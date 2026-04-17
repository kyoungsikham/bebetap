package com.bebetap.app.glance

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.glance.*
import androidx.glance.action.*
import androidx.glance.appwidget.*
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class BebeTapWidget : GlanceAppWidget() {

    override val errorUiLayout: Int = 0

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val data = try {
            loadWidgetData(context)
        } catch (e: Exception) {
            WidgetData()
        }

        provideContent {
            WidgetContent(data)
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

@GlanceComposable
@Composable
private fun WidgetContent(data: WidgetData) {
    val openLogIntent = Intent(Intent.ACTION_VIEW, Uri.parse("bebetap://log"))
        .apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
    val openLog = actionStartActivity(openLogIntent)

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(Color.White))
            .clickable(openLog),
        contentAlignment = Alignment.TopStart,
    ) {
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(horizontal = 14.dp, vertical = 12.dp),
        ) {
            // ── 앱 이름 ──────────────────────────────────────
            Text(
                "BebeTap",
                style = TextStyle(
                    fontSize = 9.sp,
                    color = ColorProvider(WidgetColors.Gray),
                ),
            )
            Spacer(GlanceModifier.height(4.dp))

            // ── 마지막 수유 경과 ─────────────────────────────
            val short = elapsedShortLabel(data.lastFeedingTime)
            val headerText = if (data.lastFeedingLabel.isNotEmpty() && short.isNotEmpty())
                "${data.lastFeedingLabel} $short 경과"
            else
                "기록 없음"
            val headerColor = if (data.lastFeedingLabel.isNotEmpty() && short.isNotEmpty())
                Color.Black
            else
                WidgetColors.Gray

            Text(
                headerText,
                style = TextStyle(
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(headerColor),
                ),
            )
            Spacer(GlanceModifier.height(10.dp))

            // ── 최근 기록 3건 ────────────────────────────────
            val rows = buildList {
                if (data.r1Label.isNotEmpty()) add(Triple(data.r1Label, data.r1Detail, data.r1Time))
                if (data.r2Label.isNotEmpty()) add(Triple(data.r2Label, data.r2Detail, data.r2Time))
                if (data.r3Label.isNotEmpty()) add(Triple(data.r3Label, data.r3Detail, data.r3Time))
            }

            if (rows.isEmpty()) {
                Text(
                    "기록을 추가하면 여기에 표시됩니다",
                    style = TextStyle(
                        fontSize = 10.sp,
                        color = ColorProvider(WidgetColors.Gray),
                    ),
                )
            } else {
                RecordRow(rows[0].first, rows[0].second, rows[0].third)
                if (rows.size > 1) {
                    Spacer(GlanceModifier.height(5.dp))
                    RecordRow(rows[1].first, rows[1].second, rows[1].third)
                }
                if (rows.size > 2) {
                    Spacer(GlanceModifier.height(5.dp))
                    RecordRow(rows[2].first, rows[2].second, rows[2].third)
                }
            }
        }
    }
}

@GlanceComposable
@Composable
private fun RecordRow(label: String, detail: String, time: String) {
    Row(
        modifier = GlanceModifier.fillMaxWidth(),
        verticalAlignment = Alignment.Vertical.CenterVertically,
    ) {
        Text(
            label,
            modifier = GlanceModifier.width(46.dp),
            style = TextStyle(
                fontSize = 11.sp,
                color = ColorProvider(WidgetColors.Gray),
            ),
        )
        Text(
            detail,
            modifier = GlanceModifier.defaultWeight(),
            style = TextStyle(
                fontSize = 11.sp,
                fontWeight = FontWeight.Medium,
                color = ColorProvider(Color.Black),
            ),
        )
        Text(
            elapsedLabel(time),
            style = TextStyle(
                fontSize = 10.sp,
                color = ColorProvider(WidgetColors.Gray),
            ),
        )
    }
}

class BebeTapWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = BebeTapWidget()
}
