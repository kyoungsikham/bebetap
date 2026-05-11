package com.bebetap.app.glance

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.*
import androidx.glance.appwidget.*
import androidx.glance.appwidget.action.*
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import com.bebetap.app.MainActivity
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

private val actionUriKey = ActionParameters.Key<String>("uri")

// 수유·기저귀·수면 빠른 저장 silent callback (기존 유지)
class WidgetSilentActionCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        val uriString = parameters[actionUriKey] ?: return
        val uri = Uri.parse(uriString)
        val segs = uri.pathSegments

        if (uri.host == "action" && segs.size >= 2) {
            val nowIso = java.time.Instant.now().toString()
            val label = when ("${segs[0]}/${segs[1]}") {
                "feeding/formula"  -> "분유"
                "feeding/breast"   -> "모유"
                "feeding/pumped"   -> "유축"
                "feeding/babyFood" -> "이유식"
                else               -> null
            }
            if (label != null) {
                context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
                    .edit()
                    .putString("lastFeedingLabel", label)
                    .putString("lastFeedingTime", nowIso)
                    .apply()
            }
        }
        BebeTapWidget().updateAll(context)
        BebeTapCompactWidget().updateAll(context)
        try { HomeWidgetBackgroundIntent.getBroadcast(context, uri).send() } catch (_: Exception) {}
    }
}

// 새로고침 아이콘 탭 → 즉시 redraw 후 Dart isolate에서 DB 재조회
// home_widget main MethodChannel은 background isolate에 미등록 → isolate 측 triggerUpdate()가
// silent fail. Kotlin이 지연 후 직접 updateAll()을 2단계 추가 호출한다.
class WidgetRefreshActionCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        // 1. 현재 prefs로 즉시 redraw
        BebeTapWidget().updateAll(context)
        BebeTapCompactWidget().updateAll(context)

        // 2. 핀 정보 추출 후 background isolate trigger
        val appWidgetId = try {
            GlanceAppWidgetManager(context).getAppWidgetId(glanceId)
        } catch (_: Exception) { AppWidgetManager.INVALID_APPWIDGET_ID }
        val prefs        = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val pinnedBabyId = prefs.getString("widget_baby_for_$appWidgetId", null)?.takeIf { it.isNotEmpty() }
        val uriStr = if (pinnedBabyId != null) "bebetap://action/refresh?baby=$pinnedBabyId"
                     else "bebetap://action/refresh"
        try { HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(uriStr)).send() } catch (_: Exception) {}

        // 3. background isolate의 DB 재조회 + prefs write 완료 후 다시 redraw
        CoroutineScope(Dispatchers.Main).launch {
            delay(2000)
            try { BebeTapWidget().updateAll(context) } catch (_: Exception) {}
            try { BebeTapCompactWidget().updateAll(context) } catch (_: Exception) {}
            delay(2500)  // 누적 4.5초 — 다중 아기 + DB 7쿼리 × N 안전망
            try { BebeTapWidget().updateAll(context) } catch (_: Exception) {}
            try { BebeTapCompactWidget().updateAll(context) } catch (_: Exception) {}
        }
    }
}

// ◂ 이전 아기 탭
class WidgetBabyPrevActionCallback : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        switchBaby(context, direction = -1)
    }
}

// ▸ 다음 아기 탭
class WidgetBabyNextActionCallback : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        switchBaby(context, direction = +1)
    }
}

private fun switchBaby(context: Context, direction: Int) {
    val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    val ids   = (prefs.getString("widget_baby_ids",    "") ?: "").split("|").filter { it.isNotEmpty() }
    val names = (prefs.getString("widget_baby_names",  "") ?: "").split("|").filter { it.isNotEmpty() }
    val familyIds = (prefs.getString("widget_baby_family_ids", "") ?: "").split("|").filter { it.isNotEmpty() }
    val n = ids.size
    if (n <= 1) return
    val curIdx = (prefs.getString("widget_baby_index", "0") ?: "0").toIntOrNull() ?: 0
    val newIdx = ((curIdx + direction) + n) % n
    prefs.edit()
        .putString("widget_baby_id",    ids.getOrElse(newIdx) { ids[0] })
        .putString("widget_baby_name",  names.getOrElse(newIdx) { names[0] })
        .putString("widget_family_id",  familyIds.getOrElse(newIdx) { familyIds.getOrElse(0) { "" } })
        .putString("widget_baby_index", newIdx.toString())
        .apply()
    // 전환된 아기 이름으로 즉시 redraw (updateAll은 suspend이므로 코루틴에서 실행)
    CoroutineScope(Dispatchers.Main).launch {
        BebeTapWidget().updateAll(context)
        BebeTapCompactWidget().updateAll(context)
    }
    val uri = Uri.parse("bebetap://action/baby/switch")
    try { HomeWidgetBackgroundIntent.getBroadcast(context, uri).send() } catch (_: Exception) {}
}

