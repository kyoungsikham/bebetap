package com.bebetap.app.glance

import android.appwidget.AppWidgetManager
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.*
import androidx.glance.appwidget.*
import androidx.glance.appwidget.action.*
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider

class BebeTapCompactWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        // getAppWidgetId()는 Glance 세션 미초기화 시 예외를 던질 수 있음 → INVALID로 취급
        val appWidgetId = try {
            GlanceAppWidgetManager(context).getAppWidgetId(id)
        } catch (_: Exception) {
            AppWidgetManager.INVALID_APPWIDGET_ID
        }
        val prefs   = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val babyIds = (prefs.getString("widget_baby_ids", "") ?: "")
                         .split("|").filter { it.isNotEmpty() }

        // 직접 핀 조회
        val rawPin = prefs.getString("widget_baby_for_$appWidgetId", null)?.takeIf { it.isNotEmpty() }

        // rawPin이 없으면 pending_pins 큐에서 자가복구 시도
        // (widget_baby_ids가 아직 없을 수 있으므로 babyIds.size 가드 제거)
        val pendingStr = prefs.getString("pending_pins", "") ?: ""
        val hasPendingPins = pendingStr.isNotEmpty()
        val pinnedBabyId: String? = rawPin?.also {
            // rawPin으로 직접 확인됐으면 이 위젯의 pending_pins 항목 정리
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID && pendingStr.isNotEmpty()) {
                val cleaned = pendingStr.split("|").filter { entry ->
                    val parts = entry.split(":")
                    parts.size != 2 || parts[0].toIntOrNull() != appWidgetId
                }.joinToString("|")
                if (cleaned != pendingStr) {
                    prefs.edit().putString("pending_pins", cleaned).apply()
                }
            }
        } ?: run {
            // 자가복구는 "자기 appWidgetId가 valid이고 정확히 매칭되는 entry가 있을 때만" 허용.
            // head claim은 다른 위젯의 entry를 가져가 영구 잘못된 핀을 만들 수 있어 금지한다.
            if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return@run null
            val pending = pendingStr.split("|").filter { it.isNotEmpty() }
            if (pending.isEmpty()) return@run null

            val parsed = pending.map { entry ->
                val parts = entry.split(":")
                if (parts.size == 2) parts[0].toIntOrNull() to parts[1] else null to null
            }
            val matchIdx = parsed.indexOfFirst { (wid, _) ->
                wid != null && wid == appWidgetId
            }
            if (matchIdx < 0) return@run null

            val (_, baby) = parsed[matchIdx]
            if (baby.isNullOrEmpty()) return@run null

            val remaining = parsed.toMutableList()
                .also { it.removeAt(matchIdx) }
                .mapNotNull { (wid, b) -> if (wid != null && b != null) "$wid:$b" else null }
            prefs.edit()
                .putString("widget_baby_for_$appWidgetId", baby)
                .putString("pending_pins", remaining.joinToString("|"))
                .commit()
            baby
        }

        // 핀 미확정 fallback: pending_pins의 마지막 entry = 가장 최근에 추가된 위젯이
        // 사용자가 보고 있는 위젯이라는 휴리스틱.
        if (pinnedBabyId == null && (babyIds.size > 1 || hasPendingPins)) {
            val peekBabyId = if (hasPendingPins) {
                pendingStr.split("|").lastOrNull { it.isNotEmpty() }
                    ?.split(":")?.let { parts -> if (parts.size >= 2) parts[1].ifEmpty { null } else null }
            } else null

            val data = if (peekBabyId != null) {
                try { loadWidgetData(context, peekBabyId) } catch (_: Exception) {
                    WidgetData(
                        babyCount     = babyIds.size.coerceAtLeast(1),
                        titleFallback = prefs.getString("widget_title_fallback", "기록") ?: "기록",
                        emptyShort    = prefs.getString("widget_empty_short", "기록 없음") ?: "기록 없음",
                        emptyToday    = prefs.getString("widget_empty_today", "오늘 기록 없음") ?: "오늘 기록 없음",
                    )
                }
            } else {
                WidgetData(
                    babyCount     = babyIds.size.coerceAtLeast(1),
                    titleFallback = prefs.getString("widget_title_fallback", "기록") ?: "기록",
                    emptyShort    = prefs.getString("widget_empty_short", "기록 없음") ?: "기록 없음",
                    emptyToday    = prefs.getString("widget_empty_today", "오늘 기록 없음") ?: "오늘 기록 없음",
                )
            }
            provideContent { CompactContent(data, context) }
            return
        }

        val data = try { loadWidgetData(context, pinnedBabyId) } catch (_: Exception) { WidgetData() }
        provideContent { CompactContent(data, context) }
    }
}

