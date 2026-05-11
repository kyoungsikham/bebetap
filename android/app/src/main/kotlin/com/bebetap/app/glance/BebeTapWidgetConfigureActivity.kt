package com.bebetap.app.glance

import android.app.Activity
import android.app.AlertDialog
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.glance.appwidget.updateAll
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch


/**
 * 위젯 추가 시 launcher가 호출하는 Configure Activity.
 * 아기가 2명 이상이면 어떤 아기를 이 위젯에 표시할지 선택하게 한다.
 * 아기가 1명이거나 목록이 없으면 즉시 RESULT_OK를 반환한다.
 */
class BebeTapWidgetConfigureActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 기본값은 RESULT_CANCELED (다이얼로그 밖을 탭해도 위젯 추가 안 됨)
        setResult(RESULT_CANCELED)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val ids   = (prefs.getString("widget_baby_ids",   "") ?: "").split("|").filter { it.isNotEmpty() }
        val names = (prefs.getString("widget_baby_names", "") ?: "").split("|").filter { it.isNotEmpty() }

        if (ids.isEmpty()) {
            // 등록된 아기가 없음 → 핀 저장 안 함, 글로벌 키로 렌더링.
            confirmAndFinish(babyId = null)
            return
        }
        if (ids.size == 1) {
            // 아기가 1명 → 다이얼로그 생략하고 자동 핀. per-baby 키로 렌더링되어
            // 이름과 최근 기록이 즉시 표시된다.
            confirmAndFinish(babyId = ids[0], babyName = names.getOrNull(0))
            return
        }

        val titleFallback = prefs.getString("widget_title_fallback", "아기 선택") ?: "아기 선택"
        AlertDialog.Builder(this)
            .setTitle(titleFallback)
            .setItems(names.toTypedArray()) { _, which ->
                confirmAndFinish(babyId = ids.getOrNull(which), babyName = names.getOrNull(which))
            }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun confirmAndFinish(babyId: String?, babyName: String? = null) {
        val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        if (babyId != null) {
            val edit = prefs.edit().putString("widget_baby_for_$appWidgetId", babyId)
            if (!babyName.isNullOrEmpty()) {
                edit.putString("widget_baby_name_$babyId", babyName)
            }

            // 글로벌 키 → per-baby 키 prePopulate: widget_baby_id (글로벌 키 owner)가
            // 선택한 babyId와 같을 때만 복사. 다른 baby의 데이터로 오염되는 것을 방지하면서
            // background isolate가 per-baby 키를 채우기 전 첫 렌더에서도 데이터 표시.
            val globalOwnerId = prefs.getString("widget_baby_id", null)
            if (globalOwnerId == babyId) {
                val prePopulateKeys = listOf(
                    "r1_label","r1_detail","r1_time","r1_color",
                    "r2_label","r2_detail","r2_time","r2_color",
                    "r3_label","r3_detail","r3_time","r3_color",
                    "today_formula_ml","today_pumped_ml","today_babyfood_ml","today_breast_sec",
                    "today_diaper_count","today_sleep_min",
                    "today_breast_value","today_sleep_value","today_diaper_value",
                )
                for (key in prePopulateKeys) {
                    val perBabyKey = "${key}_$babyId"
                    if (prefs.getString(perBabyKey, null).isNullOrEmpty()) {
                        val globalVal = prefs.getString(key, null)
                        if (!globalVal.isNullOrEmpty()) edit.putString(perBabyKey, globalVal)
                    }
                }
            }

            // 같은 appWidgetId의 stale entry 제거 후 append (멱등성 보장)
            val existingPending = prefs.getString("pending_pins", "") ?: ""
            val filtered = existingPending.split("|").filter { entry ->
                if (entry.isEmpty()) return@filter false
                val parts = entry.split(":")
                parts.size != 2 || parts[0].toIntOrNull() != appWidgetId
            }
            val newEntry = "$appWidgetId:$babyId"
            val newPending = (filtered + newEntry).joinToString("|")
            edit.putString("pending_pins", newPending)
            edit.commit()
        } else {
            prefs.edit().remove("widget_baby_for_$appWidgetId").commit()
        }

        // Dart background isolate로 refresh 트리거 → 모든 아기의 per-baby 키 최신 DB 데이터로 갱신
        val refreshUri = if (babyId != null)
            "bebetap://action/refresh?baby=$babyId"
        else
            "bebetap://action/refresh"
        try {
            HomeWidgetBackgroundIntent
                .getBroadcast(this, Uri.parse(refreshUri))
                .send()
        } catch (_: Exception) {}

        setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId))
        finish()

        // finish() 후 즉시 + 단계별 updateAll:
        // - 0ms : pre-populate 데이터로 즉시 렌더링 (이름·임시 레코드)
        // - 2000ms: background isolate DB 재조회 완료 후 최신 데이터 반영
        // - 5000ms: 안전망 (네트워크 지연 등)
        CoroutineScope(Dispatchers.Main).launch {
            try { BebeTapWidget().updateAll(applicationContext) } catch (_: Exception) {}
            try { BebeTapCompactWidget().updateAll(applicationContext) } catch (_: Exception) {}
            delay(2000)
            try { BebeTapWidget().updateAll(applicationContext) } catch (_: Exception) {}
            try { BebeTapCompactWidget().updateAll(applicationContext) } catch (_: Exception) {}
            delay(3000)
            try { BebeTapWidget().updateAll(applicationContext) } catch (_: Exception) {}
            try { BebeTapCompactWidget().updateAll(applicationContext) } catch (_: Exception) {}
        }
    }
}
