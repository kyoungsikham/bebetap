package com.bebetap.app.glance

import androidx.compose.ui.graphics.Color

object WidgetColors {
    // 원색 팔레트 — dot/텍스트용
    val Blue   = Color(0xFF5C80FF)
    val Purple = Color(0xFF7B68EE)
    val Green  = Color(0xFF40B88C)
    val Orange = Color(0xFFFF9933)
    val Red    = Color(0xFFF25858)
    val Gray   = Color(0xFF8A8A9A)

    // 배경 색상
    val BackgroundLight = Color.White
    val BackgroundDark  = Color(0xFF1C1C1E)
    val TextLight       = Color.Black
    val TextDark        = Color(0xFFF2F2F7)
    val GrayDark        = Color(0xFF8E8E93)

    // 파스텔 버튼 배경 — 라이트 모드
    val BtnBgBlueLight   = Color(0xFFE3EAFF)
    val BtnBgPurpleLight = Color(0xFFE8E3FB)
    val BtnBgGreenLight  = Color(0xFFDFF1EA)
    val BtnBgOrangeLight = Color(0xFFFFE8CE)
    val BtnBgRedLight    = Color(0xFFFCE0E0)
    val BtnBgGrayLight   = Color(0xFFE8E8EC)

    // 파스텔 버튼 배경 — 다크 모드
    val BtnBgBlueDark   = Color(0xFF2A3560)
    val BtnBgPurpleDark = Color(0xFF2E2A52)
    val BtnBgGreenDark  = Color(0xFF1C3D32)
    val BtnBgOrangeDark = Color(0xFF3D2E10)
    val BtnBgRedDark    = Color(0xFF3D1A1A)
    val BtnBgGrayDark   = Color(0xFF2A2A30)

    fun colorForLabel(label: String): Color = when (label) {
        "분유", "이유식" -> Blue
        "모유"          -> Purple
        "유축"          -> Green
        "수면"          -> Orange
        "기저귀", "체온" -> Red
        else            -> Gray
    }

    data class ButtonSpec(
        val label: String,
        val color: Color,
        val bgLight: Color,
        val bgDark: Color,
        val uri: String,
    )

    fun buttonSpecFor(token: String, isDark: Boolean = false): ButtonSpec? = when (token) {
        "formula"     -> ButtonSpec("분유",   Blue,   BtnBgBlueLight,   BtnBgBlueDark,   "bebetap://action/feeding/formula")
        "breast"      -> ButtonSpec("모유",   Purple, BtnBgPurpleLight, BtnBgPurpleDark, "bebetap://action/feeding/breast")
        "pumped"      -> ButtonSpec("유축",   Green,  BtnBgGreenLight,  BtnBgGreenDark,  "bebetap://action/feeding/pumped")
        "babyFood"    -> ButtonSpec("이유식", Blue,   BtnBgBlueLight,   BtnBgBlueDark,   "bebetap://action/feeding/babyFood")
        "sleep"       -> ButtonSpec("수면",   Orange, BtnBgOrangeLight, BtnBgOrangeDark, "bebetap://action/sleep/toggle")
        "diaper"      -> ButtonSpec("기저귀", Red,    BtnBgRedLight,    BtnBgRedDark,    "bebetap://action/diaper/wet")
        "temperature" -> ButtonSpec("체온",   Red,    BtnBgRedLight,    BtnBgRedDark,    "bebetap://log/temperature")
        "diary"       -> ButtonSpec("일기",   Gray,   BtnBgGrayLight,   BtnBgGrayDark,   "bebetap://log/diary")
        else          -> null
    }
}
