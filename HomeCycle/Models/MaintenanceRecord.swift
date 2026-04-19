import Foundation
import SwiftData

@Model
class MaintenanceRecord {
    var id: UUID
    var date: Date
    var cost: Double?           // 비용 (선택)
    var memo: String
    
    var task: MaintenanceTask?  // 역참조
    
    init(
        date: Date = Date(),
        cost: Double? = nil,
        memo: String = ""
    ) {
        self.id = UUID()
        self.date = date
        self.cost = cost
        self.memo = memo
    }
}
