import SwiftUI
import SwiftData

struct ApplianceListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var appliances: [Appliance]
    
    @State private var showAddAppliance = false
    @State private var searchText = ""
    
    var filteredAppliances: [Appliance] {
        appliances.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredAppliances.isEmpty {
                    emptyStateView
                } else {
                    applianceList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("가전제품")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "기기명 검색")
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
            ForEach(filteredAppliances) { appliance in
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
            Image(systemName: searchText.isEmpty ? "washer" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            Text(searchText.isEmpty ? "등록된 가전제품이 없어요" : "검색 결과가 없어요")
                .font(.title3).fontWeight(.medium)
            Text(searchText.isEmpty ? "우측 상단 + 버튼으로 추가해보세요" : "'\(searchText)'와 일치하는 기기가 없어요")
                .font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    // MARK: - 삭제
    private func deleteAppliances(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredAppliances[index])
        }
    }
}

// MARK: - 가전 행 컴포넌트
struct ApplianceRowView: View {
    let appliance: Appliance
    
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
                Text("\(appliance.tasks.count)개 항목")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let task = urgentTask {
                HStack(spacing: 6) {
                    statusDot(task.status)
                    Text(task.taskName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let dDay = task.dDay {
                        let color: Color = dDay < 0 ? .red : dDay <= 7 ? .orange : .green
                        let text = dDay < 0 ? "D+\(abs(dDay))" : dDay == 0 ? "D-Day" : "D-\(dDay)"
                        Text(text)
                            .font(.caption2).fontWeight(.bold)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(color.opacity(0.15))
                            .foregroundStyle(color)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func statusDot(_ status: MaintenanceStatus) -> some View {
        let color: Color = {
            switch status {
            case .good:    return .green
            case .soon:    return .orange
            case .overdue: return .red
            case .unknown: return .gray
            }
        }()
        return Circle().fill(color).frame(width: 7, height: 7)
    }
}
