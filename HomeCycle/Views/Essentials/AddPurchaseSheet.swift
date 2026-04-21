import SwiftUI
import SwiftData

struct AddPurchaseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var product: Product

    @State private var purchaseDate: Date = Date()
    @State private var store: String = ""
    @State private var priceText: String = ""
    @State private var volumeText: String = ""
    @State private var quantityText: String = ""
    @State private var memo: String = ""

    private var price: Double {
        Double(priceText.filter { $0.isNumber }) ?? 0
    }

    private var volume: Double? {
        guard product.unitType.hasVolume,
              let v = Double(volumeText), v > 0 else { return nil }
        return v
    }

    private var pricePerUnitDisplay: (amount: Double, unit: Int)? {
        guard let vol = volume, vol > 0, price > 0 else { return nil }
        let qty = Double(max(1, Int(quantityText) ?? 1))  // ✅ 수량 반영
        let pricePerOne = price / qty                      // ✅ 1개당 가격
        
        if vol <= 100 {
            return (pricePerOne / (vol / 10), 10)
        } else {
            return (pricePerOne / (vol / 100), 100)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - 제품 정보 헤더
                    productHeader

                    // MARK: - 구매 정보 입력
                    formSection(title: "구매 정보", icon: "bag.fill") {
                        VStack(spacing: 0) {

                            fieldRow {
                                DatePicker("구매일자",
                                           selection: $purchaseDate,
                                           displayedComponents: .date)
                                .font(.subheadline)
                                .environment(\.locale, Locale(identifier: "ko_KR"))
                            }

                            divider

                            fieldRow {
                                HStack {
                                    Text("구매처").font(.subheadline)
                                    Spacer()
                                    TextField("예) 올리브영, 쿠팡", text: $store)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                            }

                            divider

                            fieldRow {
                                HStack {
                                    Text("가격").font(.subheadline)
                                    Spacer()
                                    TextField("0", text: $priceText)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                        .frame(width: 120)
                                        .onChange(of: priceText) { _, newValue in
                                            let digits = newValue.filter { $0.isNumber }
                                            if let number = Int(digits) {
                                                let formatter = NumberFormatter()
                                                formatter.numberStyle = .decimal
                                                priceText = formatter.string(from: NSNumber(value: number)) ?? digits
                                            } else {
                                                priceText = digits
                                            }
                                        }
                                    Text("원").font(.subheadline).foregroundColor(.secondary)
                                }
                            }

                            divider

                            fieldRow {
                                HStack {
                                    Text("수량").font(.subheadline)
                                    Spacer()
                                    TextField("1", text: $quantityText)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                        .frame(width: 60)
                                    Text("개").font(.subheadline).foregroundColor(.secondary)
                                }
                            }

                            // 용량 입력 (ml/g 제품만)
                            if product.unitType.hasVolume {

                                divider

                                fieldRow {
                                    HStack {
                                        Text("용량").font(.subheadline)
                                        Spacer()
                                        TextField("0", text: $volumeText)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                            .font(.subheadline)
                                            .frame(width: 100)
                                        Text(product.unitType.rawValue)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                if let calc = pricePerUnitDisplay {
                                    divider

                                    fieldRow {
                                        HStack {
                                            HStack(spacing: 4) {
                                                Image(systemName: "sparkles")
                                                    .font(.caption)
                                                    .foregroundColor(.accentColor)
                                                Text("\(calc.unit)\(product.unitType.rawValue)당 가격")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text("\(Int(calc.amount.rounded()))원")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }

                            divider

                            fieldRow {
                                HStack(alignment: .top) {
                                    Text("메모").font(.subheadline)
                                    Spacer()
                                    TextField("선택사항", text: $memo, axis: .vertical)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                        .lineLimit(1...3)
                                }
                            }
                        }
                    }

                    // MARK: - 저장 버튼
                    Button {
                        savePurchase()
                    } label: {
                        Text("저장하기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("구매 기록 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - 제품 헤더
    private var productHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: product.category.icon)
                    .foregroundColor(.accentColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.headline)
                Text(product.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if !product.purchaseRecords.isEmpty {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("총 \(product.purchaseRecords.count)회 구매")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let cycle = product.averageCycleDays {
                        Text("평균 \(Int(cycle))일 주기")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // MARK: - 저장
    private func savePurchase() {
        let qty = max(1, Int(quantityText) ?? 1)
        let record = PurchaseRecord(
            date: purchaseDate,
            store: store.trimmingCharacters(in: .whitespaces),
            price: price,
            volume: volume,
            quantity: qty,
            memo: memo.trimmingCharacters(in: .whitespaces)
        )

        modelContext.insert(record)
        product.purchaseRecords.append(record)

        try? modelContext.save()
        dismiss()
    }

    // MARK: - UI Helpers
    private var divider: some View {
        Divider().padding(.leading, 16)
    }

    private func formSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            content()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
        }
    }

    private func fieldRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }
}
