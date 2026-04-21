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
        price: Double = 0,
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
    
    // ✅ 올바른 계산식
    // ex. 55000원 / 5개 / 70ml → 10ml당 가격
    // = 55000 ÷ 5 ÷ (70 ÷ 10) = 55000 ÷ 5 ÷ 7 = 약 1,571원
    var pricePerUnit: PricePerUnit? {
        guard let vol = volume, vol > 0, price > 0 else { return nil }
        
        let qty = Double(max(1, quantity))   // ✅ 수량
        let pricePerOne = price / qty        // ✅ 1개당 가격 먼저 계산
        
        if vol <= 100 {
            // 10ml/g 당 가격 = 1개당가격 ÷ (용량 ÷ 10)
            return PricePerUnit(amount: pricePerOne / (vol / 10), unit: 10)
        } else {
            // 100ml/g 당 가격 = 1개당가격 ÷ (용량 ÷ 100)
            return PricePerUnit(amount: pricePerOne / (vol / 100), unit: 100)
        }
    }
    
    var totalPrice: Double {
        price * Double(quantity)
    }
}

struct PricePerUnit {
    let amount: Double
    let unit: Int
}
