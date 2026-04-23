import SwiftUI
import SwiftData

struct AddApplianceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - 기기 정보
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var hasPurchaseDate: Bool = false
    @State private var memo: String = ""

    // MARK: - 관리 항목
    @State private var tasks: [TaskInput] = [TaskInput()]

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        tasks.allSatisfy { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - 기기 정보
                    formSection(title: "기기 정보", icon: "tv.fill") {
                        VStack(spacing: 0) {

                            fieldRow {
                                HStack {
                                    Text("기기명").font(.subheadline)
                                    Spacer()
                                    TextField("예) 공기청정기", text: $name)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                            }

                            divider

                            fieldRow {
                                HStack {
                                    Text("브랜드").font(.subheadline)
                                    Spacer()
                                    TextField("예) 삼성, LG (선택)", text: $brand)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                            }

                            divider

                            fieldRow {
                                Toggle(isOn: $hasPurchaseDate.animation()) {
                                    Text("구매일 입력").font(.subheadline)
                                }
                            }

                            if hasPurchaseDate {
                                divider

                                fieldRow {
                                    DatePicker("구매일자",
                                               selection: $purchaseDate,
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
                                    TextField("선택사항", text: $memo, axis: .vertical)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                        .lineLimit(1...3)
                                }
                            }
                        }
                    }

                    // MARK: - 관리 항목
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
                            Button {
                                withAnimation {
                                    tasks.append(TaskInput())
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.caption)
                                    Text("항목 추가")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            ForEach($tasks) { $task in
                                taskInputCard(task: $task)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // MARK: - 저장 버튼
                    Button {
                        saveAppliance()
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
            .navigationTitle("가전제품 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - 관리 항목 카드
    private func taskInputCard(task: Binding<TaskInput>) -> some View {
        VStack(spacing: 0) {

            // 항목명 + 삭제 버튼
            HStack {
                Image(systemName: "wrench.fill")
                    .font(.caption)
                    .foregroundColor(.accentColor)
                TextField("관리 항목명 예) 필터 교체", text: task.name)
                    .font(.subheadline)
                Spacer()
                if tasks.count > 1 {
                    Button {
                        withAnimation {
                            tasks.removeAll { $0.id == task.id }
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
            }
            .padding(14)

            Divider().padding(.leading, 14)

            // 관리 주기
            HStack {
                Text("관리 주기").font(.subheadline).foregroundColor(.secondary)
                Spacer()
                // 주기 프리셋 버튼
                HStack(spacing: 6) {
                    ForEach(IntervalPreset.allCases, id: \.self) { preset in
                        Button {
                            task.intervalDays.wrappedValue = preset.days
                        } label: {
                            Text(preset.label)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(task.intervalDays.wrappedValue == preset.days
                                    ? Color.accentColor
                                    : Color(.secondarySystemBackground))
                                .foregroundColor(task.intervalDays.wrappedValue == preset.days
                                    ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider().padding(.leading, 14)

            // 직접 입력
            HStack {
                Text("직접 입력").font(.caption).foregroundColor(.secondary)
                Spacer()
                TextField("0", value: task.intervalDays, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.subheadline)
                    .frame(width: 60)
                Text("일").font(.subheadline).foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            // 주기 미리보기
            if task.intervalDays.wrappedValue > 0 {
                Divider().padding(.leading, 14)

                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                    Text(intervalDescription(days: task.intervalDays.wrappedValue))
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 주기 설명
    private func intervalDescription(days: Int) -> String {
        switch days {
        case 1: return "매일 관리"
        case 7: return "매주 관리"
        case 14: return "2주마다 관리"
        case 30: return "매월 관리"
        case 60: return "2개월마다 관리"
        case 90: return "3개월마다 관리"
        case 180: return "6개월마다 관리"
        case 365: return "매년 관리"
        default:
            if days < 7 {
                return "\(days)일마다 관리"
            } else if days < 30 {
                let weeks = Int((Double(days) / 7).rounded())
                return "약 \(weeks)주마다 관리"
            } else if days < 365 {
                let months = Int((Double(days) / 30.4375).rounded())
                return "약 \(months)개월마다 관리"
            } else {
                let years = Int((Double(days) / 365).rounded())
                return "약 \(years)년마다 관리"
            }
        }
    }

    // MARK: - 저장
    private func saveAppliance() {
        guard isFormValid else { return }

        let appliance = Appliance(
            name: name.trimmingCharacters(in: .whitespaces),
            brand: brand.trimmingCharacters(in: .whitespaces),
            purchaseDate: hasPurchaseDate ? purchaseDate : nil,
            memo: memo.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(appliance)

        for task in tasks {
            let taskName = task.name.trimmingCharacters(in: .whitespaces)
            guard !taskName.isEmpty, task.intervalDays > 0 else { continue }

            let maintenanceTask = MaintenanceTask(
                taskName: taskName,
                intervalDays: task.intervalDays
            )
            modelContext.insert(maintenanceTask)
            maintenanceTask.appliance = appliance
            appliance.tasks.append(maintenanceTask)
        }

        try? modelContext.save()
        dismiss()
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

// MARK: - 관리 항목 입력 모델
struct TaskInput: Identifiable {
    let id = UUID()
    var name: String = ""
    var intervalDays: Int = 30
}

// MARK: - 주기 프리셋
enum IntervalPreset: CaseIterable {
    case oneMonth, threeMonths, sixMonths, oneYear

    var days: Int {
        switch self {
        case .oneMonth:    return 30
        case .threeMonths: return 90
        case .sixMonths:   return 180
        case .oneYear:     return 365
        }
    }

    var label: String {
        switch self {
        case .oneMonth:    return "1개월"
        case .threeMonths: return "3개월"
        case .sixMonths:   return "6개월"
        case .oneYear:     return "1년"
        }
    }
}
