package com.bebetap.app.glance

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

// 새로고침 아이콘 탭 → Dart isolate에서 DB 재조회 후 sentinel 변경 감지 → updateAll
class WidgetRefreshActionCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val prevTs = prefs.getString("widget_refresh_ts", "0") ?: "0"
        val uri = Uri.parse("bebetap://action/refresh")
        try { HomeWidgetBackgroundIntent.getBroadcast(context, uri).send() } catch (_: Exception) {}
        // Dart isolate가 _refreshAll 끝에 widget_refresh_ts를 갱신할 때까지 대기 (최대 4초)
        val deadline = System.currentTimeMillis() + 4000L
        while (System.currentTimeMillis() < deadline) {
            kotlinx.coroutines.delay(150)
            if ((prefs.getString("widget_refresh_ts", "0") ?: "0") != prevTs) break
        }
        BebeTapWidget().updateAll(context)
        BebeTapCompactWidget().updateAll(context)
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

private suspend fun switchBaby(context: Context, direction: Int) {
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
    // 헤더 이름 즉시 갱신
    BebeTapWidget().updateAll(context)
    BebeTapCompactWidget().updateAll(context)
    // Dart isolate에서 새 아기 기록 재조회 후 sentinel 갱신 → 재갱신 트리거
    val prevTs = prefs.getString("widget_refresh_ts", "0") ?: "0"
    val uri = Uri.parse("bebetap://action/baby/switch")
    try { HomeWidgetBackgroundIntent.getBroadcast(context, uri).send() } catch (_: Exception) {}
    val deadline = System.currentTimeMillis() + 4000L
    while (System.currentTimeMillis() < deadline) {
        kotlinx.coroutines.delay(150)
        if ((prefs.getString("widget_refresh_ts", "0") ?: "0") != prevTs) break
    }
    BebeTapWidget().updateAll(context)
    BebeTapCompactWidget().updateAll(context)
}

class BebeTapWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val data = try { loadWidgetData(context) } catch (_: Exception) { WidgetData() }
        provideContent { WidgetContent(data, context) }
    }
}

internal data class WidgetData(
    val babyName: String = "",
    val babyCount: Int   = 1,  // 등록된 아기 수 (1 이하면 ◂/▸ 숨김)
    val r1Label: String  = "",
    val r1Detail: String = "",
    val r1Time: String   = "",
    val r2Label: String  = "",
    val r2Detail: String = "",
    val r2Time: String   = "",
    val r3Label: String  = "",
    val r3Detail: String = "",
    val r3Time: String   = "",
    val themeMode: String    = "system",
    val todayFormulaMl: Int   = 0,
    val todayPumpedMl: Int    = 0,
    val todayBabyFoodMl: Int  = 0,
    val todayBreastSec: Int   = 0,
    val todayDiaperCount: Int = 0,
    val todaySleepMin: Int    = 0,
    val opacity: Float = 1.0f,
)