@GlanceComposable
@Composable
private fun CompactContent(data: WidgetData, context: Context) {
    val night      = resolveDark(data.themeMode, context)
    val textColor  = if (night) WidgetColors.TextDark  else WidgetColors.TextLight
    val grayColor  = if (night) WidgetColors.GrayDark  else WidgetColors.Gray
    val rowBgColor = (if (night) WidgetColors.BtnBgGrayDark else Color(0xFFF0F0F4)).copy(alpha = data.opacity)
    val rootBg     = if (night) Color.Transparent else WidgetColors.BackgroundLight.copy(alpha = data.opacity)

    val openLog  = actionStartActivity(makeDeepLinkIntent(context, "bebetap://home"))
    val refresh  = actionRunCallback<WidgetRefreshActionCallback>()
    val prevBaby = actionRunCallback<WidgetBabyPrevActionCallback>()
    val nextBaby = actionRunCallback<WidgetBabyNextActionCallback>()

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(rootBg))
            .padding(horizontal = 10.dp, vertical = 8.dp),
    ) {
        // ── 헤더: [◂] 아기이름 [▸]  [↻] ──────────────────────
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.Vertical.CenterVertically,
        ) {
            if (data.babyCount > 1) {
                Box(
                    modifier = GlanceModifier.size(20.dp).clickable(prevBaby),
                    contentAlignment = Alignment.Center,
                ) { Text("◂", style = TextStyle(fontSize = 11.sp, color = ColorProvider(grayColor))) }
            }
            Text(
                text = data.babyName.ifEmpty { data.titleFallback },
                modifier = GlanceModifier.defaultWeight().clickable(openLog),
                style = TextStyle(
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(textColor),
                ),
            )
            if (data.babyCount > 1) {
                Box(
                    modifier = GlanceModifier.size(20.dp).clickable(nextBaby),
                    contentAlignment = Alignment.Center,
                ) { Text("▸", style = TextStyle(fontSize = 11.sp, color = ColorProvider(grayColor))) }
            }
            Box(
                modifier = GlanceModifier.size(36.dp).clickable(refresh),
                contentAlignment = Alignment.Center,
            ) {
                Text("↻", style = TextStyle(fontSize = 17.sp, color = ColorProvider(grayColor)))
            }
        }

        Spacer(GlanceModifier.height(5.dp))

        // ── 최근 기록 3건 ──────────────────────────────────────
        data class Row(val label: String, val detail: String, val time: String, val color: String)
        val rows = buildList {
            if (data.r1Label.isNotEmpty()) add(Row(data.r1Label, data.r1Detail, data.r1Time, data.r1Color))
            if (data.r2Label.isNotEmpty()) add(Row(data.r2Label, data.r2Detail, data.r2Time, data.r2Color))
            if (data.r3Label.isNotEmpty()) add(Row(data.r3Label, data.r3Detail, data.r3Time, data.r3Color))
        }

        Column(
            modifier = GlanceModifier
                .fillMaxWidth()
                .clickable(openLog),
        ) {
            if (rows.isEmpty()) {
                Text(
                    data.emptyShort,
                    style = TextStyle(fontSize = 10.sp, color = ColorProvider(grayColor)),
                )
            } else {
                RecordRow(rows[0].label, rows[0].detail, rows[0].time, rows[0].color, data.unitMin, data.agoSuffix, textColor, grayColor, rowBgColor)
                if (rows.size > 1) {
                    Spacer(GlanceModifier.height(4.dp))
                    RecordRow(rows[1].label, rows[1].detail, rows[1].time, rows[1].color, data.unitMin, data.agoSuffix, textColor, grayColor, rowBgColor)
                }
                if (rows.size > 2) {
                    Spacer(GlanceModifier.height(4.dp))
                    RecordRow(rows[2].label, rows[2].detail, rows[2].time, rows[2].color, data.unitMin, data.agoSuffix, textColor, grayColor, rowBgColor)
                }
            }
        }

        Spacer(GlanceModifier.height(6.dp))

        // ── 오늘 총량 1줄 (첫 2개만) ──────────────────────────
        CompactTotalsLine(data, grayColor)
    }
}

@GlanceComposable
@Composable
private fun CompactTotalsLine(data: WidgetData, grayColor: Color) {
    val items = buildList<Triple<String, String, String>> {
        if (data.todayFormulaMl   > 0) add(Triple("formula",  data.todayFormulaLabel,  "${data.todayFormulaMl}ml"))
        if (data.todayBreastSec   > 0 && data.todayBreastValue.isNotEmpty())
            add(Triple("breast",   data.todayBreastLabel,  data.todayBreastValue))
        if (data.todayPumpedMl    > 0) add(Triple("pumped",   data.todayPumpedLabel,   "${data.todayPumpedMl}ml"))
        if (data.todayBabyFoodMl  > 0) add(Triple("babyFood", data.todayBabyFoodLabel, "${data.todayBabyFoodMl}ml"))
        if (data.todayDiaperCount > 0 && data.todayDiaperValue.isNotEmpty())
            add(Triple("diaper",   data.todayDiaperLabel,  data.todayDiaperValue))
        if (data.todaySleepMin    > 0 && data.todaySleepValue.isNotEmpty())
            add(Triple("sleep",    data.todaySleepLabel,   data.todaySleepValue))
    }

    if (items.isEmpty()) {
        Text(data.emptyToday,
            style = TextStyle(fontSize = 11.sp, color = ColorProvider(grayColor)))
        return
    }

    // 2x2 공간 제한 — 최대 2개만 표시
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        items.take(2).forEachIndexed { idx, (category, label, value) ->
            if (idx > 0) Spacer(GlanceModifier.width(6.dp))
            val dotColor = WidgetColors.colorForCategory(category)
            Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                Box(
                    modifier = GlanceModifier
                        .width(5.dp).height(5.dp)
                        .cornerRadius(3.dp)
                        .background(ColorProvider(dotColor)),
                ) {}
                Spacer(GlanceModifier.width(2.dp))
                Text(
                    "$label $value",
                    style = TextStyle(fontSize = 11.sp, color = ColorProvider(grayColor)),
                    maxLines = 1,
                )
            }
        }
    }
}

class BebeTapCompactWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = BebeTapCompactWidget()
}
