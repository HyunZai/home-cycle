import SwiftUI
import SwiftData

struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var product: Product

    @State private var showAddPurchase = false
    @State private var showDeleteRecordAlert = false
    @State private var showDeleteProductAlert = false
    @State private var recordToDelete: PurchaseRecord? = nil

    // MARK: - 수정 모드 State
    @State private var isEditing = false
    @State private var editName: String = ""
    @State private var editCategory: ProductCategory = .bathroom
    @State private var editUnitType: UnitType = .none

    var sortedRecords: [PurchaseRecord] {
        product.purchaseRecords.sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                productTitleHeader
                statsSection
                purchaseHistorySection
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        showAddPurchase = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    Button {
                        editName = product.name
                        editCategory = product.category
                        editUnitType = product.unitType
                        isEditing = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPurchase) {
            AddPurchaseSheet(product: product)
        }
        // MARK: - 수정 Sheet
        .sheet(isPresented: $isEditing) {
            editProductSheet
        }
        // MARK: - 구매이력 삭제 Alert
        .alert("구매 기록 삭제", isPresented: $showDeleteRecordAlert) {
            Button("삭제", role: .destructive) {
                if let record = recordToDelete {
                    deleteRecord(record)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 구매 기록을 삭제할까요?")
        }
        // MARK: - 제품 자체 삭제 Alert
        .alert("제품 삭제", isPresented: $showDeleteProductAlert) {
            Button("삭제", role: .destructive) {
                if let record = recordToDelete {
                    deleteRecord(record)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("마지막 구매 기록이에요.\n삭제하면 제품 자체도 함께 삭제돼요.")
        }
    }

    // MARK: - 제품 수정 Sheet
    private var editProductSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    formSection(title: "제품 정보", icon: "tag.fill") {
                        VStack(spacing: 0) {

                            fieldRow {
                                HStack {
                                    Text("제품명").font(.subheadline)
                                    Spacer()
                                    TextField("제품명", text: $editName)
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
                                                editCategory = cat
                                            } label: {
                                                Label(cat.rawValue, systemImage: cat.icon)
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: editCategory.icon).font(.caption)
                                            Text(editCategory.rawValue).font(.subheadline)
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
                                    Picker("", selection: $editUnitType) {
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
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("제품 정보 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { isEditing = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        saveEdit()
                    }
                    .fontWeight(.semibold)
                    .disabled(editName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    // MARK: - 제품명 헤더
    private var productTitleHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: product.category.icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(product.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
    }

    // MARK: - 통계 섹션
    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statCard(title: "총 구매 횟수",
                         value: "\(product.purchaseRecords.count)회",
                         icon: "bag.fill", color: .blue)
                statCard(title: "평균 구매 주기",
                         value: product.averageCycleDays.map { "\(Int($0))일" } ?? "데이터 부족",
                         icon: "arrow.clockwise", color: .green)
            }
            HStack(spacing: 12) {
                statCard(title: "마지막 구매일",
                         value: product.lastPurchaseDate?.koreanFormatted ?? "기록 없음",
                         icon: "calendar", color: .orange, smallText: true)
                statCard(title: "다음 예상 구매일",
                         value: product.nextExpectedDate?.koreanFormatted ?? "데이터 부족",
                         icon: "calendar.badge.clock", color: .purple, smallText: true)
            }
        }
        .padding(.horizontal, 16)
    }

    private func statCard(title: String, value: String, icon: String,
                          color: Color, smallText: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption).foregroundColor(color)
                Text(title).font(.caption).foregroundColor(.secondary)
            }
            Text(value)
                .font(smallText ? .subheadline : .title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 구매 이력 섹션
    private var purchaseHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.accentColor)
                Text("구매 이력")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            if sortedRecords.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bag")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("구매 기록이 없어요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("+ 버튼으로 구매 기록을 추가해보세요")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
                        purchaseRecordRow(record: record, index: index)
                        if index < sortedRecords.count - 1 {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - 구매 기록 행
    private func purchaseRecordRow(record: PurchaseRecord, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(index == 0 ? Color.accentColor : Color(.tertiarySystemBackground))
                    .frame(width: 28, height: 28)
                Text("\(sortedRecords.count - index)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(index == 0 ? .white : .secondary)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(record.date.koreanFormatted)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    if !record.store.isEmpty {
                        Text(record.store)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 12) {
                    if record.price > 0 {
                        Label("\(Int(record.price))원", systemImage: "wonsign.circle.fill")
                            .font(.caption)
                    }
                    if record.quantity > 1 {
                        Label("\(record.quantity)개", systemImage: "number.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let ppu = record.pricePerUnit {
                        Label(
                            "\(ppu.unit)\(product.unitType.rawValue)당 \(Int(ppu.amount.rounded()))원",
                            systemImage: "sparkles"
                        )
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    }
                }

                if !record.memo.isEmpty {
                    Text(record.memo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if index < sortedRecords.count - 1 {
                    let prevRecord = sortedRecords[index + 1]
                    let days = Calendar.current.dateComponents(
                        [.day], from: prevRecord.date, to: record.date
                    ).day ?? 0
                    Text(formatInterval(days: days))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                recordToDelete = record
                // ✅ 마지막 이력이면 제품 삭제 Alert, 아니면 기록만 삭제 Alert
                if product.purchaseRecords.count == 1 {
                    showDeleteProductAlert = true
                } else {
                    showDeleteRecordAlert = true
                }
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.6))
            }
            .padding(.top, 2)
        }
        .padding(14)
    }

    // MARK: - 저장
    private func saveEdit() {
        product.name = editName.trimmingCharacters(in: .whitespaces)
        product.category = editCategory
        product.unitType = editUnitType
        try? modelContext.save()
        isEditing = false
    }

    // MARK: - 삭제
    private func deleteRecord(_ record: PurchaseRecord) {
        let isLast = product.purchaseRecords.count == 1

        product.purchaseRecords.removeAll { $0.id == record.id }
        modelContext.delete(record)

        if isLast {
            // ✅ 마지막 이력이면 제품도 삭제 후 화면 닫기
            modelContext.delete(product)
            try? modelContext.save()
            dismiss()
        } else {
            try? modelContext.save()
        }
    }

    // MARK: - UI Helpers
    private var divider: some View {
        Divider().padding(.leading, 16)
    }

    private func formSection<Content: View>(
        title: String, icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption).foregroundColor(.accentColor)
                Text(title).font(.footnote).fontWeight(.semibold).foregroundColor(.secondary)
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
    
    private func formatInterval(days: Int) -> String {
        switch days {
        case 0:
            return "같은 날 구매"
        case 1:
            return "이전 구매로부터 1일 후"
        case 2..<14:
            // 2일 ~ 13일: 일수만 표시
            return "이전 구매로부터 \(days)일 후"
        case 14..<60:
            // 14일 ~ 59일: 주 + 일수
            let weeks = days / 7
            return "이전 구매로부터 약 \(weeks)주 후(\(days)일)"
        case 60..<365:
            // 60일 ~ 364일: 개월 + 일수
            // 30.4375 = 365 ÷ 12 (1개월 평균 일수)
            let months = Int((Double(days) / 30.4375).rounded())
            return "이전 구매로부터 약 \(months)개월 후(\(days)일)"
        default:
            // 365일 이상: 년 + 개월 + 일수
            let years = days / 365
            let remainingDays = days % 365
            let months = Int((Double(remainingDays) / 30.4375).rounded())
            if months == 0 {
                return "이전 구매로부터 약 \(years)년 후(\(days)일)"
            }
            return "이전 구매로부터 약 \(years)년 \(months)개월 후(\(days)일)"
        }
    }
}
