import Foundation
import SwiftData

@Model
class MaintenanceTask {
    var id: UUID
    var taskName: String        // 관리 항목명 (예: 필터 교체)
    var intervalDays: Int       // 관리 주기 (일 단위)
    var createdAt: Date
    
    var appliance: Appliance?   // 역참조
    
    @Relationship(deleteRule: .cascade)
    var records: [MaintenanceRecord]
    
    init(
        taskName: String,
        intervalDays: Int
    ) {
        self.id = UUID()
        self.taskName = taskName
        self.intervalDays = intervalDays
        self.createdAt = Date()
        self.records = []
    }
    
    // MARK: - 계산 프로퍼티
    
    // 마지막 관리일
    var lastMaintenanceDate: Date? {
        records.sorted { $0.date < $1.date }.last?.date
    }
    
    // 다음 관리 예정일
    var nextMaintenanceDate: Date? {
        guard let last = lastMaintenanceDate else { return nil }
        return Calendar.current.date(byAdding: .day,
                                     value: intervalDays,
                                     to: last)
    }
    
    // D-Day 계산
    var dDay: Int? {
        guard let next = nextMaintenanceDate else { return nil }
        let diff = Calendar.current.dateComponents([.day],
                                                   from: Date(),
                                                   to: next)
        return diff.day
    }
    
    // 상태 판단
    var status: MaintenanceStatus {
        guard let d = dDay else { return .unknown }
        switch d {
        case ..<0:    return .overdue     // 초과
        case 0...7:   return .soon        // 임박
        default:      return .good        // 여유
        }
    }
}

enum MaintenanceStatus {
    case good       // 🟢 여유
    case soon       // 🟡 임박 (7일 이내)
    case overdue    // 🔴 초과
    case unknown    // ⚫ 기록 없음
    
    var color: String {
        switch self {
        case .good:    return "green"
        case .soon:    return "yellow"
        case .overdue: return "red"
        case .unknown: return "gray"
        }
    }
    
    var label: String {
        switch self {
        case .good:    return "여유"
        case .soon:    return "임박"
        case .overdue: return "초과"
        case .unknown: return "기록없음"
        }
    }
}
