import Foundation
import SwiftData

@Model
class Appliance {
    var id: UUID
    var name: String            // 기기명 (예: 공기청정기)
    var brand: String           // 브랜드 (예: 삼성)
    var purchaseDate: Date?     // 기기 구매일
    var memo: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var tasks: [MaintenanceTask]
    
    init(
        name: String,
        brand: String = "",
        purchaseDate: Date? = nil,
        memo: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.purchaseDate = purchaseDate
        self.memo = memo
        self.createdAt = Date()
        self.tasks = []
    }
}
