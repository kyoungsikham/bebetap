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

class DiaperWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val store = BebeTapStore(context)
        provideContent {
            Column(
                modifier = GlanceModifier.fillMaxSize().background(Color.White).padding(12.dp),
            ) {
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("🚿 ", style = TextStyle(fontSize = 10.sp))
                    Text("기저귀", style = TextStyle(fontSize = 10.sp, color = ColorProvider(WidgetColors.Gray), fontWeight = FontWeight.Medium))
                }
                Spacer(GlanceModifier.height(4.dp).defaultWeight())
                Text(
                    "오늘 ${store.diaperCountToday}회",
                    style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ColorProvider(Color.Black)),
                )
                Spacer(GlanceModifier.height(6.dp))
                Row(horizontalAlignment = Alignment.Horizontal.Start) {
                    Button(
                        text = "소변",
                        onClick = actionStartActivity(
                            Intent(Intent.ACTION_VIEW, actionUri("action/diaper/wet")).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        ),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Blue.copy(alpha = 0.15f))),
                    )
                    Spacer(GlanceModifier.width(3.dp))
                    Button(
                        text = "대변",
                        onClick = actionStartActivity(
                            Intent(Intent.ACTION_VIEW, actionUri("action/diaper/soiled")).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        ),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Orange.copy(alpha = 0.15f))),
                    )
                    Spacer(GlanceModifier.width(3.dp))
                    Button(
                        text = "대+소",
                        onClick = actionStartActivity(
                            Intent(Intent.ACTION_VIEW, actionUri("action/diaper/both")).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        ),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Green.copy(alpha = 0.15f))),
                    )
                }
            }
        }
    }
}

class DiaperWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = DiaperWidget()
}
