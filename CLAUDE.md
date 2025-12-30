# PickUploader (ImgurUploader)

## プロジェクト概要

画像共有サイトのImgurに手軽にアップロードするためのiOSアプリ。共有した画像は一覧で確認でき、URLを簡単にコピペできる。App Storeで公開中。

[App Store Link](https://apps.apple.com/us/app/pickuploader/id6475726030?platform=iphone)

## アーキテクチャ

- **パターン**: MVVM (Model-View-ViewModel)
- **UIフレームワーク**: SwiftUI
- **データ永続化**: SwiftData
- **非同期処理**: Swift Concurrency (async/await)

## プロジェクト構造

```
ImgurUploader/
├── View/              # SwiftUIビュー
│   ├── ContentView.swift
│   ├── ListView.swift
│   ├── InfoView.swift
│   ├── BannerView.swift
│   ├── InterstitialViiew.swift
│   └── ContentViewModel.swift
├── ViewModel/         # ビジネスロジック
│   ├── ImgurService.swift
│   ├── PhotoData.swift
│   └── DropboxViewModel.swift
├── Model/            # データモデル
│   ├── Data.swift
│   └── ImgurDataModel.swift
├── Models/           # 追加のデータモデル
│   └── ImugurDataModel.swift
├── Assets.xcassets/  # 画像アセット
└── ImgurUploaderApp.swift  # アプリエントリーポイント
```

## 主要な依存関係

### 外部SDK
- **Firebase**: アナリティクスとクラッシュレポート (Crashlytics)
- **Google AdMob**: 広告表示
- **SwiftyDropbox**: Dropbox統合
- **Alamofire**: ネットワークリクエスト (画像アップロード)

### Appleフレームワーク
- **SwiftUI**: UI構築
- **SwiftData**: データ永続化
- **PhotosUI**: 写真選択 (PhotosPicker)
- **AppTrackingTransparency**: 広告トラッキング許可
- **AdSupport**: 広告識別子

## 主要コンポーネント

### ImgurUploaderApp.swift
- アプリのエントリーポイント
- Firebase初期化
- AdMob初期化 (ATT許可後)
- Dropbox API設定
- SwiftData ModelContainer設定 (ImageData.self)

### ImgurService.swift (ImgurDataViewModel)
- Imgur APIへの画像アップロード
- エンドポイント: `https://api.imgur.com/3/image`
- クライアントID認証を使用
- Alamofireでマルチパートアップロード
- アップロード状態管理 (`isUploading`)
- Crashlyticsでエラーログ記録

### ContentView.swift
- メインビュー
- PhotosPickerで写真選択
- アップロード進捗表示
- インタースティシャル広告表示

### ListView.swift
- アップロード済み画像の一覧表示
- URLコピー機能

## API設定

### 必要なAPIキー (Info.plist)
- `DROPBOX_API_KEY`: Dropbox API設定用

### ハードコード値
- **Imgur Client ID**: `ImgurService.swift`内にハードコードされている (`d6ee7fa84ca8bd2`)

## 開発時の注意点

### コーディング規則
- SwiftUI + Swift Concurrencyを使用
- `@Observable`マクロでViewModelを作成
- ViewModelは`@MainActor`でマーク (UI更新のため)
- エラーハンドリングはCrashlyticsでログ記録

### データモデル
- SwiftDataの`ImageData`モデルを使用
- アップロード履歴を永続化

### 広告実装
- iOS 14以降はATT許可が必要
- 許可状態に関わらずAdMob初期化
- バナー広告とインタースティシャル広告を使用

### 画像処理
- JPEGに変換してアップロード (圧縮率: 1.0)
- PhotosPickerで`.images`のみ選択可能

## Git情報

- **メインブランチ**: `main`
- **最新コミット**: toastの追加、画像サイズ変更、Webページを開く機能など

## 言語

- コメント、変数名: 日本語と英語が混在
- ユーザー向けテキスト: 主に英語
- README: 日本語

## トラブルシューティング

### よくある問題
- Firebase設定ファイル (`GoogleService-Info.plist`) が必要
- Dropbox APIキーはInfo.plistに設定
- Imgur Client IDは変更される可能性あり
- iOS 14未満のサポート有無を確認

## テスト

- `ImgurUploaderTests/`: ユニットテスト
- `ImgurUploaderUITests/`: UIテスト
