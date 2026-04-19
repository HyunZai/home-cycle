<div align="center">

# 🏠 HomeCycle

**생필품 구매 주기 & 가전제품 관리 iOS 앱**

[![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-0071E3?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/SwiftData-1.0-34C759?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/xcode/swiftdata/)
[![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=flat-square&logo=apple&logoColor=white)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

<br/>

> 💡 *"언제 샴푸 샀더라?", "공기청정기 필터 언제 갈아야 하지?"*
> 일상의 소소한 물음에서 시작된 개인 라이프스타일 관리 앱

<br/>

<!-- 스크린샷 섹션 (추후 이미지 추가) -->
<!--
<img src="./screenshots/essentials_list.png" width="200">
<img src="./screenshots/product_detail.png" width="200">
<img src="./screenshots/appliance_list.png" width="200">
-->

</div>

---

## 📌 프로젝트 소개

**HomeCycle**은 생활 속에서 반복적으로 구매하는 생필품의 구매 주기를 파악하고, 가전제품의 관리 일정을 체계적으로 관리하기 위한 개인용 iOS 앱입니다.

구매 기록이 쌓일수록 **평균 구매 주기가 자동으로 계산**되며, 다음 구매 예정일을 D-Day 형식으로 확인할 수 있습니다. 가전제품은 필터 교체, 청소 등 항목별 관리 주기를 설정하면 **다음 관리일을 자동으로 계산**해 줍니다.

---

## ✨ 주요 기능

### 🛒 생필품 관리
- 카테고리별 생필품 등록 및 관리 (욕실 / 주방 / 건강 / 리빙 / 기타)
- 구매 기록 누적을 통한 **평균 구매 주기 자동 계산**
- 다음 예상 구매일 **D-Day 뱃지** 표시 (여유 🟢 / 임박 🟡 / 초과 🔴)
- ml·g 단위 제품의 **100ml당 가격 자동 계산** (용량 대비 가성비 비교)
- 다중 구매 수량 입력 지원 (미입력 시 단품 1개로 자동 인식)
- 제품명 **실시간 검색** 기능

### 🔧 가전제품 관리
- 기기별 다중 관리 항목 등록 (예: 공기청정기 → 필터 교체, 본체 청소)
- 관리 주기 설정 → **다음 관리 예정일 자동 계산**
- 관리 이력 누적 및 비용 기록
- 상태별 컬러 인디케이터 (여유 / 임박 / 초과 / 기록없음)

### ⚙️ 설정 & UX
- **다크모드 / 라이트모드 / 시스템 테마** 선택 지원
- UserDefaults 기반 테마 설정 영구 저장
- 한국어 날짜 포맷 (`2026년 4월 16일`)
- 스와이프로 항목 삭제
- 데이터 백업 / 복원 UI (iCloud — 추후 구현 예정)

---

## 🛠 기술 스택

| 구분 | 기술 |
|---|---|
| **Language** | Swift 5.9 |
| **UI Framework** | SwiftUI 5.0 |
| **데이터 저장** | SwiftData (온디바이스 SQLite) |
| **아키텍처** | Repository Pattern + MVVM |
| **상태 관리** | `@Query`, `@Environment`, `@EnvironmentObject` |
| **비동기** | 동기 처리 (추후 async/await 확장 예정) |
| **테마 관리** | `ObservableObject` + `UserDefaults` |
| **최소 타겟** | iOS 17.0+ |
| **개발 도구** | Xcode 16, Git, GitHub |

---

## 🏗 아키텍처

```
HomeCycle/
├── App/
│   └── HomeCycleApp.swift          # 앱 진입점, ModelContainer 설정
│
├── Models/                          # SwiftData 모델 레이어
│   ├── Product.swift               # 생필품 모델 (평균주기, 다음구매일 계산)
│   ├── PurchaseRecord.swift        # 구매 기록 (100ml당 가격, 총가격 계산)
│   ├── Appliance.swift             # 가전제품 모델
│   ├── MaintenanceTask.swift       # 관리 항목 (D-Day, 상태 계산)
│   └── MaintenanceRecord.swift     # 관리 이력
│
├── Views/
│   ├── Essentials/                  # 생필품 관련 화면
│   │   ├── EssentialsListView.swift
│   │   ├── ProductDetailView.swift
│   │   ├── AddProductView.swift
│   │   └── AddPurchaseSheet.swift
│   ├── Appliances/                  # 가전제품 관련 화면
│   │   ├── ApplianceListView.swift
│   │   ├── ApplianceDetailView.swift
│   │   └── AddMaintenanceSheet.swift
│   └── Shared/                      # 공통 화면
│       ├── MainTabView.swift
│       └── SettingsView.swift
│
├── ViewModels/
│   ├── EssentialsViewModel.swift
│   └── ApplianceViewModel.swift
│
├── Repositories/
│   └── LocalRepository.swift       # 데이터 접근 추상화 (마이그레이션 대비)
│
└── Utils/
    ├── DateHelper.swift             # 한국어 날짜 포맷 Extension
    └── ThemeManager.swift           # 다크모드 상태 관리
```

### Repository 패턴 적용 이유

> 현재는 온디바이스 SwiftData를 사용하지만, 추후 서비스화 시 REST API 서버로의 마이그레이션을 고려해 데이터 접근 레이어를 `Repository Protocol`로 추상화했습니다. ViewModel은 데이터 소스에 의존하지 않아 코드 변경 없이 `LocalRepository` → `RemoteRepository` 교체가 가능합니다.

---

## 📊 데이터 모델

```
Product ──────────────── PurchaseRecord
  │  id: UUID               id: UUID
  │  name: String           date: Date
  │  category: Enum         store: String
  │  unitType: Enum         price: Double
  │  createdAt: Date        volume: Double?
  │                         quantity: Int
  │                         memo: String
  │
  └── [계산 프로퍼티]
       averageCycleDays: Double?   // 구매 기록 2개 이상 시 자동 계산
       nextExpectedDate: Date?     // 마지막 구매일 + 평균 주기
       lastPurchaseDate: Date?
       pricePerHundred: Double?    // (price / volume) × 100


Appliance ────────────── MaintenanceTask ──── MaintenanceRecord
  id: UUID                  id: UUID             id: UUID
  name: String              taskName: String     date: Date
  brand: String             intervalDays: Int    cost: Double?
  purchaseDate: Date?       createdAt: Date      memo: String
  memo: String
                        └── [계산 프로퍼티]
                             lastMaintenanceDate: Date?
                             nextMaintenanceDate: Date?
                             dDay: Int?
                             status: MaintenanceStatus
```

---

## 🚀 시작하기

### 요구 사항
- macOS 14 Sonoma 이상
- Xcode 16 이상
- iOS 17.0 이상 디바이스 또는 시뮬레이터

### 설치 및 실행

```bash
# 레포지토리 클론
git clone https://github.com/HyunZai/home-cycle.git

# Xcode에서 열기
cd home-cycle
open HomeCycle.xcodeproj
```

Xcode에서 타겟 기기 선택 후 `Cmd + R` 로 실행

---

## 🗺 개발 로드맵

- [x] 프로젝트 기초 세팅 (SwiftData 모델, Repository 패턴)
- [x] 생필품 목록 화면 (카테고리 필터, 검색, D-Day 뱃지)
- [x] 가전제품 목록 화면 (상태 인디케이터)
- [x] 생필품 추가 화면 (100ml당 가격 자동 계산, 수량 입력)
- [x] 다크모드 지원 및 설정 화면
- [ ] 생필품 상세 화면 (구매 이력, 통계)
- [ ] 가전제품 상세 화면 (관리 이력)
- [ ] 구매 기록 추가 시트
- [ ] 관리 기록 추가 시트
- [ ] 로컬 푸시 알림 (구매 예정일 N일 전)
- [ ] iCloud 백업 / 복원 (CloudKit)
- [ ] 위젯 지원 (홈 화면 D-Day 위젯)

---

## 💡 개발 배경

일상에서 생필품을 구매할 때마다 *"이거 언제 샀더라?"*, *"용량이 더 큰 게 더 저렴한 건가?"* 같은 의문이 반복됐습니다. 또 공기청정기 필터 교체 시기를 놓치는 경험이 쌓이면서, 이를 체계적으로 관리할 간단한 앱이 필요하다고 느꼈습니다.

기존의 가계부 앱이나 메모 앱으로는 **주기 분석**과 **관리 일정** 기능을 충족할 수 없었고, 이것이 HomeCycle을 직접 만들게 된 계기입니다.

---

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

---

<div align="center">

Made with ❤️ by [HyunZai](https://github.com/HyunZai)

</div>
