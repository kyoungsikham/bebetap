package com.bebetap.app.glance

import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.*
import androidx.glance.appwidget.*
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import com.bebetap.app.MainActivity
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class BebeTapWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val data = try {
            loadWidgetData(context)
        } catch (e: Exception) {
            WidgetData()
        }

        provideContent {
            WidgetContent(data, context)
        }
    }

    private fun loadWidgetData(context: Context): WidgetData {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        return WidgetData(
            lastFeedingLabel = prefs.getString("lastFeedingLabel", "") ?: "",
            lastFeedingTime  = prefs.getString("lastFeedingTime",  "") ?: "",
            r1Label  = prefs.getString("r1_label",  "") ?: "",
            r1Detail = prefs.getString("r1_detail", "") ?: "",
            r1Time   = prefs.getString("r1_time",   "") ?: "",
            r2Label  = prefs.getString("r2_label",  "") ?: "",
            r2Detail = prefs.getString("r2_detail", "") ?: "",
            r2Time   = prefs.getString("r2_time",   "") ?: "",
            r3Label  = prefs.getString("r3_label",  "") ?: "",
            r3Detail = prefs.getString("r3_detail", "") ?: "",
            r3Time   = prefs.getString("r3_time",   "") ?: "",
        )
    }
}

private data class WidgetData(
    val lastFeedingLabel: String = "",
    val lastFeedingTime: String  = "",
    val r1Label: String  = "",
    val r1Detail: String = "",
    val r1Time: String   = "",
    val r2Label: String  = "",
    val r2Detail: String = "",
    val r2Time: String   = "",
    val r3Label: String  = "",
    val r3Detail: String = "",
    val r3Time: String   = "",
)

// home_widget이 인식하는 HOME_WIDGET_LAUNCH_ACTION으로 인텐트 생성 (버그 #3 핵심 수정)
private fun makeIntent(context: Context, uri: String): Intent =
    Intent(context, MainActivity::class.java).apply {
        data = Uri.parse(uri)
        action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
    }

private fun isNightMode(context: Context): Boolean =
    (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) ==
            Configuration.UI_MODE_NIGHT_YES

@GlanceComposable
@Composable
private fun WidgetContent(data: WidgetData, context: Context) {
    val night = isNightMode(context)
    val bgColor      = if (night) WidgetColors.BackgroundDark else WidgetColors.BackgroundLight
    val textColor    = if (night) WidgetColors.TextDark       else WidgetColors.TextLight
    val grayColor    = if (night) WidgetColors.GrayDark       else WidgetColors.Gray

    val openLog = actionStartActivity(makeIntent(context, "bebetap://log"))

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(bgColor)),
        contentAlignment = Alignment.TopStart,
    ) {
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(horizontal = 10.dp, vertical = 8.dp),
        ) {
            // ── 헤더 (탭 → 기록 목록) ──────────────────────────
            Column(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .clickable(openLog),
            ) {
                Text(
                    "BebeTap",
                    style = TextStyle(
                        fontSize = 9.sp,
                        color = ColorProvider(grayColor),
                    ),
                )
                Spacer(GlanceModifier.height(1.dp))

                val short = elapsedShortLabel(data.lastFeedingTime)
                val headerText = if (data.lastFeedingLabel.isNotEmpty() && short.isNotEmpty())
                    "${data.lastFeedingLabel} $short 경과"
                else
                    "기록 없음"
                val headerColor = if (data.lastFeedingLabel.isNotEmpty() && short.isNotEmpty())
                    textColor else grayColor

                Text(
                    headerText,
                    style = TextStyle(
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(headerColor),
                    ),
                )
            }

            Spacer(GlanceModifier.height(6.dp))

            // ── 최근 기록 3건 (탭 → 기록 목록) ─────────────────
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
                        "기록을 추가하면 여기에 표시됩니다",
                        style = TextStyle(
                            fontSize = 10.sp,
                            color = ColorProvider(grayColor),
                        ),
                    )
                } else {
                    RecordRow(rows[0].first, rows[0].second, rows[0].third, textColor, grayColor)
                    if (rows.size > 1) {
                        Spacer(GlanceModifier.height(3.dp))
                        RecordRow(rows[1].first, rows[1].second, rows[1].third, textColor, grayColor)
                    }
                    if (rows.size > 2) {
                        Spacer(GlanceModifier.height(3.dp))
                        RecordRow(rows[2].first, rows[2].second, rows[2].third, textColor, grayColor)
                    }
                }
            }

            Spacer(GlanceModifier.height(8.dp))

            // ── 빠른 입력 버튼 5개 ────────────────────────────────
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
            ) {
                QuickButton("분유",   WidgetColors.Blue,   "bebetap://log/formula", context, GlanceModifier.defaultWeight())
                Spacer(GlanceModifier.width(3.dp))
                QuickButton("모유",   WidgetColors.Purple, "bebetap://log/breast",  context, GlanceModifier.defaultWeight())
                Spacer(GlanceModifier.width(3.dp))
                QuickButton("유축",   WidgetColors.Green,  "bebetap://log/pumped",  context, GlanceModifier.defaultWeight())
                Spacer(GlanceModifier.width(3.dp))
                QuickButton("수면",   WidgetColors.Orange, "bebetap://log/sleep",   context, GlanceModifier.defaultWeight())
                Spacer(GlanceModifier.width(3.dp))
                QuickButton("기저귀", WidgetColors.Red,    "bebetap://log/diaper",  context, GlanceModifier.defaultWeight())
            }
        }
    }
}

@GlanceComposable
@Composable
private fun RecordRow(
    label: String,
    detail: String,
    time: String,
    textColor: Color,
    grayColor: Color,
) {
    val dotColor = WidgetColors.colorForLabel(label)
    Row(
        modifier = GlanceModifier.fillMaxWidth(),
        verticalAlignment = Alignment.Vertical.CenterVertically,
    ) {
        Box(
            modifier = GlanceModifier
                .width(8.dp)
                .height(8.dp)
                .cornerRadius(4.dp)
                .background(ColorProvider(dotColor)),
        ) {}
        Spacer(GlanceModifier.width(5.dp))
        Text(
            label,
            modifier = GlanceModifier.width(40.dp),
            style = TextStyle(
                fontSize = 11.sp,
                color = ColorProvider(grayColor),
            ),
        )
        Text(
            detail,
            modifier = GlanceModifier.defaultWeight(),
            style = TextStyle(
                fontSize = 11.sp,
                fontWeight = FontWeight.Medium,
                color = ColorProvider(textColor),
            ),
        )
        Text(
            elapsedLabel(time),
            style = TextStyle(
                fontSize = 10.sp,
                color = ColorProvider(grayColor),
            ),
        )
    }
}

@GlanceComposable
@Composable
private fun QuickButton(
    label: String,
    color: Color,
    uri: String,
    context: Context,
    modifier: GlanceModifier = GlanceModifier,
) {
    val action = actionStartActivity(makeIntent(context, uri))
    Box(
        modifier = modifier
            .height(28.dp)
            .cornerRadius(8.dp)
            .background(ColorProvider(color))
            .clickable(action),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = TextStyle(
                fontSize = 10.sp,
                fontWeight = FontWeight.Medium,
                color = ColorProvider(Color.White),
            ),
        )
    }
}

class BebeTapWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = BebeTapWidget()
}
