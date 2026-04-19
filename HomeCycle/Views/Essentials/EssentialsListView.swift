import SwiftUI
import SwiftData

struct EssentialsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Product]
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var selectedCategory: ProductCategory? = nil
    @State private var showAddProduct = false
    @State private var showSettings = false
    @State private var searchText = ""
    
    var filteredProducts: [Product] {
        products
            .filter { selectedCategory == nil || $0.category == selectedCategory }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilterBar
                
                if filteredProducts.isEmpty {
                    emptyStateView
                } else {
                    productList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("생필품")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "제품명 검색")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddProduct = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showAddProduct) {
                AddProductView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(themeManager)
            }
        }
    }
    
    // MARK: - 카테고리 필터 바
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "전체", icon: "square.grid.2x2", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    filterChip(title: category.rawValue, icon: category.icon, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    private func filterChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
    
    // MARK: - 제품 리스트
    private var productList: some View {
        List {
            ForEach(filteredProducts) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductRowView(product: product)
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete(perform: deleteProducts)
        }
        .listStyle(.plain)
    }
    
    // MARK: - 빈 상태
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: searchText.isEmpty ? "cart" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            Text(searchText.isEmpty ? "등록된 생필품이 없어요" : "검색 결과가 없어요")
                .font(.title3).fontWeight(.medium)
            Text(searchText.isEmpty ? "우측 상단 + 버튼으로 추가해보세요" : "'\(searchText)'와 일치하는 제품이 없어요")
                .font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    private func deleteProducts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredProducts[index])
        }
    }
}

// MARK: - ProductRowView
struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: product.category.icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(product.name)
                    .font(.headline)
                Spacer()
                if let nextDate = product.nextExpectedDate {
                    nextDateBadge(date: nextDate)
                }
            }
            HStack(spacing: 12) {
                // ✅ 한국어 날짜 포맷 적용
                if let lastDate = product.lastPurchaseDate {
                    Label(lastDate.koreanFormatted, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let cycle = product.averageCycleDays {
                    Label("평균 \(Int(cycle))일", systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !product.purchaseRecords.isEmpty {
                    Label("\(product.purchaseRecords.count)회", systemImage: "bag")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func nextDateBadge(date: Date) -> some View {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        let color: Color = days < 0 ? .red : days <= 7 ? .orange : .green
        let text = days < 0 ? "D+\(abs(days))" : days == 0 ? "D-Day" : "D-\(days)"
        
        Text(text)
            .font(.caption2).fontWeight(.bold)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
