package com.bebetap.app.glance

import android.content.Context
import android.content.Intent
import androidx.glance.*
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.*
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import androidx.glance.background
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class TemperatureWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val store = BebeTapStore(context)
        val isFever = store.lastTempCelsius >= 37.5f
        provideContent {
            Column(
                modifier = GlanceModifier.fillMaxSize().background(Color.White).padding(12.dp)
                    .clickable(actionStartActivity(
                        Intent(Intent.ACTION_VIEW, actionUri("log/temperature")).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )),
            ) {
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("🌡️ ", style = TextStyle(fontSize = 10.sp))
                    Text("체온", style = TextStyle(fontSize = 10.sp, color = ColorProvider(WidgetColors.Gray), fontWeight = FontWeight.Medium))
                }
                Spacer(GlanceModifier.height(6.dp).defaultWeight())
                if (store.lastTempCelsius > 0f) {
                    Text(
                        "%.1f°C".format(store.lastTempCelsius),
                        style = TextStyle(
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = ColorProvider(if (isFever) WidgetColors.Red else Color.Black),
                        ),
                    )
                    Text(
                        timeLabel(store.lastTempTime),
                        style = TextStyle(fontSize = 11.sp, color = ColorProvider(WidgetColors.Gray)),
                    )
                } else {
                    Text("기록 없음", style = TextStyle(fontSize = 13.sp, color = ColorProvider(WidgetColors.Gray)))
                }
            }
        }
    }
}

class TemperatureWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = TemperatureWidget()
}