class BebeTapWidget : GlanceAppWidget() {
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
        // 사용자가 보고 있는 위젯이라는 휴리스틱. last entry의 baby로 데이터 로드.
        // (first entry 사용은 다른 위젯의 oldest entry를 표시할 위험이 있어 last로 변경.)
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
                        emptyHint     = prefs.getString("widget_empty_hint", "기록을 추가하면 여기에 표시됩니다") ?: "기록을 추가하면 여기에 표시됩니다",
                        emptyToday    = prefs.getString("widget_empty_today", "오늘 기록 없음") ?: "오늘 기록 없음",
                    )
                }
            } else {
                WidgetData(
                    babyCount     = babyIds.size.coerceAtLeast(1),
                    titleFallback = prefs.getString("widget_title_fallback", "기록") ?: "기록",
                    emptyHint     = prefs.getString("widget_empty_hint", "기록을 추가하면 여기에 표시됩니다") ?: "기록을 추가하면 여기에 표시됩니다",
                    emptyToday    = prefs.getString("widget_empty_today", "오늘 기록 없음") ?: "오늘 기록 없음",
                )
            }
            provideContent { WidgetContent(data, context) }
            return
        }

        val data = try { loadWidgetData(context, pinnedBabyId) } catch (_: Exception) { WidgetData() }
        provideContent { WidgetContent(data, context) }
    }
}

internal data class WidgetData(
    val babyName: String = "",
    val babyCount: Int   = 1,  // 등록된 아기 수 (1 이하면 ◂/▸ 숨김)
    val r1Label: String  = "",
    val r1Detail: String = "",
    val r1Time: String   = "",
    val r1Color: String  = "",
    val r2Label: String  = "",
    val r2Detail: String = "",
    val r2Time: String   = "",
    val r2Color: String  = "",
    val r3Label: String  = "",
    val r3Detail: String = "",
    val r3Time: String   = "",
    val r3Color: String  = "",
    val themeMode: String    = "system",
    val todayFormulaMl: Int   = 0,
    val todayPumpedMl: Int    = 0,
    val todayBabyFoodMl: Int  = 0,
    val todayBreastSec: Int   = 0,
    val todayDiaperCount: Int = 0,
    val todaySleepMin: Int    = 0,
    val opacity: Float = 1.0f,
    // 다국어 텍스트 (Dart가 번역해서 push)
    val emptyShort: String   = "기록 없음",
    val emptyHint: String    = "기록을 추가하면 여기에 표시됩니다",
    val emptyToday: String   = "오늘 기록 없음",
    val titleFallback: String = "기록",
    val unitMin: String      = "분",
    val agoSuffix: String    = " 전",
    // 오늘 총량 — 번역된 라벨 + 포맷된 값
    val todayFormulaLabel: String  = "분유",
    val todayBreastLabel: String   = "모유",
    val todayPumpedLabel: String   = "유축",
    val todayBabyFoodLabel: String = "이유식",
    val todayDiaperLabel: String   = "기저귀",
    val todaySleepLabel: String    = "수면",
    val todayBreastValue: String   = "",
    val todaySleepValue: String    = "",
    val todayDiaperValue: String   = "",
)