internal fun loadWidgetData(context: Context): WidgetData {
    val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    val babyIds = (prefs.getString("widget_baby_ids", "") ?: "").split("|").filter { it.isNotEmpty() }
    return WidgetData(
        babyName         = prefs.getString("widget_baby_name",   "") ?: "",
        babyCount        = babyIds.size.coerceAtLeast(1),
        r1Label          = prefs.getString("r1_label",  "") ?: "",
        r1Detail         = prefs.getString("r1_detail", "") ?: "",
        r1Time           = prefs.getString("r1_time",   "") ?: "",
        r2Label          = prefs.getString("r2_label",  "") ?: "",
        r2Detail         = prefs.getString("r2_detail", "") ?: "",
        r2Time           = prefs.getString("r2_time",   "") ?: "",
        r3Label          = prefs.getString("r3_label",  "") ?: "",
        r3Detail         = prefs.getString("r3_detail", "") ?: "",
        r3Time           = prefs.getString("r3_time",   "") ?: "",
        themeMode        = prefs.getString("widget_theme",       "system") ?: "system",
        todayFormulaMl   = prefs.getString("today_formula_ml",   "0")?.toIntOrNull() ?: 0,
        todayPumpedMl    = prefs.getString("today_pumped_ml",    "0")?.toIntOrNull() ?: 0,
        todayBabyFoodMl  = prefs.getString("today_babyfood_ml",  "0")?.toIntOrNull() ?: 0,
        todayBreastSec   = prefs.getString("today_breast_sec",   "0")?.toIntOrNull() ?: 0,
        todayDiaperCount = prefs.getString("today_diaper_count", "0")?.toIntOrNull() ?: 0,
        todaySleepMin    = prefs.getString("today_sleep_min",    "0")?.toIntOrNull() ?: 0,
        opacity          = prefs.getString("widget_opacity",   "1.00")?.toFloatOrNull()?.coerceIn(0f, 1f) ?: 1.0f,
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

// "N분 전" / "Nh Nm 전" — elapsedShortLabel에 "전" 붙임
internal fun elapsedShortAgo(iso: String): String {
    val s = elapsedShortLabel(iso)
    return if (s.isEmpty()) "" else "$s 전"
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
                text = data.babyName.ifEmpty { "기록" },
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
                modifier = GlanceModifier.size(28.dp).clickable(refresh),
                contentAlignment = Alignment.Center,
            ) {
                Text("↻", style = TextStyle(fontSize = 15.sp, color = ColorProvider(grayColor)))
            }
        }

        Spacer(GlanceModifier.height(8.dp))

        // ── 최근 기록 3건 ──────────────────────────────────────
        val rows = buildList {
            if (data.r1Label.isNotEmpty()) add(Triple(data.r1Label, data.r1Detail, data.r1Time))
            if (data.r2Label.isNotEmpty()) add(Triple(data.r2Label, data.r2Detail, data.r2Time))
            if (data.r3Label.isNotEmpty()) add(Triple(data.r3Label, data.r3Detail, data.r3Time))
        }

        Column(
            modifier = GlanceModifier
                .fillMaxWidth()
                .clickable(openHome),
        ) {
            if (rows.isEmpty()) {
                Text(
                    "기록을 추가하면 여기에 표시됩니다",
                    style = TextStyle(fontSize = 10.sp, color = ColorProvider(grayColor)),
                )
            } else {
                RecordRow(rows[0].first, rows[0].second, rows[0].third, textColor, grayColor, rowBgColor, verticalPad = 9.dp)
                if (rows.size > 1) {
                    Spacer(GlanceModifier.height(10.dp))
                    RecordRow(rows[1].first, rows[1].second, rows[1].third, textColor, grayColor, rowBgColor, verticalPad = 9.dp)
                }
                if (rows.size > 2) {
                    Spacer(GlanceModifier.height(10.dp))
                    RecordRow(rows[2].first, rows[2].second, rows[2].third, textColor, grayColor, rowBgColor, verticalPad = 9.dp)
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
    val bH = data.todayBreastSec / 3600
    val bM = (data.todayBreastSec % 3600) / 60
    val breastStr = if (bH > 0) "${bH}h${bM}m" else "${bM}분"

    val sH = data.todaySleepMin / 60
    val sM = data.todaySleepMin % 60
    val sleepStr = if (sH > 0) "${sH}h${sM}m" else "${sM}분"

    val items = buildList<Pair<String, String>> {
        if (data.todayFormulaMl   > 0) add("분유"   to "${data.todayFormulaMl}ml")
        if (data.todayBreastSec   > 0) add("모유"   to breastStr)
        if (data.todayPumpedMl    > 0) add("유축"   to "${data.todayPumpedMl}ml")
        if (data.todayBabyFoodMl  > 0) add("이유식" to "${data.todayBabyFoodMl}ml")
        if (data.todayDiaperCount > 0) add("기저귀" to "${data.todayDiaperCount}회")
        if (data.todaySleepMin    > 0) add("수면"   to sleepStr)
    }

    if (items.isEmpty()) {
        Text("오늘 기록 없음",
            style = TextStyle(fontSize = 10.sp, color = ColorProvider(grayColor)))
        return
    }

    val firstRow  = if (twoRows && items.size > 3) items.take(3) else items
    val secondRow = if (twoRows && items.size > 3) items.drop(3) else emptyList()

    Column(modifier = GlanceModifier.fillMaxWidth()) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            firstRow.forEachIndexed { idx, (label, value) ->
                if (idx > 0) Spacer(GlanceModifier.width(8.dp))
                val dotColor = WidgetColors.colorForLabel(label)
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
        if (secondRow.isNotEmpty()) {
            Spacer(GlanceModifier.height(4.dp))
            Row(modifier = GlanceModifier.fillMaxWidth()) {
                secondRow.forEachIndexed { idx, (label, value) ->
                    if (idx > 0) Spacer(GlanceModifier.width(8.dp))
                    val dotColor = WidgetColors.colorForLabel(label)
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
    textColor: Color,
    grayColor: Color,
    bgColor: Color,
    verticalPad: Dp = 3.dp,
) {
    val dotColor = WidgetColors.colorForLabel(label)
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
            elapsedShortAgo(time),
            style = TextStyle(fontSize = 10.sp, color = ColorProvider(grayColor)),
        )
    }
}

class BebeTapWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = BebeTapWidget()
}
