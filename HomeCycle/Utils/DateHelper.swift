import Foundation

extension Date {
    // 2026년 4월 16일
    var koreanFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: self)
    }
    
    // 2026년 4월 16일 (요일)
    var koreanFormattedWithDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        return formatter.string(from: self)
    }
}

// ✅ 가격 콤마 포맷 추가
extension String {
    // "55000" → "55,000"
    var priceFormatted: String {
        let digits = self.filter { $0.isNumber }
        guard let number = Int(digits) else { return digits }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? digits
    }
}
