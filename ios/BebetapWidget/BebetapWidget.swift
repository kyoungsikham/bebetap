import WidgetKit
import SwiftUI

// MARK: - Shared Data Store

private let kAppGroup = "group.com.bebetap.app"

struct BebeTapStore {
    let defaults: UserDefaults?
    let pinnedBabyId: String?

    init(pinnedBabyId: String? = nil) {
        defaults = UserDefaults(suiteName: kAppGroup)
        self.pinnedBabyId = pinnedBabyId
    }

    // pinnedBabyId 접미사 키 우선, 없으면 전역 키 fallback
    private func str(_ key: String, fallback: String = "") -> String {
        if let id = pinnedBabyId,
           let v = defaults?.string(forKey: "\(key)_\(id)"), !v.isEmpty {
            return v
        }
        return defaults?.string(forKey: key) ?? fallback
    }

    // 아기 목록 — "|" 구분자로 저장된 ids/names
    var babyIds:   [String] { (defaults?.string(forKey: "widget_baby_ids")   ?? "").split(separator: "|").map(String.init).filter { !$0.isEmpty } }
    var babyNames: [String] { (defaults?.string(forKey: "widget_baby_names") ?? "").split(separator: "|").map(String.init).filter { !$0.isEmpty } }
    var babyCount: Int      { pinnedBabyId != nil ? 1 : max(babyIds.count, 1) }

    var babyName: String {
        if let id = pinnedBabyId, let idx = babyIds.firstIndex(of: id), babyNames.indices.contains(idx) {
            return babyNames[idx]
        }
        return defaults?.string(forKey: "widget_baby_name") ?? ""
    }

    var r1Label: String  { str("r1_label") }
    var r1Detail: String { str("r1_detail") }
    var r1Time: Date?    { isoDate(str("r1_time")) }
    var r1Color: String  { str("r1_color") }

    var r2Label: String  { str("r2_label") }
    var r2Detail: String { str("r2_detail") }
    var r2Time: Date?    { isoDate(str("r2_time")) }
    var r2Color: String  { str("r2_color") }

    var r3Label: String  { str("r3_label") }
    var r3Detail: String { str("r3_detail") }
    var r3Time: Date?    { isoDate(str("r3_time")) }
    var r3Color: String  { str("r3_color") }

    // MARK: Today totals (per-baby 접미사 지원)
    var todayFormulaMl: Int   { Int(str("today_formula_ml",   fallback: "0")) ?? 0 }
    var todayPumpedMl: Int    { Int(str("today_pumped_ml",    fallback: "0")) ?? 0 }
    var todayBabyFoodMl: Int  { Int(str("today_babyfood_ml", fallback: "0")) ?? 0 }
    var todayBreastSec: Int   { Int(str("today_breast_sec",  fallback: "0")) ?? 0 }
    var todayDiaperCount: Int { Int(str("today_diaper_count",fallback: "0")) ?? 0 }
    var todaySleepMin: Int    { Int(str("today_sleep_min",   fallback: "0")) ?? 0 }
    // MARK: Today totals — 번역된 라벨 + 포맷된 값 (라벨은 전역, 값은 per-baby)
    var todayFormulaLabel: String  { defaults?.string(forKey: "today_formula_label")  ?? "분유" }
    var todayBreastLabel: String   { defaults?.string(forKey: "today_breast_label")   ?? "모유" }
    var todayPumpedLabel: String   { defaults?.string(forKey: "today_pumped_label")   ?? "유축" }
    var todayBabyFoodLabel: String { defaults?.string(forKey: "today_babyfood_label") ?? "이유식" }
    var todayDiaperLabel: String   { defaults?.string(forKey: "today_diaper_label")   ?? "기저귀" }
    var todaySleepLabel: String    { defaults?.string(forKey: "today_sleep_label")    ?? "수면" }
    var todayBreastValue: String   { str("today_breast_value") }
    var todaySleepValue: String    { str("today_sleep_value") }
    var todayDiaperValue: String   { str("today_diaper_value") }

