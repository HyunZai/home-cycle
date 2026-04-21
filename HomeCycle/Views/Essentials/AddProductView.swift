import SwiftUI
import SwiftData

struct AddProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedCategory: ProductCategory = .bathroom
    @State private var selectedUnitType: UnitType = .none

    @State private var addFirstPurchase: Bool = true
    @State private var purchaseDate: Date = Date()
    @State private var store: String = ""
    @State private var priceText: String = ""
    @State private var volumeText: String = ""
    @State private var quantityText: String = ""
    @State private var memo: String = ""

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // price 계산 프로퍼티 (콤마 제거 후 Double 변환)
    private var price: Double {
        Double(priceText.filter { $0.isNumber }) ?? 0
    }

    private var volume: Double? {
        guard selectedUnitType.hasVolume,
              let v = Double(volumeText), v > 0 else { return nil }
        return v
    }

    // ✅ 수정된 코드
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

                    // MARK: - 제품 정보
                    formSection(title: "제품 정보", icon: "tag.fill") {
                        VStack(spacing: 0) {

                            fieldRow {
                                HStack {
                                    Text("제품명").font(.subheadline)
                                    Spacer()
                                    TextField("예) 수분크림", text: $name)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                            }

                            divider

                            fieldRow {
                                HStack {
                                    Text("카테고리").font(.subheadline)
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
                                            Image(systemName: selectedCategory.icon).font(.caption)
                                            Text(selectedCategory.rawValue).font(.subheadline)
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .foregroundColor(.accentColor)
                                    }
                                }
                            }

                            divider

                            fieldRow {
                                HStack {
                                    Text("용량 단위").font(.subheadline)
                                    Spacer()
                                    Picker("", selection: $selectedUnitType) {
                                        ForEach(UnitType.allCases, id: \.self) { unit in
                                            Text(unit.rawValue).tag(unit)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 160)
                                }
                            }
                        }
                    }

                    // MARK: - 첫 구매 기록
                    formSection(title: "첫 구매 기록", icon: "bag.fill") {
                        VStack(spacing: 0) {

                            fieldRow {
                                Toggle(isOn: $addFirstPurchase.animation()) {
                                    Text("구매 기록 바로 추가").font(.subheadline)
                                }
                            }

                            if addFirstPurchase {

                                divider

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
                                                // 숫자만 추출 후 콤마 포맷 적용
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

                                if selectedUnitType.hasVolume {

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
                                            Text(selectedUnitType.rawValue)
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
                                                    Text("\(calc.unit)\(selectedUnitType.rawValue)당 가격")
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
                    }

                    // MARK: - 저장 버튼
                    Button {
                        saveProduct()
                    } label: {
                        Text("저장하기")
                            .font(.headline)
                            .foregroundColor(.white)
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

    // MARK: - 저장 (완전히 새로 작성)
    private func saveProduct() {
        guard isFormValid else { return }

        // 1. Product 생성 및 insert
        let product = Product(
            name: name.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            unitType: selectedUnitType
        )
        modelContext.insert(product)

        // 2. 구매 기록 추가 (가격 입력 여부 무관하게 토글이 켜져 있으면 저장)
        if addFirstPurchase {
            let qty = max(1, Int(quantityText) ?? 1)
            let record = PurchaseRecord(
                date: purchaseDate,
                store: store.trimmingCharacters(in: .whitespaces),
                price: price,
                volume: volume,
                quantity: qty,
                memo: memo.trimmingCharacters(in: .whitespaces)
            )
            // 3. ✅ record도 반드시 insert
            modelContext.insert(record)

            // 4. ✅ 관계 설정은 insert 이후에
            product.purchaseRecords.append(record)
        }

        // 5. ✅ 명시적 save로 디스크에 반영
        do {
            try modelContext.save()
            print("✅ 저장 성공: \(product.name)")
        } catch {
            print("❌ 저장 실패: \(error.localizedDescription)")
        }

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
