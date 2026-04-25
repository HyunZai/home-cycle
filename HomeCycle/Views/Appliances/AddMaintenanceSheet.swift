import SwiftUI
import SwiftData

struct AddMaintenanceSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: MaintenanceTask

    @State private var date: Date = Date()
    @State private var costText: String = ""
    @State private var memo: String = ""

    private var cost: Double? {
        let val = Double(costText.filter { $0.isNumber })
        return val == 0 ? nil : val
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // 항목 헤더
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.accentColor.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: "wrench.fill")
                                .foregroundColor(.accentColor)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.taskName).font(.headline)
                            Text(task.appliance?.name ?? "").font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)

                    VStack(spacing: 0) {

                        HStack {
                            DatePicker("관리일자", selection: $date,
                                       displayedComponents: .date)
                            .font(.subheadline)
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                        }
                        .padding(16)

                        Divider().padding(.leading, 16)

                        HStack {
                            Text("비용").font(.subheadline)
                            Spacer()
                            TextField("0", text: $costText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .font(.subheadline)
                                .frame(width: 120)
                                .onChange(of: costText) { _, newValue in
                                    let digits = newValue.filter { $0.isNumber }
                                    if let number = Int(digits) {
                                        let formatter = NumberFormatter()
                                        formatter.numberStyle = .decimal
                                        costText = formatter.string(
                                            from: NSNumber(value: number)) ?? digits
                                    } else {
                                        costText = digits
                                    }
                                }
                            Text("원").font(.subheadline).foregroundColor(.secondary)
                        }
                        .padding(16)

                        Divider().padding(.leading, 16)

                        HStack(alignment: .top) {
                            Text("메모").font(.subheadline)
                            Spacer()
                            TextField("선택사항", text: $memo, axis: .vertical)
                                .multilineTextAlignment(.trailing)
                                .font(.subheadline)
                                .lineLimit(1...3)
                        }
                        .padding(16)
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)

                    Button {
                        saveRecord()
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
            .navigationTitle("관리 기록 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func saveRecord() {
        let record = MaintenanceRecord(
            date: date,
            cost: cost,
            memo: memo.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(record)
        task.records.append(record)
        try? modelContext.save()
        dismiss()
    }
}
