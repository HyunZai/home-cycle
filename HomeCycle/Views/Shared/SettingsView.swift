import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {

                // MARK: - 화면 테마
                Section {
                    ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                        Button {
                            themeManager.setTheme(theme)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: theme.icon)
                                    .frame(width: 28)
                                    .foregroundColor(.accentColor)
                                Text(theme.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if themeManager.currentTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                } header: {
                    Label("시스템 테마", systemImage: "paintbrush")
                }

                // MARK: - 백업 (UI만)
                Section {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .frame(width: 28)
                            .foregroundColor(.gray)
                        Text("iCloud 백업")
                        Spacer()
                        Text("준비 중")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                            .frame(width: 28)
                            .foregroundColor(.gray)
                        Text("iCloud 복원")
                        Spacer()
                        Text("준비 중")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Label("데이터 백업", systemImage: "externaldrive")
                }

                // MARK: - 앱 정보
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .frame(width: 28)
                            .foregroundColor(.gray)
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Label("앱 정보", systemImage: "apps.iphone")
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }
}
