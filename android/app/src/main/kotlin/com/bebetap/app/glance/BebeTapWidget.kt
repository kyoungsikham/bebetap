package com.bebetap.app.glance

import android.content.Context
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import java.time.Instant
import java.time.temporal.ChronoUnit

class BebeTapWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        val lastFeedingTime = prefs.getString("lastFeedingTime", "") ?: ""
        val formulaTotalMl = prefs.getInt("formulaTotalMl", 0)
        val isSleeping = prefs.getBoolean("sleepActive", false)
        val sleepStartTime = prefs.getString("sleepStartTime", "") ?: ""

        val lastFeedingLabel = if (lastFeedingTime.isNotEmpty()) {
            try {
                val feedingInstant = Instant.parse(lastFeedingTime)
                val minutesAgo = ChronoUnit.MINUTES.between(feedingInstant, Instant.now())
                if (minutesAgo < 60) "${minutesAgo}분 전"
                else "${minutesAgo / 60}시간 ${minutesAgo % 60}분 전"
            } catch (e: Exception) { "기록 없음" }
        } else "기록 없음"

        val sleepElapsedLabel = if (isSleeping && sleepStartTime.isNotEmpty()) {
            try {
                val startInstant = Instant.parse(sleepStartTime)
                val minutesAgo = ChronoUnit.MINUTES.between(startInstant, Instant.now())
                if (minutesAgo < 60) "${minutesAgo}분" else "${minutesAgo / 60}시간 ${minutesAgo % 60}분"
            } catch (e: Exception) { "" }
        } else ""

        provideContent {
            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(ColorProvider(Color.White))
                    .padding(12.dp),
                verticalAlignment = Alignment.Vertical.Top,
            ) {
                Text(
                    text = "BebeTap",
                    style = TextStyle(
                        fontSize = 10.sp,
                        color = ColorProvider(Color(0xFF8A8A9A)),
                        fontWeight = FontWeight.Medium,
                    ),
                )
                Spacer(modifier = GlanceModifier.height(8.dp))

                if (isSleeping) {
                    Text(
                        text = "🌙 ${sleepElapsedLabel.ifEmpty { "수면 중" }}",
                        style = TextStyle(
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = ColorProvider(Color(0xFF7B68EE)),
                        ),
                    )
                } else {
                    Text(
                        text = "🍼 $lastFeedingLabel",
                        style = TextStyle(
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = ColorProvider(Color(0xFF1A1A2E)),
                        ),
                    )
                }

                if (formulaTotalMl > 0) {
                    Spacer(modifier = GlanceModifier.height(4.dp))
                    Text(
                        text = "분유 ${formulaTotalMl}ml",
                        style = TextStyle(
                            fontSize = 12.sp,
                            color = ColorProvider(Color(0xFF8A8A9A)),
                        ),
                    )
                }
            }
        }
    }
}

class BebeTapWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = BebeTapWidget()
}
