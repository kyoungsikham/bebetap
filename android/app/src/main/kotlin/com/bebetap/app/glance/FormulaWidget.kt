package com.bebetap.app.glance

import android.content.Context
import androidx.glance.*
import androidx.glance.action.actionStartActivity
import androidx.glance.appwidget.*
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import androidx.glance.background
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class FormulaWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val store = BebeTapStore(context)
        provideContent {
            Column(
                modifier = GlanceModifier.fillMaxSize().background(Color.White).padding(12.dp),
            ) {
                Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                    Text("🍼 ", style = TextStyle(fontSize = 10.sp))
                    Text("분유", style = TextStyle(fontSize = 10.sp, color = ColorProvider(WidgetColors.Gray), fontWeight = FontWeight.Medium))
                }
                Spacer(GlanceModifier.height(6.dp).defaultWeight())
                Text(
                    elapsedLabel(store.lastFormulaTime),
                    style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ColorProvider(Color.Black)),
                )
                if (store.formulaTotalMl > 0) {
                    Spacer(GlanceModifier.height(2.dp))
                    Text(
                        "오늘 ${store.formulaTotalMl}ml",
                        style = TextStyle(fontSize = 11.sp, color = ColorProvider(WidgetColors.Gray)),
                    )
                }
            }
        }
    }
}

class FormulaWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = FormulaWidget()
}
