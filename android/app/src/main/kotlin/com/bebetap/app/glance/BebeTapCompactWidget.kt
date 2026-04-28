package com.bebetap.app.glance

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
        val data = try { loadWidgetData(context) } catch (_: Exception) { WidgetData() }
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
                text = data.babyName.ifEmpty { "기록" },
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
                modifier = GlanceModifier.size(24.dp).clickable(refresh),
                contentAlignment = Alignment.Center,
            ) {
                Text("↻", style = TextStyle(fontSize = 13.sp, color = ColorProvider(grayColor)))
            }
        }

        Spacer(GlanceModifier.height(5.dp))

        // ── 최근 기록 3건 ──────────────────────────────────────
        val rows = buildList {
            if (data.r1Label.isNotEmpty()) add(Triple(data.r1Label, data.r1Detail, data.r1Time))
            if (data.r2Label.isNotEmpty()) add(Triple(data.r2Label, data.r2Detail, data.r2Time))
            if (data.r3Label.isNotEmpty()) add(Triple(data.r3Label, data.r3Detail, data.r3Time))
        }

        Column(
            modifier = GlanceModifier
                .fillMaxWidth()
                .clickable(openLog),
        ) {
            if (rows.isEmpty()) {
                Text(
                    "기록 없음",
                    style = TextStyle(fontSize = 10.sp, color = ColorProvider(grayColor)),
                )
            } else {
                RecordRow(rows[0].first, rows[0].second, rows[0].third, textColor, grayColor, rowBgColor)
                if (rows.size > 1) {
                    Spacer(GlanceModifier.height(4.dp))
                    RecordRow(rows[1].first, rows[1].second, rows[1].third, textColor, grayColor, rowBgColor)
                }
                if (rows.size > 2) {
                    Spacer(GlanceModifier.height(4.dp))
                    RecordRow(rows[2].first, rows[2].second, rows[2].third, textColor, grayColor, rowBgColor)
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
    val bH = data.todayBreastSec / 3600
    val bM = (data.todayBreastSec % 3600) / 60
    val sH = data.todaySleepMin / 60
    val sM = data.todaySleepMin % 60

    val items = buildList<Pair<String, String>> {
        if (data.todayFormulaMl   > 0) add("분유"   to "${data.todayFormulaMl}ml")
        if (data.todayBreastSec   > 0) add("모유"   to if (bH > 0) "${bH}h${bM}m" else "${bM}분")
        if (data.todayPumpedMl    > 0) add("유축"   to "${data.todayPumpedMl}ml")
        if (data.todayBabyFoodMl  > 0) add("이유식" to "${data.todayBabyFoodMl}ml")
        if (data.todayDiaperCount > 0) add("기저귀" to "${data.todayDiaperCount}회")
        if (data.todaySleepMin    > 0) add("수면"   to if (sH > 0) "${sH}h${sM}m" else "${sM}분")
    }

    if (items.isEmpty()) {
        Text("오늘 기록 없음",
            style = TextStyle(fontSize = 9.sp, color = ColorProvider(grayColor)))
        return
    }

    // 2x2 공간 제한 — 최대 2개만 표시
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        items.take(2).forEachIndexed { idx, (label, value) ->
            if (idx > 0) Spacer(GlanceModifier.width(6.dp))
            val dotColor = WidgetColors.colorForLabel(label)
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
                    style = TextStyle(fontSize = 9.sp, color = ColorProvider(grayColor)),
                    maxLines = 1,
                )
            }
        }
    }
}

class BebeTapCompactWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = BebeTapCompactWidget()
}
