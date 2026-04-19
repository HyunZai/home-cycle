import SwiftUI
import SwiftData

@main
struct HomeCycleApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [
            Product.self,
            PurchaseRecord.self,
            Appliance.self,
            MaintenanceTask.self,
            MaintenanceRecord.self
        ])
    }
}