    // MARK: 다국어 정적 텍스트 (전역)
    var emptyShort: String    { defaults?.string(forKey: "widget_empty_short")    ?? "기록 없음" }
    var emptyToday: String    { defaults?.string(forKey: "widget_empty_today")    ?? "오늘 기록 없음" }
    var emptyHint: String     { defaults?.string(forKey: "widget_empty_hint")     ?? "기록을 추가하면 여기에 표시됩니다" }
    var titleFallback: String { defaults?.string(forKey: "widget_title_fallback") ?? "기록" }
    var unitMin: String       { defaults?.string(forKey: "widget_unit_min")       ?? "분" }
    var agoSuffix: String     { defaults?.string(forKey: "widget_ago_suffix")     ?? " 전" }

    // MARK: Widget settings (전역)
    var themeMode: String { defaults?.string(forKey: "widget_theme") ?? "system" }
    var opacity: Double   { Double(defaults?.string(forKey: "widget_opacity") ?? "1.00") ?? 1.0 }

    private func isoDate(_ str: String?) -> Date? {
        guard let str, !str.isEmpty else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: str) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: str) { return d }
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                    "yyyy-MM-dd'T'HH:mm:ss.SSS",
                    "yyyy-MM-dd'T'HH:mm:ss"] {
            df.dateFormat = fmt
            if let d = df.date(from: str) { return d }
        }
        return nil
    }
}

// MARK: - Helpers

private func elapsedShort(from date: Date?, unitMin: String = "분") -> String {
    guard let date else { return "" }
    let elapsed = Int(Date().timeIntervalSince(date))
    guard elapsed >= 0 else { return "" }
    let h = elapsed / 3600, m = (elapsed % 3600) / 60
    return h > 0 ? "\(h)h\(m)\(unitMin)" : "\(m)\(unitMin)"
}

// 경과시간 "N분 전" / "Nh Nm 전" — unitMin/agoSuffix로 다국어 처리
private func elapsedShortAgo(from date: Date?, unitMin: String = "분", agoSuffix: String = " 전") -> String {
    let s = elapsedShort(from: date, unitMin: unitMin)
    return s.isEmpty ? "" : "\(s)\(agoSuffix)"
}

private func actionURL(_ path: String) -> URL {
    URL(string: "bebetap://\(path)")!
}

// MARK: - Entry & Provider

struct BebeTapEntry: TimelineEntry {
    let date: Date
    let store: BebeTapStore
    let configuration: BabySelectionIntent
}

struct BebeTapProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> BebeTapEntry {
        let cfg = BabySelectionIntent()
        return BebeTapEntry(date: Date(),
                            store: BebeTapStore(pinnedBabyId: _resolvedBabyId(cfg)),
                            configuration: cfg)
    }
    func snapshot(for configuration: BabySelectionIntent, in context: Context) async -> BebeTapEntry {
        BebeTapEntry(date: Date(),
                     store: BebeTapStore(pinnedBabyId: _resolvedBabyId(configuration)),
                     configuration: configuration)
    }
    func timeline(for configuration: BabySelectionIntent, in context: Context) async -> Timeline<BebeTapEntry> {
        let store = BebeTapStore(pinnedBabyId: _resolvedBabyId(configuration))
        let entry = BebeTapEntry(date: Date(), store: store, configuration: configuration)
        let next  = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        return Timeline(entries: [entry], policy: .after(next))
    }

    // 사용자가 아기를 선택하지 않은 위젯은 첫 번째 등록 아기로 fallback
    private func _resolvedBabyId(_ configuration: BabySelectionIntent) -> String? {
        if let id = configuration.baby?.id { return id }
        let d = UserDefaults(suiteName: kAppGroup)
        let ids = (d?.string(forKey: "widget_baby_ids") ?? "")
            .split(separator: "|").map(String.init).filter { !$0.isEmpty }
        return ids.first
    }
}

// MARK: - Colors

private extension Color {
    static let bbGray   = Color(red: 0.54,  green: 0.54,  blue: 0.60)
    static let bbBlue   = Color(red: 0.361, green: 0.502, blue: 1.0)
    static let bbPurple = Color(red: 0.482, green: 0.408, blue: 0.933)
    static let bbGreen  = Color(red: 0.251, green: 0.722, blue: 0.549)
    static let bbOrange = Color(red: 1.0,   green: 0.6,   blue: 0.2)
    static let bbRed    = Color(red: 0.949, green: 0.345, blue: 0.345)

