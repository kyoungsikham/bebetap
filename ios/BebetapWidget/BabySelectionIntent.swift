import AppIntents
import WidgetKit
import Foundation

// MARK: - Baby Entity

struct BabyEntity: AppEntity {
    var id: String
    var name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "아기"
    static var defaultQuery = BabyEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

// MARK: - Baby Entity Query

struct BabyEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [BabyEntity] {
        _allBabies().filter { identifiers.contains($0.id) }
    }
    func suggestedEntities() async throws -> [BabyEntity] { _allBabies() }
    // defaultResult 없음 — picker가 "선택 안 됨" 상태로 노출됨
    // nil 시 fallback은 BebeTapProvider._resolvedBabyId 에서 첫 번째 아기로 처리
}

private func _allBabies() -> [BabyEntity] {
    let d     = UserDefaults(suiteName: "group.com.bebetap.app")
    let ids   = (d?.string(forKey: "widget_baby_ids")   ?? "").split(separator: "|").map(String.init).filter { !$0.isEmpty }
    let names = (d?.string(forKey: "widget_baby_names") ?? "").split(separator: "|").map(String.init).filter { !$0.isEmpty }
    return ids.enumerated().map { idx, id in
        BabyEntity(id: id, name: names.indices.contains(idx) ? names[idx] : id)
    }
}

// MARK: - Widget Configuration Intent

struct BabySelectionIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "아기 선택"
    static var description = IntentDescription("표시할 아기를 선택하세요.")

    @Parameter(title: "아기")
    var baby: BabyEntity?
}