internal fun loadWidgetData(context: Context, pinnedBabyId: String? = null): WidgetData {
    val prefs   = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    val babyIds = (prefs.getString("widget_baby_ids", "") ?: "").split("|").filter { it.isNotEmpty() }

    fun str(key: String, default: String = ""): String {
        if (pinnedBabyId != null) {
            // pinned된 아이 전용 키만 읽음. 아직 없으면 빈값(다른 아이 데이터로 오염 방지)
            return prefs.getString("${key}_${pinnedBabyId}", default) ?: default
        }
        return prefs.getString(key, default) ?: default
    }

    val babyName = if (pinnedBabyId != null) {
        // 1순위: Configure Activity가 즉시 저장한 per-baby 명시 이름
        prefs.getString("widget_baby_name_$pinnedBabyId", null)?.takeIf { it.isNotEmpty() }
            ?: run {
                // 2순위: widget_baby_names 배열에서 index lookup
                val names = (prefs.getString("widget_baby_names", "") ?: "").split("|").filter { it.isNotEmpty() }
                val idx   = babyIds.indexOf(pinnedBabyId)
                if (idx >= 0) names.getOrElse(idx) { "" } else ""
                // ★ 글로벌 widget_baby_name fallback 제거 — 다른 아기 이름 오염 방지
            }
    } else {
        prefs.getString("widget_baby_name", "") ?: ""
    }

    return WidgetData(
        babyName         = babyName,
        // 인스턴스 고정 시 ◂/▸ 숨김
        babyCount        = if (pinnedBabyId != null) 1 else babyIds.size.coerceAtLeast(1),
        r1Label          = str("r1_label"),
        r1Detail         = str("r1_detail"),
        r1Time           = str("r1_time"),
        r1Color          = str("r1_color"),
        r2Label          = str("r2_label"),
        r2Detail         = str("r2_detail"),
        r2Time           = str("r2_time"),
        r2Color          = str("r2_color"),
        r3Label          = str("r3_label"),
        r3Detail         = str("r3_detail"),
        r3Time           = str("r3_time"),
        r3Color          = str("r3_color"),
        themeMode        = prefs.getString("widget_theme",       "system") ?: "system",
        todayFormulaMl   = str("today_formula_ml",   "0").toIntOrNull() ?: 0,
        todayPumpedMl    = str("today_pumped_ml",    "0").toIntOrNull() ?: 0,
        todayBabyFoodMl  = str("today_babyfood_ml",  "0").toIntOrNull() ?: 0,
        todayBreastSec   = str("today_breast_sec",   "0").toIntOrNull() ?: 0,
        todayDiaperCount = str("today_diaper_count", "0").toIntOrNull() ?: 0,
        todaySleepMin    = str("today_sleep_min",    "0").toIntOrNull() ?: 0,
        opacity          = prefs.getString("widget_opacity",   "1.00")?.toFloatOrNull()?.coerceIn(0f, 1f) ?: 1.0f,
        emptyShort       = prefs.getString("widget_empty_short",   "기록 없음") ?: "기록 없음",
        emptyHint        = prefs.getString("widget_empty_hint",    "기록을 추가하면 여기에 표시됩니다") ?: "기록을 추가하면 여기에 표시됩니다",
        emptyToday       = prefs.getString("widget_empty_today",   "오늘 기록 없음") ?: "오늘 기록 없음",
        titleFallback    = prefs.getString("widget_title_fallback","기록") ?: "기록",
        unitMin          = prefs.getString("widget_unit_min",      "분") ?: "분",
        agoSuffix        = prefs.getString("widget_ago_suffix",    " 전") ?: " 전",
        todayFormulaLabel  = prefs.getString("today_formula_label",  "분유")   ?: "분유",
        todayBreastLabel   = prefs.getString("today_breast_label",   "모유")   ?: "모유",
        todayPumpedLabel   = prefs.getString("today_pumped_label",   "유축")   ?: "유축",
        todayBabyFoodLabel = prefs.getString("today_babyfood_label", "이유식") ?: "이유식",
        todayDiaperLabel   = prefs.getString("today_diaper_label",   "기저귀") ?: "기저귀",
        todaySleepLabel    = prefs.getString("today_sleep_label",    "수면")   ?: "수면",
        todayBreastValue   = str("today_breast_value"),
        todaySleepValue    = str("today_sleep_value"),
        todayDiaperValue   = str("today_diaper_value"),
    )
}

internal fun makeDeepLinkIntent(context: Context, uri: String): Intent =
    Intent(context, MainActivity::class.java).apply {
        data = Uri.parse(uri)
        action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
    }

internal fun resolveDark(themeMode: String, context: Context): Boolean = when (themeMode) {
    "dark"  -> true
    "light" -> false
    else    -> (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) ==
                   Configuration.UI_MODE_NIGHT_YES
}

