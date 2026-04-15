import WidgetKit
import SwiftUI

// MARK: - Shared Data Store

private let kAppGroup = "group.com.bebetap.app"

struct BebeTapStore {
    let defaults: UserDefaults?

    init() { defaults = UserDefaults(suiteName: kAppGroup) }

    // 수유
    var lastFormulaTime: Date?   { isoDate(defaults?.string(forKey: "lastFormulaTime")) }
    var formulaTotalMl: Int      { defaults?.integer(forKey: "formulaTotalMl") ?? 0 }
    var lastBreastTime: Date?    { isoDate(defaults?.string(forKey: "lastBreastTime")) }
    var lastPumpedTime: Date?    { isoDate(defaults?.string(forKey: "lastPumpedTime")) }
    var pumpedTotalMl: Int       { defaults?.integer(forKey: "pumpedTotalMl") ?? 0 }
    var lastBabyFoodTime: Date?  { isoDate(defaults?.string(forKey: "lastBabyFoodTime")) }
    var babyFoodTotalMl: Int     { defaults?.integer(forKey: "babyFoodTotalMl") ?? 0 }
    // 기저귀
    var diaperCountToday: Int    { defaults?.integer(forKey: "diaperCountToday") ?? 0 }
    var lastDiaperType: String   { defaults?.string(forKey: "lastDiaperType") ?? "" }
    // 수면
    var sleepActive: Bool        { defaults?.bool(forKey: "sleepActive") ?? false }
    var sleepStartTime: Date?    { isoDate(defaults?.string(forKey: "sleepStartTime")) }
    var todaySleepMin: Int       { defaults?.integer(forKey: "todaySleepMin") ?? 0 }
    // 체온
    var lastTempCelsius: Double  { defaults?.double(forKey: "lastTempCelsius") ?? 0 }
    var lastTempTime: Date?      { isoDate(defaults?.string(forKey: "lastTempTime")) }

    private func isoDate(_ str: String?) -> Date? {
        guard let str, !str.isEmpty else { return nil }
        // 1. UTC / offset 포함 + 마이크로초 (e.g. 2024-04-14T03:00:00.123456Z)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: str) { return d }
        // 2. UTC / offset 포함, 초까지 (e.g. 2024-04-14T03:00:00Z)
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: str) { return d }
        // 3. 타임존 없음 – Dart DateTime.now().toIso8601String() 형식
        //    e.g. 2024-04-14T12:00:00.123456
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

// MARK: - Elapsed Label Helper

private func elapsedLabel(from date: Date?, default text: String = "기록 없음") -> String {
    guard let date else { return text }
    let elapsed = Int(Date().timeIntervalSince(date))
    let h = elapsed / 3600, m = (elapsed % 3600) / 60
    return h > 0 ? "\(h)시간 \(m)분 전" : "\(m)분 전"
}

private func activeLabel(from date: Date?, default text: String = "수면 중") -> String {
    guard let date else { return text }
    let elapsed = Int(Date().timeIntervalSince(date))
    let h = elapsed / 3600, m = (elapsed % 3600) / 60
    return h > 0 ? "\(h)시간 \(m)분" : "\(m)분"
}

private func timeLabel(_ date: Date?) -> String {
    guard let date else { return "--:--" }
    let fmt = DateFormatter(); fmt.dateFormat = "HH:mm"
    return fmt.string(from: date)
}

// MARK: - Shared Entry & Provider

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

// MARK: - Color Palette

private extension Color {
    static let bbBlue   = Color(red: 0.36, green: 0.50, blue: 1.00)
    static let bbPurple = Color(red: 0.48, green: 0.41, blue: 0.93)
    static let bbGreen  = Color(red: 0.25, green: 0.72, blue: 0.55)
    static let bbOrange = Color(red: 1.00, green: 0.60, blue: 0.20)
    static let bbRed    = Color(red: 0.95, green: 0.35, blue: 0.35)
    static let bbGray   = Color(red: 0.54, green: 0.54, blue: 0.60)
}

// MARK: - Deep Link URL Helper

private func actionURL(_ path: String) -> URL {
    URL(string: "bebetap://\(path)")!
}

// MARK: - Shared Header

private struct WidgetHeader: View {
    let icon: String
    let color: Color
    let label: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2).foregroundColor(color)
            Text(label).font(.caption2).fontWeight(.semibold).foregroundColor(.secondary)
        }
    }
}

