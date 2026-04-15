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

class PumpedWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val store = BebeTapStore(context)
        provideContent {
            Column(
                modifier = GlanceModifier.fillMaxSize().background(Color.White).padding(12.dp)
                    .clickable(actionStartActivity(
                        Intent(Intent.ACTION_VIEW, actionUri("log/pumped")).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )),
            ) {
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("💧 ", style = TextStyle(fontSize = 10.sp))
                    Text("유축수유", style = TextStyle(fontSize = 10.sp, color = ColorProvider(WidgetColors.Gray), fontWeight = FontWeight.Medium))
                }
                Spacer(GlanceModifier.height(6.dp).defaultWeight())
                Text(
                    elapsedLabel(store.lastPumpedTime),
                    style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ColorProvider(Color.Black)),
                )
                if (store.pumpedTotalMl > 0) {
                    Spacer(GlanceModifier.height(2.dp))
                    Text(
                        "오늘 ${store.pumpedTotalMl}ml",
                        style = TextStyle(fontSize = 11.sp, color = ColorProvider(WidgetColors.Gray)),
                    )
                }
            }
        }
    }
}

class PumpedWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = PumpedWidget()
}