    static func bbForCategory(_ category: String) -> Color {
        switch category {
        case "formula", "babyFood": return .bbBlue
        case "breast":              return .bbPurple
        case "pumped":              return .bbGreen
        case "sleep":               return .bbOrange
        case "diaper", "temperature": return .bbRed
        default:                    return .bbGray
        }
    }
}

// MARK: - Record Row

private struct RecordRow: View {
    let label: String
    let detail: String
    let time: Date?
    let colorCategory: String
    var unitMin: String = "분"
    var agoSuffix: String = " 전"
    var rowOpacity: Double = 1.0

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color.bbForCategory(colorCategory))
                .frame(width: 8, height: 8)
            Spacer().frame(width: 5)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.bbGray)
                .frame(width: 36, alignment: .leading)
            Text(detail)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(elapsedShortAgo(from: time, unitMin: unitMin, agoSuffix: agoSuffix))
                .font(.system(size: 10))
                .foregroundColor(.bbGray)
                .lineLimit(1)
                .fixedSize()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.gray.opacity(0.08 * rowOpacity))
        .cornerRadius(8)
    }
}

// MARK: - ConditionalColorScheme

private struct ConditionalColorScheme: ViewModifier {
    let scheme: ColorScheme?
    func body(content: Content) -> some View {
        if let scheme {
            content.environment(\.colorScheme, scheme)
        } else {
            content
        }
    }
}

// MARK: - Widget View

struct BebeTapWidgetView: View {
    let entry: BebeTapEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var systemColorScheme

    private var store: BebeTapStore { entry.store }

