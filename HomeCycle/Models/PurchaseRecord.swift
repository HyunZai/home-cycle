import Foundation
import SwiftData

@Model
class PurchaseRecord {
    var id: UUID
    var date: Date
    var store: String
    var price: Double
    var volume: Double?
    var quantity: Int
    var memo: String
    
    var product: Product?
    
    init(
        date: Date = Date(),
        store: String = "",
        price: Double,
        volume: Double? = nil,
        quantity: Int = 1,
        memo: String = ""
    ) {
        self.id = UUID()
        self.date = date
        self.store = store
        self.price = price
        self.volume = volume
        self.quantity = quantity
        self.memo = memo
    }
    
    // 100ml(g)당 가격
    var pricePerHundred: Double? {
        guard let vol = volume, vol > 0 else { return nil }
        return (price / vol) * 100
    }
    
    // 총 결제금액 (단가 × 수량)
    var totalPrice: Double {
        price * Double(quantity)
    }
}
