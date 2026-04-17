import WidgetKit
import SwiftUI

// MARK: - Shared Data Store

private let kAppGroup = "group.com.bebetap.app"

struct BebeTapStore {
    let defaults: UserDefaults?

    init() { defaults = UserDefaults(suiteName: kAppGroup) }

    var lastFeedingLabel: String { defaults?.string(forKey: "lastFeedingLabel") ?? "" }
    var lastFeedingTime: Date?   { isoDate(defaults?.string(forKey: "lastFeedingTime")) }

    var r1Label: String  { defaults?.string(forKey: "r1_label")  ?? "" }
    var r1Detail: String { defaults?.string(forKey: "r1_detail") ?? "" }
    var r1Time: Date?    { isoDate(defaults?.string(forKey: "r1_time")) }

    var r2Label: String  { defaults?.string(forKey: "r2_label")  ?? "" }
    var r2Detail: String { defaults?.string(forKey: "r2_detail") ?? "" }
    var r2Time: Date?    { isoDate(defaults?.string(forKey: "r2_time")) }

    var r3Label: String  { defaults?.string(forKey: "r3_label")  ?? "" }
    var r3Detail: String { defaults?.string(forKey: "r3_detail") ?? "" }
    var r3Time: Date?    { isoDate(defaults?.string(forKey: "r3_time")) }

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

private func elapsedLabel(from date: Date?) -> String {
    guard let date else { return "기록 없음" }
    let elapsed = Int(Date().timeIntervalSince(date))
    let h = elapsed / 3600, m = (elapsed % 3600) / 60
    return h > 0 ? "\(h)시간 \(m)분 전" : "\(m)분 전"
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
    static let bbGray   = Color(red: 0.54, green: 0.54, blue: 0.60)
    static let bbPrimary = Color(red: 0.98, green: 0.47, blue: 0.43)
}

// MARK: - Record Row

private struct RecordRow: View {
    let label: String
    let detail: String
    let time: Date?

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.bbGray)
                .frame(width: 44, alignment: .leading)
            Text(detail)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(elapsedLabel(from: time))
                .font(.system(size: 10))
                .foregroundColor(.bbGray)
        }
    }
}

// MARK: - Widget View

struct BebeTapWidgetView: View {
    let entry: BebeTapEntry

    private var headerText: String {
        let s = entry.store
        let short = elapsedShort(from: s.lastFeedingTime)
        guard !s.lastFeedingLabel.isEmpty, !short.isEmpty else { return "기록 없음" }
        return "\(s.lastFeedingLabel) \(short) 경과"
    }

    private var headerIsEmpty: Bool {
        entry.store.lastFeedingLabel.isEmpty || elapsedShort(from: entry.store.lastFeedingTime).isEmpty
    }

    var body: some View {
        Link(destination: actionURL("log")) {
            VStack(alignment: .leading, spacing: 0) {
                // 앱 이름
                Text("BebeTap")
                    .font(.system(size: 9))
                    .foregroundColor(.bbGray)

                Spacer().frame(height: 4)

                // 마지막 수유 경과
                Text(headerText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(headerIsEmpty ? .bbGray : .primary)
                    .lineLimit(1)

                Spacer().frame(height: 10)

                // 최근 기록 3건
                let s = entry.store
                let rows: [(String, String, Date?)] = [
                    (s.r1Label, s.r1Detail, s.r1Time),
                    (s.r2Label, s.r2Detail, s.r2Time),
                    (s.r3Label, s.r3Detail, s.r3Time),
                ].filter { !$0.0.isEmpty }

                if rows.isEmpty {
                    Text("기록을 추가하면 여기에 표시됩니다")
                        .font(.system(size: 10))
                        .foregroundColor(.bbGray)
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            RecordRow(label: row.0, detail: row.1, time: row.2)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .containerBackground(.background, for: .widget)
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
        .description("최근 기록 3건과 마지막 수유 경과 시간을 표시합니다.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle

@main
struct BebetapWidgetBundle: WidgetBundle {
    var body: some Widget {
        BebeTapWidget()
    }
}
