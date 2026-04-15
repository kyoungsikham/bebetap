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

class BabyFoodStageWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val store = BebeTapStore(context)
        val totalH = store.todaySleepMin / 60
        val totalM = store.todaySleepMin % 60
        provideContent {
            Column(
                modifier = GlanceModifier.fillMaxSize().background(Color.White).padding(12.dp),
            ) {
                Text("BebeTap 이유식기", style = TextStyle(fontSize = 10.sp, color = ColorProvider(WidgetColors.Gray), fontWeight = FontWeight.Medium))
                Spacer(GlanceModifier.height(8.dp))

                // 이유식
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("🍴 이유식  ", style = TextStyle(fontSize = 12.sp, color = ColorProvider(WidgetColors.Gray)))
                    Text(elapsedLabel(store.lastBabyFoodTime), style = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.Bold))
                    if (store.babyFoodTotalMl > 0) Text("  ${store.babyFoodTotalMl}ml", style = TextStyle(fontSize = 11.sp, color = ColorProvider(WidgetColors.Gray)))
                }
                Spacer(GlanceModifier.height(5.dp))

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
                Spacer(GlanceModifier.height(5.dp))

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
                Spacer(GlanceModifier.height(5.dp))

                // 체온
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("🌡️ 체온  ", style = TextStyle(fontSize = 12.sp, color = ColorProvider(WidgetColors.Gray)))
                    if (store.lastTempCelsius > 0f) {
                        Text("%.1f°C".format(store.lastTempCelsius),
                            style = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.Bold,
                                color = ColorProvider(if (store.lastTempCelsius >= 37.5f) WidgetColors.Red else Color.Black)))
                        Text("  ${timeLabel(store.lastTempTime)}", style = TextStyle(fontSize = 10.sp, color = ColorProvider(WidgetColors.Gray)))
                    } else {
                        Text("기록 없음", style = TextStyle(fontSize = 12.sp, color = ColorProvider(WidgetColors.Gray)))
                    }
                }
            }
        }
    }
}

class BabyFoodStageWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = BabyFoodStageWidget()
}