// MARK: - 1. 분유 위젯

struct FormulaWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        Link(destination: actionURL("log/formula")) {
            VStack(alignment: .leading, spacing: 6) {
                WidgetHeader(icon: "cup.and.saucer.fill", color: .bbBlue, label: "분유")
                Spacer()
                Text(elapsedLabel(from: entry.store.lastFormulaTime))
                    .font(.subheadline).fontWeight(.bold)
                if entry.store.formulaTotalMl > 0 {
                    Text("오늘 \(entry.store.formulaTotalMl)ml")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(.background, for: .widget)
        }
    }
}

struct FormulaWidget: Widget {
    let kind = "FormulaWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            FormulaWidgetView(entry: entry)
        }
        .configurationDisplayName("분유")
        .description("마지막 분유로부터 경과 시간과 오늘 총량을 표시합니다.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - 2. 모유 위젯

struct BreastWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader(icon: "heart.fill", color: .bbRed, label: "모유")
            Spacer()
            Text(elapsedLabel(from: entry.store.lastBreastTime))
                .font(.subheadline).fontWeight(.bold)
            HStack(spacing: 6) {
                Link(destination: actionURL("log/breast")) {
                    Text("왼쪽").font(.caption2).padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.bbRed.opacity(0.12)).cornerRadius(6)
                }
                Link(destination: actionURL("log/breast")) {
                    Text("오른쪽").font(.caption2).padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.bbRed.opacity(0.12)).cornerRadius(6)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.background, for: .widget)
    }
}

struct BreastWidget: Widget {
    let kind = "BreastWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            BreastWidgetView(entry: entry)
        }
        .configurationDisplayName("모유")
        .description("마지막 모유 수유로부터 경과 시간을 표시합니다.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - 3. 유축수유 위젯

struct PumpedWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        Link(destination: actionURL("log/pumped")) {
            VStack(alignment: .leading, spacing: 6) {
                WidgetHeader(icon: "drop.fill", color: .bbBlue, label: "유축수유")
                Spacer()
                Text(elapsedLabel(from: entry.store.lastPumpedTime))
                    .font(.subheadline).fontWeight(.bold)
                if entry.store.pumpedTotalMl > 0 {
                    Text("오늘 \(entry.store.pumpedTotalMl)ml")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(.background, for: .widget)
        }
    }
}

struct PumpedWidget: Widget {
    let kind = "PumpedWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            PumpedWidgetView(entry: entry)
        }
        .configurationDisplayName("유축수유")
        .description("마지막 유축 수유로부터 경과 시간과 오늘 총량을 표시합니다.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - 4. 기저귀 위젯

struct DiaperWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader(icon: "shower.fill", color: .bbGreen, label: "기저귀")
            Spacer()
            Text("오늘 \(entry.store.diaperCountToday)회")
                .font(.subheadline).fontWeight(.bold)
            HStack(spacing: 4) {
                diaperButton("소변", path: "action/diaper/wet",   color: .bbBlue)
                diaperButton("대변", path: "action/diaper/soiled", color: .bbOrange)
                diaperButton("대+소", path: "action/diaper/both",  color: .bbGreen)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.background, for: .widget)
    }

    private func diaperButton(_ label: String, path: String, color: Color) -> some View {
        Link(destination: actionURL(path)) {
            Text(label).font(.system(size: 10, weight: .semibold))
                .padding(.horizontal, 6).padding(.vertical, 4)
                .background(color.opacity(0.12)).cornerRadius(6)
        }
    }
}

