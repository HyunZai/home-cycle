import SwiftUI
import SwiftData

struct AddTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var appliance: Appliance

    @State private var taskName: String = ""
    @State private var intervalDays: Int = 30

    private var isFormValid: Bool {
        !taskName.trimmingCharacters(in: .whitespaces).isEmpty && intervalDays > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 0) {

                        HStack {
                            Text("항목명").font(.subheadline)
                            Spacer()
                            TextField("예) 필터 교체", text: $taskName)
                                .multilineTextAlignment(.trailing)
                                .font(.subheadline)
                        }
                        .padding(16)

                        Divider().padding(.leading, 16)

                        // 프리셋
                        HStack {
                            Text("관리 주기").font(.subheadline).foregroundColor(.secondary)
                            Spacer()
                            HStack(spacing: 6) {
                                ForEach(IntervalPreset.allCases, id: \.self) { preset in
                                    Button {
                                        intervalDays = preset.days
                                    } label: {
                                        Text(preset.label)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(intervalDays == preset.days
                                                ? Color.accentColor
                                                : Color(.secondarySystemBackground))
                                            .foregroundColor(intervalDays == preset.days
                                                ? .white : .primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        Divider().padding(.leading, 16)

                        HStack {
                            Text("직접 입력").font(.caption).foregroundColor(.secondary)
                            Spacer()
                            TextField("0", value: $intervalDays, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .font(.subheadline)
                                .frame(width: 60)
                            Text("일").font(.subheadline).foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)

                    Button {
                        saveTask()
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
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("관리 항목 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }

    private func saveTask() {
        guard isFormValid else { return }
        let task = MaintenanceTask(
            taskName: taskName.trimmingCharacters(in: .whitespaces),
            intervalDays: intervalDays
        )
        modelContext.insert(task)
        task.appliance = appliance
        appliance.tasks.append(task)
        try? modelContext.save()
        dismiss()
    }
}