// "N분 전" / "Nh Nm 전" — unitMin/agoSuffix로 다국어 처리
internal fun elapsedShortAgo(iso: String, unitMin: String = "분", agoSuffix: String = " 전"): String {
    val s = elapsedShortLabel(iso, unitMin)
    return if (s.isEmpty()) "" else "$s$agoSuffix"
}

@GlanceComposable
@Composable
private fun WidgetContent(data: WidgetData, context: Context) {
    val night      = resolveDark(data.themeMode, context)
    val textColor  = if (night) WidgetColors.TextDark  else WidgetColors.TextLight
    val grayColor  = if (night) WidgetColors.GrayDark  else WidgetColors.Gray
    val rowBgColor = (if (night) WidgetColors.BtnBgGrayDark else Color(0xFFF0F0F4)).copy(alpha = data.opacity)
    // 라이트 모드에서 카드 배경을 흰색으로, 다크는 시스템 위임
    val rootBg     = if (night) Color.Transparent else WidgetColors.BackgroundLight.copy(alpha = data.opacity)

    val openHome = actionStartActivity(makeDeepLinkIntent(context, "bebetap://home"))
    val refresh  = actionRunCallback<WidgetRefreshActionCallback>()
    val prevBaby = actionRunCallback<WidgetBabyPrevActionCallback>()
    val nextBaby = actionRunCallback<WidgetBabyNextActionCallback>()

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(rootBg))
            .padding(horizontal = 14.dp, vertical = 12.dp),
    ) {
        // ── 헤더: [◂] 아기이름 [▸]  [↻] ──────────────────────
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.Vertical.CenterVertically,
        ) {
            if (data.babyCount > 1) {
                Box(
                    modifier = GlanceModifier.size(24.dp).clickable(prevBaby),
                    contentAlignment = Alignment.Center,
                ) { Text("◂", style = TextStyle(fontSize = 13.sp, color = ColorProvider(grayColor))) }
            }
            Text(
                text = data.babyName.ifEmpty { data.titleFallback },
                modifier = GlanceModifier.defaultWeight().clickable(openHome),
                style = TextStyle(
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(textColor),
                ),
            )
            if (data.babyCount > 1) {
                Box(
                    modifier = GlanceModifier.size(24.dp).clickable(nextBaby),
                    contentAlignment = Alignment.Center,
                ) { Text("▸", style = TextStyle(fontSize = 13.sp, color = ColorProvider(grayColor))) }
            }
            Box(
                modifier = GlanceModifier.size(44.dp).clickable(refresh),
                contentAlignment = Alignment.Center,
            ) {
                Text("↻", style = TextStyle(fontSize = 20.sp, color = ColorProvider(grayColor)))
            }
        }

        Spacer(GlanceModifier.height(8.dp))

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
                .clickable(openHome),
        ) {
            if (rows.isEmpty()) {
                Text(
                    data.emptyHint,
                    style = TextStyle(fontSize = 10.sp, color = ColorProvider(grayColor)),
                )
            } else {
                RecordRow(rows[0].label, rows[0].detail, rows[0].time, rows[0].color, data.unitMin, data.agoSuffix, textColor, grayColor, rowBgColor, verticalPad = 9.dp)
                if (rows.size > 1) {
                    Spacer(GlanceModifier.height(10.dp))
                    RecordRow(rows[1].label, rows[1].detail, rows[1].time, rows[1].color, data.unitMin, data.agoSuffix, textColor, grayColor, rowBgColor, verticalPad = 9.dp)
                }
                if (rows.size > 2) {
                    Spacer(GlanceModifier.height(10.dp))
                    RecordRow(rows[2].label, rows[2].detail, rows[2].time, rows[2].color, data.unitMin, data.agoSuffix, textColor, grayColor, rowBgColor, verticalPad = 9.dp)
                }
            }
        }

        Spacer(GlanceModifier.defaultWeight())

        // ── 오늘 총량 (값이 있는 카테고리만 가로 나열) ────────────
        TotalsRow(data, grayColor, twoRows = true)
    }
}

