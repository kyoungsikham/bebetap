import WidgetKit
import SwiftUI

// MARK: - Shared Data Store

private let kAppGroup = "group.com.bebetap.app"

struct BebeTapStore {
    let defaults: UserDefaults?

    init() { defaults = UserDefaults(suiteName: kAppGroup) }

    var babyName: String { defaults?.string(forKey: "widget_baby_name") ?? "" }

    // 아기 목록 — "|" 구분자로 저장된 ids/names
    var babyIds:   [String] { (defaults?.string(forKey: "widget_baby_ids")   ?? "").split(separator: "|").map(String.init).filter { !$0.isEmpty } }
    var babyNames: [String] { (defaults?.string(forKey: "widget_baby_names") ?? "").split(separator: "|").map(String.init).filter { !$0.isEmpty } }
    var babyCount: Int      { max(babyIds.count, 1) }

    var r1Label: String  { defaults?.string(forKey: "r1_label")  ?? "" }
    var r1Detail: String { defaults?.string(forKey: "r1_detail") ?? "" }
    var r1Time: Date?    { isoDate(defaults?.string(forKey: "r1_time")) }

    var r2Label: String  { defaults?.string(forKey: "r2_label")  ?? "" }
    var r2Detail: String { defaults?.string(forKey: "r2_detail") ?? "" }
    var r2Time: Date?    { isoDate(defaults?.string(forKey: "r2_time")) }

    var r3Label: String  { defaults?.string(forKey: "r3_label")  ?? "" }
    var r3Detail: String { defaults?.string(forKey: "r3_detail") ?? "" }
    var r3Time: Date?    { isoDate(defaults?.string(forKey: "r3_time")) }

    // MARK: Today totals
    var todayFormulaMl: Int   { Int(defaults?.string(forKey: "today_formula_ml")   ?? "0") ?? 0 }
    var todayPumpedMl: Int    { Int(defaults?.string(forKey: "today_pumped_ml")    ?? "0") ?? 0 }
    var todayBabyFoodMl: Int  { Int(defaults?.string(forKey: "today_babyfood_ml") ?? "0") ?? 0 }
    var todayBreastSec: Int   { Int(defaults?.string(forKey: "today_breast_sec")  ?? "0") ?? 0 }
    var todayDiaperCount: Int { Int(defaults?.string(forKey: "today_diaper_count") ?? "0") ?? 0 }
    var todaySleepMin: Int    { Int(defaults?.string(forKey: "today_sleep_min")    ?? "0") ?? 0 }

    // MARK: Widget settings
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

private func elapsedShort(from date: Date?) -> String {
    guard let date else { return "" }
    let elapsed = Int(Date().timeIntervalSince(date))
    guard elapsed >= 0 else { return "" }
    let h = elapsed / 3600, m = (elapsed % 3600) / 60
    return h > 0 ? "\(h)시간 \(m)분" : "\(m)분"
}

// "N분 전" / "Nh Nm 전" — 경과시간 짧은 포맷
private func elapsedShortAgo(from date: Date?) -> String {
    let s = elapsedShort(from: date)
    return s.isEmpty ? "" : "\(s) 전"
}

private func actionURL(_ path: String) -> URL {
    URL(string: "bebetap://\(path)")!
}

// MARK: - Entry & Provider

struct BebeTapEntry: TimelineEntry {
    let date: Date
    let store: BebeTapStore
}

struct BebeTapProvider: TimelineProvider {
    func placeholder(in context: Context) -> BebeTapEntry {
        BebeTapEntry(date: Date(), store: BebeTapStore())
    }
    func getSnapshot(in context: Context, completion: @escaping (BebeTapEntry) -> Void) {
        completion(placeholder(in: context))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<BebeTapEntry>) -> Void) {
        let entry = BebeTapEntry(date: Date(), store: BebeTapStore())
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
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

    static func bbForLabel(_ label: String) -> Color {
        switch label {
        case "분유", "이유식": return .bbBlue
        case "모유":           return .bbPurple
        case "유축":           return .bbGreen
        case "수면":           return .bbOrange
        case "기저귀", "체온":  return .bbRed
        default:               return .bbGray
        }
    }
}

// MARK: - Record Row

private struct RecordRow: View {
    let label: String
    let detail: String
    let time: Date?
    var rowOpacity: Double = 1.0

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color.bbForLabel(label))
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
            Text(elapsedShortAgo(from: time))
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

    // 오늘 총량 목록 — 값이 있는 카테고리만
    private var allTotalItems: [(String, String)] {
        var items: [(String, String)] = []
        if store.todayFormulaMl   > 0 { items.append(("분유",   "\(store.todayFormulaMl)ml")) }
        let bH = store.todayBreastSec / 3600, bM = (store.todayBreastSec % 3600) / 60
        if store.todayBreastSec   > 0 { items.append(("모유",   bH > 0 ? "\(bH)h\(bM)m" : "\(bM)분")) }
        if store.todayPumpedMl    > 0 { items.append(("유축",   "\(store.todayPumpedMl)ml")) }
        if store.todayBabyFoodMl  > 0 { items.append(("이유식", "\(store.todayBabyFoodMl)ml")) }
        if store.todayDiaperCount > 0 { items.append(("기저귀", "\(store.todayDiaperCount)회")) }
        let sH = store.todaySleepMin / 60, sM = store.todaySleepMin % 60
        if store.todaySleepMin    > 0 { items.append(("수면",   sH > 0 ? "\(sH)h\(sM)m" : "\(sM)분")) }
        return items
    }

    private var recentRows: [(String, String, Date?)] {
        [(store.r1Label, store.r1Detail, store.r1Time),
         (store.r2Label, store.r2Detail, store.r2Time),
         (store.r3Label, store.r3Detail, store.r3Time)].filter { !$0.0.isEmpty }
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
                    Text(store.babyName.isEmpty ? "기록" : store.babyName)
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
                Text("기록 없음")
                    .font(.system(size: 10))
                    .foregroundColor(.bbGray)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        RecordRow(label: row.0, detail: row.1, time: row.2,
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
                                .fill(Color.bbForLabel(item.0))
                                .frame(width: 5, height: 5)
                            Text("\(item.0) \(item.1)")
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
                    Text(store.babyName.isEmpty ? "기록" : store.babyName)
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
                    Text("기록을 추가하면 여기에 표시됩니다")
                        .font(.system(size: 10))
                        .foregroundColor(.bbGray)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            RecordRow(label: row.0, detail: row.1, time: row.2,
                                      rowOpacity: store.opacity)
                        }
                    }
                }
            }

            Spacer(minLength: 10)

            // 오늘 총량 (값이 있는 카테고리 전부 가로 나열)
            if totals.isEmpty {
                Text("오늘 기록 없음")
                    .font(.system(size: 10))
                    .foregroundColor(.bbGray)
            } else {
                HStack(spacing: 8) {
                    ForEach(Array(totals.enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color.bbForLabel(item.0))
                                .frame(width: 5, height: 5)
                            Text("\(item.0) \(item.1)")
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
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            BebeTapWidgetView(entry: entry)
        }
        .configurationDisplayName("BebeTap")
        .description("최근 기록 3건과 오늘 총량을 표시합니다.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle

@main
struct BebetapWidgetBundle: WidgetBundle {
    var body: some Widget {
        BebeTapWidget()
    }
}
