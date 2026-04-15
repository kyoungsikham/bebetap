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

class EssentialWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val store = BebeTapStore(context)
        val totalH = store.todaySleepMin / 60
        val totalM = store.todaySleepMin % 60
        provideContent {
            Column(
                modifier = GlanceModifier.fillMaxSize().background(Color.White).padding(12.dp),
            ) {
                Text("BebeTap 필수 3종", style = TextStyle(fontSize = 10.sp, color = ColorProvider(WidgetColors.Gray), fontWeight = FontWeight.Medium))
                Spacer(GlanceModifier.height(8.dp))

                // 분유
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("🍼 분유  ", style = TextStyle(fontSize = 12.sp, color = ColorProvider(WidgetColors.Gray)))
                    Text(elapsedLabel(store.lastFormulaTime), style = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.Bold))
                    if (store.formulaTotalMl > 0) Text("  ${store.formulaTotalMl}ml", style = TextStyle(fontSize = 11.sp, color = ColorProvider(WidgetColors.Gray)))
                }
                Spacer(GlanceModifier.height(6.dp))

                // 기저귀
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("🚿 기저귀  ", style = TextStyle(fontSize = 12.sp, color = ColorProvider(WidgetColors.Gray)))
                    Text("오늘 ${store.diaperCountToday}회", style = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.Bold))
                    Spacer(GlanceModifier.width(4.dp))
                    Button("소", actionStartActivity(Intent(Intent.ACTION_VIEW, actionUri("action/diaper/wet")).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Blue.copy(alpha = 0.12f))))
                    Spacer(GlanceModifier.width(2.dp))
                    Button("대", actionStartActivity(Intent(Intent.ACTION_VIEW, actionUri("action/diaper/soiled")).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Orange.copy(alpha = 0.12f))))
                    Spacer(GlanceModifier.width(2.dp))
                    Button("대+소", actionStartActivity(Intent(Intent.ACTION_VIEW, actionUri("action/diaper/both")).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Green.copy(alpha = 0.12f))))
                }
                Spacer(GlanceModifier.height(6.dp))

                // 수면
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("🌙 수면  ", style = TextStyle(fontSize = 12.sp, color = ColorProvider(WidgetColors.Gray)))
                    if (store.sleepActive) {
                        Text(activeLabel(store.sleepStartTime), style = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.Bold, color = ColorProvider(WidgetColors.Purple)))
                        Spacer(GlanceModifier.width(4.dp))
                        Button("종료", actionStartActivity(Intent(Intent.ACTION_VIEW, actionUri("action/sleep/end")).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }),
                            colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Purple.copy(alpha = 0.12f))))
                    } else {
                        Text("${totalH}h ${totalM}m", style = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.Bold))
                        Spacer(GlanceModifier.width(4.dp))
                        Button("시작", actionStartActivity(Intent(Intent.ACTION_VIEW, actionUri("action/sleep/start")).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }),
                            colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Purple.copy(alpha = 0.12f))))
                    }
                }
            }
        }
    }
}

class EssentialWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = EssentialWidget()
}
