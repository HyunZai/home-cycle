import Foundation
import SwiftData

@Model
class Product {
    var id: UUID
    var name: String
    var category: ProductCategory
    var unitType: UnitType
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var purchaseRecords: [PurchaseRecord]
    
    init(
        name: String,
        category: ProductCategory,
        unitType: UnitType = .none
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.unitType = unitType
        self.createdAt = Date()
        self.purchaseRecords = []
    }
    
    var averageCycleDays: Double? {
        let sorted = purchaseRecords.sorted { $0.date < $1.date }
        guard sorted.count >= 2 else { return nil }
        var intervals: [Double] = []
        for i in 1..<sorted.count {
            let diff = sorted[i].date.timeIntervalSince(sorted[i-1].date)
            intervals.append(diff / 86400)
        }
        return intervals.reduce(0, +) / Double(intervals.count)
    }
    
    var nextExpectedDate: Date? {
        guard let cycle = averageCycleDays,
              let lastDate = purchaseRecords.sorted(by: { $0.date < $1.date }).last?.date
        else { return nil }
        return Calendar.current.date(byAdding: .day, value: Int(cycle), to: lastDate)
    }
    
    var lastPurchaseDate: Date? {
        purchaseRecords.sorted { $0.date < $1.date }.last?.date
    }
}

// MARK: - Enum 정의

enum ProductCategory: String, CaseIterable, Codable {
    case bathroom = "욕실"
    case kitchen  = "주방"
    case health   = "건강"
    case living   = "리빙"
    case other    = "기타"
    
    var icon: String {
        switch self {
        case .bathroom: return "shower"
        case .kitchen:  return "fork.knife"
        case .health:   return "heart.fill"
        case .living:   return "house.fill"
        case .other:    return "ellipsis.circle"
        }
    }
}

// ✅ '개입' 제거
enum UnitType: String, CaseIterable, Codable {
    case ml   = "ml"
    case g    = "g"
    case none = "없음"
    
    var hasVolume: Bool {
        self == .ml || self == .g
    }
}
