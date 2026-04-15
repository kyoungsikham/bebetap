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

class BreastWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val store = BebeTapStore(context)
        provideContent {
            Column(
                modifier = GlanceModifier.fillMaxSize().background(Color.White).padding(12.dp),
            ) {
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("❤️ ", style = TextStyle(fontSize = 10.sp))
                    Text("모유", style = TextStyle(fontSize = 10.sp, color = ColorProvider(WidgetColors.Gray), fontWeight = FontWeight.Medium))
                }
                Spacer(GlanceModifier.height(6.dp).defaultWeight())
                Text(
                    elapsedLabel(store.lastBreastTime),
                    style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ColorProvider(Color.Black)),
                )
                Spacer(GlanceModifier.height(6.dp))
                Row(horizontalAlignment = Alignment.Horizontal.Start) {
                    Button(
                        text = "왼쪽",
                        onClick = actionStartActivity(
                            Intent(Intent.ACTION_VIEW, actionUri("log/breast")).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        ),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Red.copy(alpha = 0.12f))),
                    )
                    Spacer(GlanceModifier.width(4.dp))
                    Button(
                        text = "오른쪽",
                        onClick = actionStartActivity(
                            Intent(Intent.ACTION_VIEW, actionUri("log/breast")).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        ),
                        colors = ButtonDefaults.buttonColors(backgroundColor = ColorProvider(WidgetColors.Red.copy(alpha = 0.12f))),
                    )
                }
            }
        }
    }
}

class BreastWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = BreastWidget()
}