struct DiaperWidget: Widget {
    let kind = "DiaperWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            DiaperWidgetView(entry: entry)
        }
        .configurationDisplayName("기저귀")
        .description("오늘 기저귀 횟수와 빠른 기록 버튼을 제공합니다.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - 5. 수면 위젯

struct SleepWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader(icon: "moon.fill", color: .bbPurple, label: "수면")
            Spacer()
            if entry.store.sleepActive {
                Text(activeLabel(from: entry.store.sleepStartTime))
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.bbPurple)
                Link(destination: actionURL("action/sleep/end")) {
                    Text("종료").font(.caption2).padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.bbPurple.opacity(0.12)).cornerRadius(6)
                }
            } else {
                Text("오늘 \(entry.store.todaySleepMin / 60)시간 \(entry.store.todaySleepMin % 60)분")
                    .font(.subheadline).fontWeight(.bold)
                Link(destination: actionURL("action/sleep/start")) {
                    Text("시작").font(.caption2).padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.bbPurple.opacity(0.12)).cornerRadius(6)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.background, for: .widget)
    }
}

struct SleepWidget: Widget {
    let kind = "SleepWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            SleepWidgetView(entry: entry)
        }
        .configurationDisplayName("수면")
        .description("수면 시작/종료 버튼과 오늘 총 수면 시간을 표시합니다.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - 6. 체온 위젯

struct TemperatureWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        Link(destination: actionURL("log/temperature")) {
            VStack(alignment: .leading, spacing: 6) {
                WidgetHeader(icon: "thermometer.medium", color: .bbOrange, label: "체온")
                Spacer()
                if entry.store.lastTempCelsius > 0 {
                    Text(String(format: "%.1f°C", entry.store.lastTempCelsius))
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(entry.store.lastTempCelsius >= 37.5 ? .bbRed : .primary)
                    Text(timeLabel(entry.store.lastTempTime))
                        .font(.caption2).foregroundColor(.secondary)
                } else {
                    Text("기록 없음").font(.subheadline).foregroundColor(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(.background, for: .widget)
        }
    }
}

struct TemperatureWidget: Widget {
    let kind = "TemperatureWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            TemperatureWidgetView(entry: entry)
        }
        .configurationDisplayName("체온")
        .description("마지막 체온 측정 결과를 표시합니다.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - 7. 이유식 위젯

struct BabyFoodWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        Link(destination: actionURL("log/baby_food")) {
            VStack(alignment: .leading, spacing: 6) {
                WidgetHeader(icon: "fork.knife", color: .bbOrange, label: "이유식")
                Spacer()
                Text(elapsedLabel(from: entry.store.lastBabyFoodTime))
                    .font(.subheadline).fontWeight(.bold)
                if entry.store.babyFoodTotalMl > 0 {
                    Text("오늘 \(entry.store.babyFoodTotalMl)ml")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(.background, for: .widget)
        }
    }
}

struct BabyFoodWidget: Widget {
    let kind = "BabyFoodWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            BabyFoodWidgetView(entry: entry)
        }
        .configurationDisplayName("이유식")
        .description("마지막 이유식으로부터 경과 시간과 오늘 총량을 표시합니다.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Bundle Row Views (묶음 위젯용 컴포넌트)

private struct BundleFormulaRow: View {
    let store: BebeTapStore
    var body: some View {
        HStack {
            Image(systemName: "cup.and.saucer.fill").foregroundColor(.bbBlue).font(.caption)
            Text("분유").font(.caption2).foregroundColor(.secondary)
            Spacer()
            Text(elapsedLabel(from: store.lastFormulaTime)).font(.caption2).fontWeight(.semibold)
        }
    }
}

private struct BundleDiaperRow: View {
    let store: BebeTapStore
    var body: some View {
        HStack {
            Image(systemName: "shower.fill").foregroundColor(.bbGreen).font(.caption)
            Text("기저귀").font(.caption2).foregroundColor(.secondary)
            Spacer()
            Text("오늘 \(store.diaperCountToday)회").font(.caption2).fontWeight(.semibold)
            HStack(spacing: 3) {
                Link(destination: actionURL("action/diaper/wet")) {
                    Text("소").font(.system(size: 9)).padding(3)
                        .background(Color.bbBlue.opacity(0.12)).cornerRadius(4)
                }
                Link(destination: actionURL("action/diaper/soiled")) {
                    Text("대").font(.system(size: 9)).padding(3)
                        .background(Color.bbOrange.opacity(0.12)).cornerRadius(4)
                }
                Link(destination: actionURL("action/diaper/both")) {
                    Text("대+소").font(.system(size: 9)).padding(3)
                        .background(Color.bbGreen.opacity(0.12)).cornerRadius(4)
                }
            }
        }
    }
}

private struct BundleSleepRow: View {
    let store: BebeTapStore
    var body: some View {
        HStack {
            Image(systemName: "moon.fill").foregroundColor(.bbPurple).font(.caption)
            Text("수면").font(.caption2).foregroundColor(.secondary)
            Spacer()
            if store.sleepActive {
                Text(activeLabel(from: store.sleepStartTime)).font(.caption2).fontWeight(.semibold).foregroundColor(.bbPurple)
                Link(destination: actionURL("action/sleep/end")) {
                    Text("종료").font(.system(size: 9)).padding(3)
                        .background(Color.bbPurple.opacity(0.12)).cornerRadius(4)
                }
            } else {
                Text("\(store.todaySleepMin / 60)h \(store.todaySleepMin % 60)m").font(.caption2).fontWeight(.semibold)
                Link(destination: actionURL("action/sleep/start")) {
                    Text("시작").font(.system(size: 9)).padding(3)
                        .background(Color.bbPurple.opacity(0.12)).cornerRadius(4)
                }
            }
        }
    }
}

private struct BundleBreastRow: View {
    let store: BebeTapStore
    var body: some View {
        HStack {
            Image(systemName: "heart.fill").foregroundColor(.bbRed).font(.caption)
            Text("모유").font(.caption2).foregroundColor(.secondary)
            Spacer()
            Text(elapsedLabel(from: store.lastBreastTime)).font(.caption2).fontWeight(.semibold)
        }
    }
}

private struct BundleBabyFoodRow: View {
    let store: BebeTapStore
    var body: some View {
        HStack {
            Image(systemName: "fork.knife").foregroundColor(.bbOrange).font(.caption)
            Text("이유식").font(.caption2).foregroundColor(.secondary)
            Spacer()
            Text(elapsedLabel(from: store.lastBabyFoodTime)).font(.caption2).fontWeight(.semibold)
        }
    }
}

private struct BundleTemperatureRow: View {
    let store: BebeTapStore
    var body: some View {
        HStack {
            Image(systemName: "thermometer.medium").foregroundColor(.bbOrange).font(.caption)
            Text("체온").font(.caption2).foregroundColor(.secondary)
            Spacer()
            if store.lastTempCelsius > 0 {
                Text(String(format: "%.1f°C", store.lastTempCelsius))
                    .font(.caption2).fontWeight(.semibold)
                    .foregroundColor(store.lastTempCelsius >= 37.5 ? .bbRed : .primary)
                Text(timeLabel(store.lastTempTime)).font(.system(size: 9)).foregroundColor(.secondary)
            } else {
                Text("기록 없음").font(.caption2).foregroundColor(.secondary)
            }
        }
    }
}

private struct BundlePumpedRow: View {
    let store: BebeTapStore
    var body: some View {
        HStack {
            Image(systemName: "drop.fill").foregroundColor(.bbBlue).font(.caption)
            Text("유축수유").font(.caption2).foregroundColor(.secondary)
            Spacer()
            Text(elapsedLabel(from: store.lastPumpedTime)).font(.caption2).fontWeight(.semibold)
        }
    }
}

// MARK: - 8. 올인원 위젯

struct AllInOneWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 4) {
                Image(systemName: "hare.fill").font(.caption2).foregroundColor(.bbBlue)
                Text("BebeTap 올인원").font(.caption2).fontWeight(.semibold).foregroundColor(.secondary)
            }
            Divider()
            BundleFormulaRow(store: entry.store)
            BundleBreastRow(store: entry.store)
            BundlePumpedRow(store: entry.store)
            BundleDiaperRow(store: entry.store)
            BundleSleepRow(store: entry.store)
            BundleTemperatureRow(store: entry.store)
            BundleBabyFoodRow(store: entry.store)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(.background, for: .widget)
    }
}

struct AllInOneWidget: Widget {
    let kind = "AllInOneWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            AllInOneWidgetView(entry: entry)
        }
        .configurationDisplayName("BebeTap 올인원")
        .description("수유·기저귀·수면·체온 전체 현황을 한눈에 확인합니다.")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - 9. 필수 3종 위젯

struct EssentialWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "hare.fill").font(.caption2).foregroundColor(.bbBlue)
                Text("BebeTap 필수 3종").font(.caption2).fontWeight(.semibold).foregroundColor(.secondary)
            }
            Divider()
            BundleFormulaRow(store: entry.store)
            BundleDiaperRow(store: entry.store)
            BundleSleepRow(store: entry.store)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(.background, for: .widget)
    }
}