    private var resolvedColorScheme: ColorScheme? {
        switch store.themeMode {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    private var isDark: Bool {
        switch store.themeMode {
        case "dark":  return true
        case "light": return false
        default:      return systemColorScheme == .dark
        }
    }

    // 오늘 총량 목록 — (category, label, value) — 번역된 라벨+값은 Dart에서 push
    private var allTotalItems: [(String, String, String)] {
        var items: [(String, String, String)] = []
        if store.todayFormulaMl   > 0 { items.append(("formula",  store.todayFormulaLabel,  "\(store.todayFormulaMl)ml")) }
        if store.todayBreastSec   > 0, !store.todayBreastValue.isEmpty {
            items.append(("breast",   store.todayBreastLabel,  store.todayBreastValue)) }
        if store.todayPumpedMl    > 0 { items.append(("pumped",   store.todayPumpedLabel,   "\(store.todayPumpedMl)ml")) }
        if store.todayBabyFoodMl  > 0 { items.append(("babyFood", store.todayBabyFoodLabel, "\(store.todayBabyFoodMl)ml")) }
        if store.todayDiaperCount > 0, !store.todayDiaperValue.isEmpty {
            items.append(("diaper",   store.todayDiaperLabel,  store.todayDiaperValue)) }
        if store.todaySleepMin    > 0, !store.todaySleepValue.isEmpty {
            items.append(("sleep",    store.todaySleepLabel,   store.todaySleepValue)) }
        return items
    }

    private var recentRows: [(String, String, Date?, String)] {
        [(store.r1Label, store.r1Detail, store.r1Time, store.r1Color),
         (store.r2Label, store.r2Detail, store.r2Time, store.r2Color),
         (store.r3Label, store.r3Detail, store.r3Time, store.r3Color)].filter { !$0.0.isEmpty }
    }

    var body: some View {
        if family == .systemSmall {
            smallBody
        } else {
            mediumLargeBody
        }
    }

    // MARK: 2×2 소형 위젯
    @ViewBuilder
    private var smallBody: some View {
        let rows = recentRows
        let totals = allTotalItems
        let multiBaby = store.babyCount > 1

        VStack(alignment: .leading, spacing: 0) {
            // 헤더: [◂] 아기이름 [▸]  (새로고침 제거 — Timeline 자동 갱신)
            HStack(alignment: .center, spacing: 2) {
                if multiBaby {
                    Link(destination: actionURL("action/baby/prev")) {
                        Text("◂").font(.system(size: 11)).foregroundColor(.bbGray)
                            .frame(width: 18, height: 18)
                    }
                }
                Link(destination: actionURL("home")) {
                    Text(store.babyName.isEmpty ? store.titleFallback : store.babyName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                if multiBaby {
                    Link(destination: actionURL("action/baby/next")) {
                        Text("▸").font(.system(size: 11)).foregroundColor(.bbGray)
                            .frame(width: 18, height: 18)
                    }
                }
                Spacer()
            }

            Spacer().frame(height: 5)

            // 최근 기록 3건
            if rows.isEmpty {
                Text(store.emptyShort)
                    .font(.system(size: 10))
                    .foregroundColor(.bbGray)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        RecordRow(label: row.0, detail: row.1, time: row.2,
                                  colorCategory: row.3,
                                  unitMin: store.unitMin, agoSuffix: store.agoSuffix,
                                  rowOpacity: store.opacity)
                    }
                }
            }

            Spacer(minLength: 4)

            // 총량 1줄 (2x2 공간 제한: 최대 2개)
            if !totals.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(totals.prefix(2).enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 2) {
                            Circle()
                                .fill(Color.bbForCategory(item.0))
                                .frame(width: 5, height: 5)
                            Text("\(item.1) \(item.2)")
                                .font(.system(size: 9))
                                .foregroundColor(.bbGray)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .modifier(ConditionalColorScheme(scheme: resolvedColorScheme))
        .widgetURL(actionURL("home"))
        .containerBackground(for: .widget) {
            isDark ? Color.clear : Color.white.opacity(store.opacity)
        }
    }

    // MARK: 4×2 중형 위젯
    @ViewBuilder
    private var mediumLargeBody: some View {
        let rows = recentRows
        let totals = allTotalItems
        let multiBaby = store.babyCount > 1

        VStack(alignment: .leading, spacing: 0) {
            // 헤더: [◂] 아기이름 [▸]  (새로고침 제거 — Timeline 자동 갱신)
            HStack(alignment: .center, spacing: 2) {
                if multiBaby {
                    Link(destination: actionURL("action/baby/prev")) {
                        Text("◂").font(.system(size: 13)).foregroundColor(.bbGray)
                            .frame(width: 22, height: 22)
                    }
                }
                Link(destination: actionURL("home")) {
                    Text(store.babyName.isEmpty ? store.titleFallback : store.babyName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                if multiBaby {
                    Link(destination: actionURL("action/baby/next")) {
                        Text("▸").font(.system(size: 13)).foregroundColor(.bbGray)
                            .frame(width: 22, height: 22)
                    }
                }
                Spacer()
            }

            Spacer().frame(height: 8)

            // 최근 기록 3건
            Link(destination: actionURL("home")) {
                if rows.isEmpty {
                    Text(store.emptyHint)
                        .font(.system(size: 10))
                        .foregroundColor(.bbGray)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            RecordRow(label: row.0, detail: row.1, time: row.2,
                                      colorCategory: row.3,
                                      unitMin: store.unitMin, agoSuffix: store.agoSuffix,
                                      rowOpacity: store.opacity)
                        }
                    }
                }
            }

            Spacer(minLength: 10)

            // 오늘 총량 (값이 있는 카테고리 전부 가로 나열)
            if totals.isEmpty {
                Text(store.emptyToday)
                    .font(.system(size: 10))
                    .foregroundColor(.bbGray)
            } else {
                HStack(spacing: 8) {
                    ForEach(Array(totals.enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color.bbForCategory(item.0))
                                .frame(width: 5, height: 5)
                            Text("\(item.1) \(item.2)")
                                .font(.system(size: 10))
                                .foregroundColor(.bbGray)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .modifier(ConditionalColorScheme(scheme: resolvedColorScheme))
        .containerBackground(for: .widget) {
            isDark ? Color.clear : Color.white.opacity(store.opacity)
        }
    }
}

// MARK: - Widget

struct BebeTapWidget: Widget {
    let kind = "BebeTapWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: BabySelectionIntent.self, provider: BebeTapProvider()) { entry in
            BebeTapWidgetView(entry: entry)
        }
        .configurationDisplayName("BebeTap")
        .description("최근 기록 3건과 오늘 총량을 표시합니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Bundle

@main
struct BebetapWidgetBundle: WidgetBundle {
    var body: some Widget {
        BebeTapWidget()
    }
}
