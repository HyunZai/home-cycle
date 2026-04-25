import SwiftUI
import SwiftData

struct MaintenanceHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: MaintenanceTask

    @State private var showAddRecord = false
    @State private var showDeleteAlert = false
    @State private var recordToDelete: MaintenanceRecord? = nil

    var sortedRecords: [MaintenanceRecord] {
        task.records.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // 상태 카드
                    statusCard

                    // 이력 섹션
                    historySection
                }
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(task.taskName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddRecord = true
                    } label: {
                        Image(systemName: "plus").fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showAddRecord) {
                AddMaintenanceSheet(task: task)
            }
            .alert("기록 삭제", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    if let record = recordToDelete {
                        task.records.removeAll { $0.id == record.id }
                        modelContext.delete(record)
                        try? modelContext.save()
                    }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("이 관리 기록을 삭제할까요?")
            }
        }
    }

    // MARK: - 상태 카드
    private var statusCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statBox(
                    title: "관리 주기",
                    value: intervalText,
                    icon: "arrow.clockwise",
                    color: .blue
                )
                statBox(
                    title: "총 관리 횟수",
                    value: "\(task.records.count)회",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            HStack(spacing: 12) {
                statBox(
                    title: "마지막 관리일",
                    value: task.lastMaintenanceDate?.koreanFormatted ?? "기록 없음",
                    icon: "calendar",
                    color: .orange,
                    small: true
                )
                statBox(
                    title: "다음 관리 예정일",
                    value: task.nextMaintenanceDate?.koreanFormatted ?? "기록 후 계산",
                    icon: "calendar.badge.clock",
                    color: .purple,
                    small: true
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private var intervalText: String {
        let days = task.intervalDays
        if days < 30 { return "\(days)일" }
        else if days < 365 {
            let months = Int((Double(days) / 30.4375).rounded())
            return "약 \(months)개월"
        } else {
            let years = Int((Double(days) / 365).rounded())
            return "약 \(years)년"
        }
    }

    private func statBox(title: String, value: String,
                         icon: String, color: Color, small: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption).foregroundColor(color)
                Text(title).font(.caption).foregroundColor(.secondary)
            }
            Text(value)
                .font(small ? .subheadline : .title3)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 이력 섹션
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption).foregroundColor(.accentColor)
                Text("관리 이력")
                    .font(.footnote).fontWeight(.semibold).foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            if sortedRecords.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("관리 기록이 없어요")
                        .font(.subheadline).foregroundColor(.secondary)
                    Text("+ 버튼으로 관리 기록을 추가해보세요")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
                        recordRow(record: record, index: index)
                        if index < sortedRecords.count - 1 {
                            Divider().padding(.leading, 54)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - 기록 행
    private func recordRow(record: MaintenanceRecord, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(index == 0 ? Color.accentColor : Color(.tertiarySystemBackground))
                    .frame(width: 28, height: 28)
                Text("\(sortedRecords.count - index)")
                    .font(.caption2).fontWeight(.bold)
                    .foregroundColor(index == 0 ? .white : .secondary)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(record.date.koreanFormatted)
                    .font(.subheadline).fontWeight(.medium)

                if let cost = record.cost, cost > 0 {
                    Label("\(Int(cost))원", systemImage: "wonsign.circle.fill")
                        .font(.caption)
                }

                if !record.memo.isEmpty {
                    Text(record.memo)
                        .font(.caption).foregroundColor(.secondary)
                }

                if index < sortedRecords.count - 1 {
                    let prev = sortedRecords[index + 1]
                    let days = Calendar.current.dateComponents(
                        [.day], from: prev.date, to: record.date
                    ).day ?? 0
                    Text(formatInterval(days: days))
                        .font(.caption2).foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Button {
                recordToDelete = record
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.caption).foregroundColor(.red.opacity(0.6))
            }
            .padding(.top, 2)
        }
        .padding(14)
    }

    private func formatInterval(days: Int) -> String {
        switch days {
        case 0: return "같은 날 관리"
        case 1..<14: return "이전 관리로부터 \(days)일 후"
        case 14..<60:
            let weeks = days / 7
            return "이전 관리로부터 약 \(weeks)주 후(\(days)일)"
        case 60..<365:
            let months = Int((Double(days) / 30.4375).rounded())
            return "이전 관리로부터 약 \(months)개월 후(\(days)일)"
        default:
            let years = days / 365
            let remaining = Int((Double(days % 365) / 30.4375).rounded())
            return remaining == 0
                ? "이전 관리로부터 약 \(years)년 후(\(days)일)"
                : "이전 관리로부터 약 \(years)년 \(remaining)개월 후(\(days)일)"
        }
    }
}
