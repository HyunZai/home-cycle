import SwiftUI
import SwiftData

struct ApplianceListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var appliances: [Appliance]
    
    @State private var showAddAppliance = false
    
    var body: some View {
        NavigationStack {
            Group {
                if appliances.isEmpty {
                    emptyStateView
                } else {
                    applianceList
                }
            }
            .navigationTitle("가전제품")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddAppliance = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showAddAppliance) {
                AddApplianceView()
            }
        }
    }
    
    // MARK: - 가전 리스트
    private var applianceList: some View {
        List {
            ForEach(appliances) { appliance in
                NavigationLink(destination: ApplianceDetailView(appliance: appliance)) {
                    ApplianceRowView(appliance: appliance)
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete(perform: deleteAppliances)
        }
        .listStyle(.plain)
    }
    
    // MARK: - 빈 상태
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "washer")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            Text("등록된 가전제품이 없어요")
                .font(.title3)
                .fontWeight(.medium)
            Text("우측 상단 + 버튼으로 추가해보세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    // MARK: - 삭제
    private func deleteAppliances(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(appliances[index])
        }
    }
}

// MARK: - 가전 행 컴포넌트
struct ApplianceRowView: View {
    let appliance: Appliance
    
    // 가장 긴급한 태스크 추출
    var urgentTask: MaintenanceTask? {
        appliance.tasks
            .filter { $0.nextMaintenanceDate != nil }
            .min(by: { ($0.dDay ?? 999) < ($1.dDay ?? 999) })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(appliance.name)
                        .font(.headline)
                    if !appliance.brand.isEmpty {
                        Text(appliance.brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // 관리 항목 수
                Text("\(appliance.tasks.count)개 항목")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // 가장 임박한 관리 항목 표시
            if let task = urgentTask {
                HStack(spacing: 6) {
                    statusDot(task.status)
                    Text(task.taskName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let next = task.nextMaintenanceDate {
                        Text(next.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func statusDot(_ status: MaintenanceStatus) -> some View {
        let color: Color = {
            switch status {
            case .good:    return .green
            case .soon:    return .orange
            case .overdue: return .red
            case .unknown: return .gray
            }
        }()
        Circle()
            .fill(color)
            .frame(width: 7, height: 7)
    }
}
