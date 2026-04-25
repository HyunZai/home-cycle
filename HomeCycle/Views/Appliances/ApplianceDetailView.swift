import SwiftUI
import SwiftData

struct ApplianceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var appliance: Appliance

    @State private var isEditing = false
    @State private var editName: String = ""
    @State private var editBrand: String = ""
    @State private var editMemo: String = ""
    @State private var editHasPurchaseDate: Bool = false
    @State private var editPurchaseDate: Date = Date()

    @State private var showAddTask = false
    @State private var selectedTask: MaintenanceTask? = nil
    @State private var showDeleteApplianceAlert = false

    var sortedTasks: [MaintenanceTask] {
        appliance.tasks.sorted { ($0.dDay ?? 999) < ($1.dDay ?? 999) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - 기기 헤더
                applianceHeader

                // MARK: - 관리 항목 리스트
                taskListSection
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(appliance.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    Button {
                        editName = appliance.name
                        editBrand = appliance.brand
                        editMemo = appliance.memo
                        editHasPurchaseDate = appliance.purchaseDate != nil
                        editPurchaseDate = appliance.purchaseDate ?? Date()
                        isEditing = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet(appliance: appliance)
        }
        .sheet(item: $selectedTask) { task in
            MaintenanceHistoryView(task: task)
        }
        .sheet(isPresented: $isEditing) {
            editApplianceSheet
        }
        .alert("가전제품 삭제", isPresented: $showDeleteApplianceAlert) {
            Button("삭제", role: .destructive) {
                modelContext.delete(appliance)
                try? modelContext.save()
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("모든 관리 항목과 이력이 함께 삭제돼요.")
        }
    }

    // MARK: - 기기 헤더
    private var applianceHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(appliance.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    if !appliance.brand.isEmpty {
                        Text(appliance.brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()

                // 전체 상태 뱃지
                overallStatusBadge
            }
            .padding(16)

            if let purchaseDate = appliance.purchaseDate {
                Divider().padding(.horizontal, 16)
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("구매일: \(purchaseDate.koreanFormatted)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    let days = Calendar.current.dateComponents(
                        [.day], from: purchaseDate, to: Date()
                    ).day ?? 0
                    Text("사용 \(days)일째")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }

            if !appliance.memo.isEmpty {
                Divider().padding(.horizontal, 16)
                HStack {
                    Text(appliance.memo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }

            // 삭제 버튼
            Divider().padding(.horizontal, 16)
            Button {
                showDeleteApplianceAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .font(.caption)
                    Text("이 가전제품 삭제")
                        .font(.caption)
                }
                .foregroundColor(.red.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
    }

    // MARK: - 전체 상태 뱃지
    @ViewBuilder
    private var overallStatusBadge: some View {
        let statuses = appliance.tasks.map { $0.status }
        let worstStatus: MaintenanceStatus = {
            if statuses.contains(.overdue)  { return .overdue }
            if statuses.contains(.soon)     { return .soon }
            if statuses.contains(.good)     { return .good }
            return .unknown
        }()

        let (color, label, icon): (Color, String, String) = {
            switch worstStatus {
            case .overdue: return (.red,    "관리 필요",  "exclamationmark.circle.fill")
            case .soon:    return (.orange, "임박",       "clock.fill")
            case .good:    return (.green,  "정상",       "checkmark.circle.fill")
            case .unknown: return (.gray,   "기록없음",   "minus.circle")
            }
        }()

        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(label).font(.caption2).fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .clipShape(Capsule())
    }

    // MARK: - 관리 항목 리스트
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.caption)
                    .foregroundColor(.accentColor)
                Text("관리 항목")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(appliance.tasks.count)개")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            if appliance.tasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("관리 항목이 없어요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("+ 버튼으로 관리 항목을 추가해보세요")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 10) {
                    ForEach(sortedTasks) { task in
                        taskCard(task: task)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - 관리 항목 카드
    private func taskCard(task: MaintenanceTask) -> some View {
        Button {
            selectedTask = task
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 12) {

                    // 상태 인디케이터
                    statusCircle(task.status)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.taskName)
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack(spacing: 8) {
                            // 주기
                            Label(intervalDescription(days: task.intervalDays),
                                  systemImage: "arrow.clockwise")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            // 총 관리 횟수
                            if !task.records.isEmpty {
                                Label("\(task.records.count)회",
                                      systemImage: "checkmark.circle")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    // D-Day
                    VStack(alignment: .trailing, spacing: 4) {
                        dDayBadge(task: task)

                        if let nextDate = task.nextMaintenanceDate {
                            Text(nextDate.koreanFormatted)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else {
                            Text("기록 후 계산")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(14)

                // 마지막 관리일
                if let lastDate = task.lastMaintenanceDate {
                    Divider().padding(.horizontal, 14)
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("마지막 관리: \(lastDate.koreanFormatted)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 상태 원형 인디케이터
    private func statusCircle(_ status: MaintenanceStatus) -> some View {
        let color: Color = {
            switch status {
            case .good:    return .green
            case .soon:    return .orange
            case .overdue: return .red
            case .unknown: return .gray
            }
        }()
        return ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
        }
    }

    // MARK: - D-Day 뱃지
    @ViewBuilder
    private func dDayBadge(task: MaintenanceTask) -> some View {
        if let dDay = task.dDay {
            let color: Color = dDay < 0 ? .red : dDay <= 7 ? .orange : .green
            let text = dDay < 0 ? "D+\(abs(dDay))" : dDay == 0 ? "D-Day" : "D-\(dDay)"
            Text(text)
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(color.opacity(0.12))
                .foregroundColor(color)
                .clipShape(Capsule())
        } else {
            Text("미기록")
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.gray.opacity(0.12))
                .foregroundColor(.gray)
                .clipShape(Capsule())
        }
    }

    // MARK: - 주기 설명
    private func intervalDescription(days: Int) -> String {
        switch days {
        case 1:   return "매일"
        case 7:   return "매주"
        case 14:  return "2주마다"
        case 30:  return "매월"
        case 90:  return "3개월마다"
        case 180: return "6개월마다"
        case 365: return "매년"
        default:
            if days < 30 {
                return "\(days)일마다"
            } else if days < 365 {
                let months = Int((Double(days) / 30.4375).rounded())
                return "약 \(months)개월마다"
            } else {
                let years = Int((Double(days) / 365).rounded())
                return "약 \(years)년마다"
            }
        }
    }

    // MARK: - 기기 정보 수정 Sheet
    private var editApplianceSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    formSection(title: "기기 정보", icon: "tv.fill") {
                        VStack(spacing: 0) {

                            fieldRow {
                                HStack {
                                    Text("기기명").font(.subheadline)
                                    Spacer()
                                    TextField("기기명", text: $editName)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                            }

                            divider

                            fieldRow {
                                HStack {
                                    Text("브랜드").font(.subheadline)
                                    Spacer()
                                    TextField("선택사항", text: $editBrand)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                            }

                            divider

                            fieldRow {
                                Toggle(isOn: $editHasPurchaseDate.animation()) {
                                    Text("구매일 입력").font(.subheadline)
                                }
                            }

                            if editHasPurchaseDate {
                                divider
                                fieldRow {
                                    DatePicker("구매일자",
                                               selection: $editPurchaseDate,
                                               displayedComponents: .date)
                                    .font(.subheadline)
                                    .environment(\.locale, Locale(identifier: "ko_KR"))
                                }
                            }

                            divider

                            fieldRow {
                                HStack(alignment: .top) {
                                    Text("메모").font(.subheadline)
                                    Spacer()
                                    TextField("선택사항", text: $editMemo, axis: .vertical)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                        .lineLimit(1...3)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("기기 정보 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { isEditing = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        appliance.name = editName.trimmingCharacters(in: .whitespaces)
                        appliance.brand = editBrand.trimmingCharacters(in: .whitespaces)
                        appliance.memo = editMemo.trimmingCharacters(in: .whitespaces)
                        appliance.purchaseDate = editHasPurchaseDate ? editPurchaseDate : nil
                        try? modelContext.save()
                        isEditing = false
                    }
                    .fontWeight(.semibold)
                    .disabled(editName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
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
}
