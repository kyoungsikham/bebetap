import WidgetKit
import SwiftUI

// MARK: - Data Model

struct BebeTapEntry: TimelineEntry {
    let date: Date
    let lastFeedingLabel: String
    let formulaTotalMl: Int
    let isSleeping: Bool
    let sleepElapsedLabel: String
}

// MARK: - Timeline Provider

struct BebeTapProvider: TimelineProvider {
    private let appGroupId = "group.com.bebetap.app"

    func placeholder(in context: Context) -> BebeTapEntry {
        BebeTapEntry(
            date: Date(),
            lastFeedingLabel: "3시간 전",
            formulaTotalMl: 540,
            isSleeping: false,
            sleepElapsedLabel: ""
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BebeTapEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BebeTapEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: appGroupId)
        let formatter = ISO8601DateFormatter()

        // 마지막 수유 시간
        var lastFeedingLabel = "기록 없음"
        if let str = defaults?.string(forKey: "lastFeedingTime"),
           let feedingDate = formatter.date(from: str) {
            let elapsed = Int(Date().timeIntervalSince(feedingDate))
            let h = elapsed / 3600
            let m = (elapsed % 3600) / 60
            lastFeedingLabel = h > 0 ? "\(h)시간 \(m)분 전" : "\(m)분 전"
        }

        let formulaTotal = defaults?.integer(forKey: "formulaTotalMl") ?? 0
        let isSleeping = defaults?.bool(forKey: "sleepActive") ?? false

        // 수면 경과 시간
        var sleepLabel = ""
        if isSleeping,
           let str = defaults?.string(forKey: "sleepStartTime"),
           let startDate = formatter.date(from: str) {
            let elapsed = Int(Date().timeIntervalSince(startDate))
            let h = elapsed / 3600
            let m = (elapsed % 3600) / 60
            sleepLabel = h > 0 ? "\(h)시간 \(m)분" : "\(m)분"
        }

        let entry = BebeTapEntry(
            date: Date(),
            lastFeedingLabel: lastFeedingLabel,
            formulaTotalMl: formulaTotal,
            isSleeping: isSleeping,
            sleepElapsedLabel: sleepLabel
        )

        // 15분마다 갱신
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget View

struct BebeTapWidgetView: View {
    var entry: BebeTapEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "hare.fill")
                    .font(.caption2)
                    .foregroundColor(Color(red: 0.36, green: 0.50, blue: 1.0))
                Text("BebeTap")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if entry.isSleeping {
                Label {
                    Text(entry.sleepElapsedLabel.isEmpty ? "수면 중" : entry.sleepElapsedLabel)
                        .font(.subheadline).fontWeight(.semibold)
                } icon: {
                    Image(systemName: "moon.fill")
                        .foregroundColor(Color(red: 0.48, green: 0.41, blue: 0.93))
                }
            } else {
                Label {
                    Text(entry.lastFeedingLabel)
                        .font(.subheadline).fontWeight(.semibold)
                } icon: {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundColor(Color(red: 0.36, green: 0.50, blue: 1.0))
                }
            }

            if entry.formulaTotalMl > 0 {
                Text("분유 \(entry.formulaTotalMl)ml")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.white, for: .widget)
    }
}

// MARK: - Widget Configuration

@main
struct BebeTapWidget: Widget {
    let kind = "BebeTapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BebeTapProvider()) { entry in
            BebeTapWidgetView(entry: entry)
        }
        .configurationDisplayName("BebeTap")
        .description("아기 수유 및 수면 현황을 홈 화면에서 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