struct EssentialWidget: Widget {
    let kind = "EssentialWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            EssentialWidgetView(entry: entry)
        }
        .configurationDisplayName("BebeTap 필수 3종")
        .description("분유·기저귀·수면 핵심 정보를 빠르게 확인합니다.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - 10. 신생아 위젯

struct NewbornWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "hare.fill").font(.caption2).foregroundColor(.bbBlue)
                Text("BebeTap 신생아").font(.caption2).fontWeight(.semibold).foregroundColor(.secondary)
            }
            Divider()
            BundleFormulaRow(store: entry.store)
            BundleBreastRow(store: entry.store)
            BundleDiaperRow(store: entry.store)
            BundleSleepRow(store: entry.store)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(.background, for: .widget)
    }
}

struct NewbornWidget: Widget {
    let kind = "NewbornWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            NewbornWidgetView(entry: entry)
        }
        .configurationDisplayName("BebeTap 신생아")
        .description("분유·모유·기저귀·수면 신생아 핵심 정보를 표시합니다.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - 11. 이유식기 위젯

struct BabyFoodStageWidgetView: View {
    let entry: BebeTapEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "hare.fill").font(.caption2).foregroundColor(.bbBlue)
                Text("BebeTap 이유식기").font(.caption2).fontWeight(.semibold).foregroundColor(.secondary)
            }
            Divider()
            BundleBabyFoodRow(store: entry.store)
            BundleDiaperRow(store: entry.store)
            BundleSleepRow(store: entry.store)
            BundleTemperatureRow(store: entry.store)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(.background, for: .widget)
    }
}

struct BabyFoodStageWidget: Widget {
    let kind = "BabyFoodStageWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            BabyFoodStageWidgetView(entry: entry)
        }
        .configurationDisplayName("BebeTap 이유식기")
        .description("이유식·기저귀·수면·체온 이유식 시기 핵심 정보를 표시합니다.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle

@main
struct BebetapWidgetBundle: WidgetBundle {
    var body: some Widget {
        FormulaWidget()
        BreastWidget()
        PumpedWidget()
        DiaperWidget()
        SleepWidget()
        TemperatureWidget()
        BabyFoodWidget()
        AllInOneWidget()
        EssentialWidget()
        NewbornWidget()
        BabyFoodStageWidget()
    }
}
