import SwiftUI
import SwiftData

struct MainTabView: View {
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            EssentialsListView()
                .tabItem {
                    Label("생필품", systemImage: "cart.fill")
                }

            ApplianceListView()
                .tabItem {
                    Label("가전제품", systemImage: "washer.fill")
                }
        }
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
}
