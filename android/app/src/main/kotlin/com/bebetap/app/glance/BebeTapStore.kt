package com.bebetap.app.glance

import android.content.Context
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit

/** SharedPreferences에서 위젯 데이터를 읽는 공통 저장소 */
class BebeTapStore(context: Context) {
    private val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

    // 수유
    val lastFormulaTime: String  get() = prefs.getString("lastFormulaTime", "") ?: ""
    val formulaTotalMl: Int      get() = prefs.getInt("formulaTotalMl", 0)
    val lastBreastTime: String   get() = prefs.getString("lastBreastTime", "") ?: ""
    val lastPumpedTime: String   get() = prefs.getString("lastPumpedTime", "") ?: ""
    val pumpedTotalMl: Int       get() = prefs.getInt("pumpedTotalMl", 0)
    val lastBabyFoodTime: String get() = prefs.getString("lastBabyFoodTime", "") ?: ""
    val babyFoodTotalMl: Int     get() = prefs.getInt("babyFoodTotalMl", 0)
    // 기저귀
    val diaperCountToday: Int    get() = prefs.getInt("diaperCountToday", 0)
    val lastDiaperType: String   get() = prefs.getString("lastDiaperType", "") ?: ""
    // 수면
    val sleepActive: Boolean     get() = prefs.getBoolean("sleepActive", false)
    val sleepStartTime: String   get() = prefs.getString("sleepStartTime", "") ?: ""
    val todaySleepMin: Int       get() = prefs.getInt("todaySleepMin", 0)
    // 체온
    val lastTempCelsius: Float   get() = prefs.getFloat("lastTempCelsius", 0f)
    val lastTempTime: String     get() = prefs.getString("lastTempTime", "") ?: ""
}

/** ISO8601 문자열 → 경과 시간 레이블 */
fun elapsedLabel(iso: String, default_: String = "기록 없음"): String {
    if (iso.isEmpty()) return default_
    return try {
        val instant = Instant.parse(iso)
        val minutes = ChronoUnit.MINUTES.between(instant, Instant.now())
        if (minutes < 60) "${minutes}분 전" else "${minutes / 60}시간 ${minutes % 60}분 전"
    } catch (e: Exception) { default_ }
}

/** ISO8601 문자열 → 활성 경과 레이블 (수면 중) */
fun activeLabel(iso: String, default_: String = "수면 중"): String {
    if (iso.isEmpty()) return default_
    return try {
        val instant = Instant.parse(iso)
        val minutes = ChronoUnit.MINUTES.between(instant, Instant.now())
        if (minutes < 60) "${minutes}분" else "${minutes / 60}시간 ${minutes % 60}분"
    } catch (e: Exception) { default_ }
}

/** ISO8601 문자열 → HH:mm 표시 */
fun timeLabel(iso: String): String {
    if (iso.isEmpty()) return "--:--"
    return try {
        val instant = Instant.parse(iso)
        val fmt = DateTimeFormatter.ofPattern("HH:mm").withZone(ZoneId.systemDefault())
        fmt.format(instant)
    } catch (e: Exception) { "--:--" }
}

/** 위젯 딥링크 URI */
fun actionUri(path: String) = android.net.Uri.parse("bebetap://$path")
