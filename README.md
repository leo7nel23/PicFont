# PicFont

PicFont 是一用來實現 Google Font 的應用程式，是基於 `https://developers.google.com/fonts/docs/developer_api` 提供之API進行資訊擷取。

## System Requirements
本專案是基於 XCode 14.0 和 Swift 5.6.1 開發，deplyment target 為 iOS 16.0。

--

## 程式架構

PicFont 是基於 VIP 架構做為開發基礎，並加入 BLoC Pattern 將商業邏輯拆分，已達到可測性與重用性。
資料取得部分，將透過 `Session` 來取得 Google Font 資訊。

### Coordinator

Coordinator 包含
- AppCoordinator
用於驅動App初始頁面 - UINavigationController


## GoogleFontViewController

這個Controller 是App的主要畫面，包含 
- UITableView 顯示 Font 及 Subsets 
- UIStackView + UIScrollView 顯示 family + subset 內容
- UILable 用於預覽字型

程式架構圖
![CleanShot 2022-09-26 at 23 15 57](https://user-images.githubusercontent.com/8021888/192314902-94f514b4-d9d8-4f96-8f75-7735555d4cf0.png)


## 主要技術
- Combine
- `CTFontManagerRegisterGraphicsFont`
- Swift Package Manager 達成模組拆分
