package com.bebetap.app.glance

import androidx.compose.ui.graphics.Color

object WidgetColors {
    val Blue   = Color(0xFF5C80FF)
    val Purple = Color(0xFF7B68EE)
    val Green  = Color(0xFF40B88C)
    val Orange = Color(0xFFFF9933)
    val Red    = Color(0xFFF25858)
    val Gray   = Color(0xFF8A8A9A)
    val BgCard = Color(0xFFF5F5F5)

    // 다크모드용 색상
    val BackgroundLight = Color.White
    val BackgroundDark  = Color(0xFF1C1C1E)
    val TextLight       = Color.Black
    val TextDark        = Color(0xFFF2F2F7)
    val GrayDark        = Color(0xFF8E8E93)

    fun colorForLabel(label: String): Color = when (label) {
        "분유", "이유식" -> Blue
        "모유"          -> Purple
        "유축"          -> Green
        "수면"          -> Orange
        "기저귀", "체온" -> Red
        else            -> Gray
    }
}
