import SwiftUI
import SwiftData

struct AddProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form State
    @State private var name: String = ""
    @State private var selectedCategory: ProductCategory = .bathroom
    @State private var selectedUnitType: UnitType = .none
    
    // 첫 구매 기록
    @State private var addFirstPurchase: Bool = true
    @State private var purchaseDate: Date = Date()
    @State private var store: String = ""
    @State private var priceText: String = ""
    @State private var volumeText: String = ""
    @State private var memo: String = ""
    @State private var quantityText: String = ""
    
    // MARK: - Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var price: Double {
        Double(priceText.replacingOccurrences(of: ",", with: "")) ?? 0
    }
    
    private var volume: Double? {
        guard selectedUnitType.hasVolume,
              let v = Double(volumeText), v > 0 else { return nil }
        return v
    }
    
    private var pricePerHundred: Double? {
        guard let vol = volume, vol > 0, price > 0 else { return nil }
        return (price / vol) * 100
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - 제품 기본 정보
                    formSection(title: "제품 정보", icon: "tag.fill") {
                        VStack(spacing: 0) {
                            // 제품명
                            fieldRow {
                                HStack {
                                    Text("제품명")
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    TextField("예) 수분크림", text: $name)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                            }
                            
                            divider
                            
                            // 카테고리
                            fieldRow {
                                HStack {
                                    Text("카테고리")
                                        .font(.subheadline)
                                    Spacer()
                                    Menu {
                                        ForEach(ProductCategory.allCases, id: \.self) { cat in
                                            Button {
                                                selectedCategory = cat
                                            } label: {
                                                Label(cat.rawValue, systemImage: cat.icon)
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: selectedCategory.icon)
                                                .font(.caption)
                                            Text(selectedCategory.rawValue)
                                                .font(.subheadline)
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.caption2)
                                                .foregroundStyle(.tertiary)
                                        }
                                        .foregroundStyle(Color.accentColor)
                                    }
                                }
                            }
                            
                            divider
                            
                            // 용량 단위
                            fieldRow {
                                HStack {
                                    Text("용량 단위")
                                        .font(.subheadline)
                                    Spacer()
                                    Picker("", selection: $selectedUnitType) {
                                        ForEach(UnitType.allCases, id: \.self) { unit in
                                            Text(unit.rawValue).tag(unit)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 200)
                                }
                            }
                        }
                    }
                    
                    // MARK: - 첫 구매 기록 토글
                    formSection(title: "첫 구매 기록", icon: "bag.fill") {
                        VStack(spacing: 0) {
                            
                            fieldRow {
                                Toggle(isOn: $addFirstPurchase.animation()) {
                                    Text("구매 기록 바로 추가")
                                        .font(.subheadline)
                                }
                            }
                            
                            if addFirstPurchase {
                                divider
                                
                                // 구매일
                                fieldRow {
                                    DatePicker(
                                        "구매일자",
                                        selection: $purchaseDate,
                                        displayedComponents: .date
                                    )
                                    .font(.subheadline)
                                    .environment(\.locale, Locale(identifier: "ko_KR"))
                                }
                                
                                divider
                                
                                // 구매처
                                fieldRow {
                                    HStack {
                                        Text("구매처")
                                            .font(.subheadline)
                                        Spacer()
                                        TextField("예) 올리브영, 쿠팡", text: $store)
                                            .multilineTextAlignment(.trailing)
                                            .font(.subheadline)
                                    }
                                }
                                
                                divider
                                
                                // 가격
                                fieldRow {
                                    HStack {
                                        Text("가격")
                                            .font(.subheadline)
                                        Spacer()
                                        TextField("0", text: $priceText)
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.trailing)
                                            .font(.subheadline)
                                            .frame(width: 120)
                                        Text("원")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                // 용량 (ml/g인 경우만)
                                if selectedUnitType.hasVolume {
                                    divider
                                    
                                    fieldRow {
                                        HStack {
                                            Text("용량")
                                                .font(.subheadline)
                                            Spacer()
                                            TextField("0", text: $volumeText)
                                                .keyboardType(.decimalPad)
                                                .multilineTextAlignment(.trailing)
                                                .font(.subheadline)
                                                .frame(width: 100)
                                            Text(selectedUnitType.rawValue)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    divider

                                    // 수량
                                    fieldRow {
                                        HStack {
                                            Text("수량")
                                                .font(.subheadline)
                                            Spacer()
                                            TextField("1", text: $quantityText)
                                                .keyboardType(.numberPad)
                                                .multilineTextAlignment(.trailing)
                                                .font(.subheadline)
                                                .frame(width: 60)
                                            Text("개")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    // 100ml당 가격 자동 계산 표시
                                    if let pph = pricePerHundred {
                                        divider
                                        
                                        fieldRow {
                                            HStack {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "sparkles")
                                                        .font(.caption)
                                                        .foregroundStyle(Color.accentColor)
                                                    Text("100\(selectedUnitType.rawValue)당 가격")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                }
                                                Spacer()
                                                Text("\(Int(pph.rounded()))원")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(Color.accentColor)
                                            }
                                        }
                                    }
                                }
                                
                                divider
                                
                                // 메모
                                fieldRow {
                                    HStack(alignment: .top) {
                                        Text("메모")
                                            .font(.subheadline)
                                        Spacer()
                                        TextField("선택사항", text: $memo, axis: .vertical)
                                            .multilineTextAlignment(.trailing)
                                            .font(.subheadline)
                                            .lineLimit(1...3)
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - 저장 버튼
                    Button {
                        saveProduct()
                    } label: {
                        Text("저장하기")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? Color.accentColor : Color.gray.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("생필품 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    // MARK: - Save
    private func saveProduct() {
        guard isFormValid else { return }
        
        let product = Product(
            name: name.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            unitType: selectedUnitType
        )
        modelContext.insert(product)
        
        if addFirstPurchase && price > 0 {
            let qty = Int(quantityText) ?? 1  // ✅ 미입력시 1개
            let record = PurchaseRecord(
                date: purchaseDate,
                store: store,
                price: price,
                volume: volume,
                quantity: qty,
                memo: memo
            )
            record.product = product
            product.purchaseRecords.append(record)
        }
        
        dismiss()
    }
    
    // MARK: - Helpers
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
                    .foregroundStyle(Color.accentColor)
                Text(title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
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
