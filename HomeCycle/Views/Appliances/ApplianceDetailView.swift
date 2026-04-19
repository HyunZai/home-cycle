import SwiftUI
struct ApplianceDetailView: View {
    let appliance: Appliance
    var body: some View { Text(appliance.name) }
}
