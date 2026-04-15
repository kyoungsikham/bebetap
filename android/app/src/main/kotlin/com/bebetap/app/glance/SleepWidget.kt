package com.bebetap.app.glance

import android.content.Context
import android.content.Intent
import androidx.glance.*
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.*
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import androidx.glance.background
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class SleepWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val store = BebeTapStore(context)
        val totalH = store.todaySleepMin / 60
        val totalM = store.todaySleepMin % 60
        provideContent {
            Column(
                modifier = GlanceModifier.fillMaxSize().background(Color.White).padding(12.dp),
            ) {
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("🌙 ", style = TextStyle(fontSize = 10.sp))
                    Text("수면", style = TextStyle(fontSize = 10.sp, color = ColorProvider(WidgetColors.Gray), fontWeight = FontWeight.Medium))
                }
                Spacer(GlanceModifier.height(4.dp).defaultWeight())
                if (store.sleepActive) {
                    Text(
                        activeLabel(store.sleepStartTime),
                        style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ColorProvider(WidgetColors.Purple)),
                    )
                    Spacer(GlanceModifier.height(6.dp))
                    Button(
                        text = "종료",
                        onClick = actionStartActivity(
                            Intent(Intent.ACTION_VIEW, actionUri("action/sleep/end")).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        ),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Purple.copy(alpha = 0.12f))),
                    )
                } else {
                    Text(
                        "${totalH}시간 ${totalM}분",
                        style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ColorProvider(Color.Black)),
                    )
                    Spacer(GlanceModifier.height(6.dp))
                    Button(
                        text = "시작",
                        onClick = actionStartActivity(
                            Intent(Intent.ACTION_VIEW, actionUri("action/sleep/start")).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        ),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Purple.copy(alpha = 0.12f))),
                    )
                }
            }
        }
    }
}

class SleepWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = SleepWidget()
}