@GlanceComposable
@Composable
internal fun TotalsRow(data: WidgetData, grayColor: Color, twoRows: Boolean = false) {
    // 라벨과 포맷된 값은 Dart가 번역해서 push (다국어 지원)
    val items = buildList<Triple<String, String, String>> {
        if (data.todayFormulaMl   > 0) add(Triple("formula",     data.todayFormulaLabel,  "${data.todayFormulaMl}ml"))
        if (data.todayBreastSec   > 0 && data.todayBreastValue.isNotEmpty())
            add(Triple("breast",   data.todayBreastLabel,  data.todayBreastValue))
        if (data.todayPumpedMl    > 0) add(Triple("pumped",      data.todayPumpedLabel,   "${data.todayPumpedMl}ml"))
        if (data.todayBabyFoodMl  > 0) add(Triple("babyFood",    data.todayBabyFoodLabel, "${data.todayBabyFoodMl}ml"))
        if (data.todayDiaperCount > 0 && data.todayDiaperValue.isNotEmpty())
            add(Triple("diaper",   data.todayDiaperLabel,  data.todayDiaperValue))
        if (data.todaySleepMin    > 0 && data.todaySleepValue.isNotEmpty())
            add(Triple("sleep",    data.todaySleepLabel,   data.todaySleepValue))
    }

    if (items.isEmpty()) {
        Text(data.emptyToday,
            style = TextStyle(fontSize = 12.sp, color = ColorProvider(grayColor)))
        return
    }

    val firstRow  = if (twoRows && items.size > 3) items.take(3) else items
    val secondRow = if (twoRows && items.size > 3) items.drop(3) else emptyList()

    Column(modifier = GlanceModifier.fillMaxWidth()) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            firstRow.forEachIndexed { idx, (category, label, value) ->
                if (idx > 0) Spacer(GlanceModifier.width(8.dp))
                val dotColor = WidgetColors.colorForCategory(category)
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Box(
                        modifier = GlanceModifier
                            .width(6.dp).height(6.dp)
                            .cornerRadius(3.dp)
                            .background(ColorProvider(dotColor)),
                    ) {}
                    Spacer(GlanceModifier.width(3.dp))
                    Text(
                        "$label $value",
                        style = TextStyle(fontSize = 12.sp, color = ColorProvider(grayColor)),
                        maxLines = 1,
                    )
                }
            }
        }
        if (secondRow.isNotEmpty()) {
            Spacer(GlanceModifier.height(4.dp))
            Row(modifier = GlanceModifier.fillMaxWidth()) {
                secondRow.forEachIndexed { idx, (category, label, value) ->
                    if (idx > 0) Spacer(GlanceModifier.width(8.dp))
                    val dotColor = WidgetColors.colorForCategory(category)
                    Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                        Box(
                            modifier = GlanceModifier
                                .width(6.dp).height(6.dp)
                                .cornerRadius(3.dp)
                                .background(ColorProvider(dotColor)),
                        ) {}
                        Spacer(GlanceModifier.width(3.dp))
                        Text(
                            "$label $value",
                            style = TextStyle(fontSize = 10.sp, color = ColorProvider(grayColor)),
                            maxLines = 1,
                        )
                    }
                }
            }
        }
    }
}

@GlanceComposable
@Composable
internal fun RecordRow(
    label: String,
    detail: String,
    time: String,
    colorCategory: String,
    unitMin: String,
    agoSuffix: String,
    textColor: Color,
    grayColor: Color,
    bgColor: Color,
    verticalPad: Dp = 3.dp,
) {
    val dotColor = WidgetColors.colorForCategory(colorCategory)
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .background(ColorProvider(bgColor))
            .cornerRadius(8.dp)
            .padding(horizontal = 6.dp, vertical = verticalPad),
        verticalAlignment = Alignment.Vertical.CenterVertically,
    ) {
        Box(
            modifier = GlanceModifier
                .width(8.dp).height(8.dp)
                .cornerRadius(4.dp)
                .background(ColorProvider(dotColor)),
        ) {}
        Spacer(GlanceModifier.width(5.dp))
        Text(
            label,
            modifier = GlanceModifier.width(36.dp),
            style = TextStyle(fontSize = 11.sp, color = ColorProvider(grayColor)),
        )
        Text(
            detail,
            modifier = GlanceModifier.defaultWeight(),
            style = TextStyle(
                fontSize = 11.sp,
                fontWeight = FontWeight.Medium,
                color = ColorProvider(textColor),
            ),
            maxLines = 1,
        )
        Text(
            elapsedShortAgo(time, unitMin, agoSuffix),
            style = TextStyle(fontSize = 10.sp, color = ColorProvider(grayColor)),
        )
    }
}

class BebeTapWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = BebeTapWidget()
}
