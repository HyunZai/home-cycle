import Foundation
import Combine
import SwiftUI

enum AppTheme: String, CaseIterable, Hashable {
    case system = "시스템"
    case light  = "라이트"
    case dark   = "다크"
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

final class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "appTheme") ?? ""
        self.currentTheme = AppTheme(rawValue: saved) ?? .system
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
    }
}
