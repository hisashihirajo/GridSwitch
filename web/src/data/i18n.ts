export type Lang = 'en' | 'ja';

export const t = {
  en: {
    // Header
    features: 'Features',
    download: 'Download',
    blog: 'Blog',

    // Hero
    heroTitle1: 'A Better Way to',
    heroTitle2: 'Switch Apps',
    heroTitle3: 'on macOS',
    heroSub: 'Replace the default app switcher with a visual grid. See all your running apps at a glance and switch instantly.',
    heroShortcut1: 'Just press',
    heroShortcut2: 'as you always do',
    heroDownload: 'Download for Free',
    heroLearnMore: 'Learn More',

    // Features
    featuresTitle1: 'Everything you need,',
    featuresTitle2: 'nothing you don\'t',
    featuresSub: 'Designed to feel like a native part of macOS.',
    featureGrid: 'Grid Layout',
    featureGridDesc: 'See all running apps in a clean grid view instead of a cramped horizontal strip. Find and switch to any app instantly.',
    featureSeamless: 'Seamless Activation',
    featureSeamlessDesc: 'Intercepts Cmd+Tab natively. No new shortcuts to learn — just press the same keys you already use.',
    featureNumber: 'Number Key Shortcuts',
    featureNumberDesc: 'Press 1–9 to instantly jump to any app by its position. Switch apps without even looking at the grid.',
    featureCustom: 'Fully Customizable',
    featureCustomDesc: 'Adjust icon size, background color and opacity, grid columns, and even set a custom background image.',
    featureInput: 'Multiple Input Methods',
    featureInputDesc: 'Navigate with Tab, Shift+Tab, arrow keys, or number keys. Press Q to quit the selected app on the spot.',
    featureBilingual: 'Bilingual UI',
    featureBilingualDesc: 'Full support for both Japanese and English interfaces. Automatically adapts to your preferred language.',

    // How It Works
    howTitle: 'How it works',
    howSub: 'Three simple steps. No learning curve.',
    howStep1Title: 'Press Cmd + Tab',
    howStep1Desc: 'GridSwitch intercepts the shortcut and displays a visual grid of all running applications.',
    howStep2Title: 'Navigate the Grid',
    howStep2Desc: 'Use arrow keys, Tab/Shift+Tab, or number keys (1-9) to select an app. Press Q to quit the selected app instantly.',
    howStep3Title: 'Release Cmd',
    howStep3Desc: 'Release the Command key and the selected application is instantly brought to the front.',

    // Screenshots
    screenshotsTitle: 'See it in action',
    screenshotsSub: 'A clean, beautiful interface that stays out of your way.',
    tabGrid: 'Grid View',
    tabSettings: 'Settings',
    tabBackground: 'Custom Background',
    tabNumbers: 'Number Shortcuts',

    // Comparison
    compTitle: 'Why GridSwitch?',
    compSub: 'See how it compares to the built-in app switcher.',

    // Download
    downloadTitle: 'Ready to switch better?',
    downloadSub: 'Download GridSwitch for free and transform the way you navigate between apps on macOS.',
    downloadBtn: 'Download GridSwitch',
    downloadReq1: 'Requires macOS 14.0 (Sonoma) or later',
    downloadReq2: 'Accessibility permission required for keyboard interception',
    downloadFree: 'Free and open source',
    downloadEmailHeading: 'Get notified about new products',
    downloadEmailPlaceholder: 'Enter your email address',
    downloadEmailSubmit: 'Subscribe',
    downloadEmailSubmitting: 'Submitting...',
    downloadEmailSuccess: 'Thanks for subscribing!',
    downloadEmailError: 'Something went wrong. Please try again.',
    downloadEmailInvalid: 'Please enter a valid email address.',
    downloadEmailPrivacy: 'No spam, ever. Unsubscribe anytime.',

    // Footer
    footerMade: 'Made with \u2665 in Japan',

    // Header / Footer - Manual
    manual: 'Manual',

    // Manual page
    manualTitle: 'Manual',
    manualSub: 'Everything you need to know to get started with GridSwitch.',
    manualToc: 'Table of Contents',

    // Manual - Installation
    manualInstall: 'Installation',
    manualInstallDownload: 'Download GridSwitch from the official website and move it to your Applications folder.',
    manualInstallReq: 'Requires macOS 14.0 (Sonoma) or later.',
    manualInstallAccessibility: 'Accessibility Permission',
    manualInstallAccessibilityDesc: 'GridSwitch needs Accessibility permission to intercept keyboard shortcuts. On first launch, you will be prompted to grant permission.',
    manualInstallAccessibilitySteps: 'If you need to enable it manually:',
    manualInstallStep1: 'Open System Settings',
    manualInstallStep2: 'Go to Privacy & Security > Accessibility',
    manualInstallStep3: 'Enable the toggle for GridSwitch',

    // Manual - Basic Usage
    manualBasic: 'Basic Usage',
    manualBasicOpen: 'Show the switcher',
    manualBasicOpenDesc: 'Press Cmd+Tab to open the GridSwitch panel. All running applications are displayed in a grid.',
    manualBasicSwitch: 'Switch to an app',
    manualBasicSwitchDesc: 'While holding Cmd, navigate to the desired app, then release Cmd to switch to it.',
    manualBasicCancel: 'Cancel',
    manualBasicCancelDesc: 'Press Esc to close the switcher without switching apps.',

    // Manual - Grid Navigation
    manualGrid: 'Grid Navigation',
    manualGridArrows: 'Use arrow keys to move selection in the grid.',
    manualGridTab: 'Press Tab to move to the next app, or Shift+Tab to move to the previous app.',
    manualGridCmdTab: 'Press Cmd+Tab again (while the grid is open) to move to the next app.',
    manualGridCmdShiftTab: 'Press Cmd+Shift+Tab to move to the previous app.',
    manualGridMouse: 'Click on any app icon with the mouse to select and switch to it.',

    // Manual - Number Key Shortcuts
    manualNumbers: 'Number Key Shortcuts',
    manualNumbersDesc: 'Quickly jump to any app by pressing its number key while the grid is open.',
    manualNumbers1to9: 'Press 1 through 9 to jump to the 1st through 9th app.',
    manualNumbers0: 'Press 0 to jump to the 10th app.',
    manualNumbersToggle: 'This feature can be enabled or disabled in Settings.',

    // Manual - Quit App
    manualQuit: 'Quit Apps Instantly',
    manualQuitDesc: 'While the grid is open, press Q to immediately quit the currently selected app. The app will close and be removed from the grid.',

    // Manual - Settings
    manualSettings: 'Settings',
    manualSettingsDesc: 'Open Settings from the menu bar icon to customize GridSwitch.',
    manualSettingsIconSize: 'Icon Size',
    manualSettingsIconSizeDesc: 'Adjust the size of app icons (32–128px).',
    manualSettingsCols: 'Max Columns',
    manualSettingsColsDesc: 'Set the maximum number of apps per row (4–12).',
    manualSettingsBgColor: 'Background Color & Opacity',
    manualSettingsBgColorDesc: 'Customize the background color and transparency of the switcher panel.',
    manualSettingsBgImage: 'Background Image & Opacity',
    manualSettingsBgImageDesc: 'Set a custom background image and adjust its opacity.',
    manualSettingsNumberKeys: 'Number Key Shortcuts',
    manualSettingsNumberKeysDesc: 'Enable or disable number key shortcuts (1–9, 0).',
    manualSettingsAutoLaunch: 'Launch at Login',
    manualSettingsAutoLaunchDesc: 'Automatically start GridSwitch when you log in.',
    manualSettingsLang: 'Language',
    manualSettingsLangDesc: 'Switch between Japanese and English.',
    manualSettingsHidden: 'Hidden Apps',
    manualSettingsHiddenDesc: 'Manage apps that are excluded from the grid.',

    // Manual - Menu Bar
    manualMenuBar: 'Menu Bar',
    manualMenuBarDesc: 'GridSwitch adds a grid icon to your menu bar. Click it to access:',
    manualMenuBarAbout: 'About — View version information',
    manualMenuBarSettings: 'Settings — Open the settings window',
    manualMenuBarQuit: 'Quit — Exit GridSwitch',

    // Manual - Troubleshooting
    manualTroubleshooting: 'Troubleshooting',
    manualTsNoShow: 'The switcher does not appear',
    manualTsNoShowDesc: 'Make sure Accessibility permission is granted. Go to System Settings > Privacy & Security > Accessibility and verify that GridSwitch is enabled.',
    manualTsNoResponse: 'Keys are not responding',
    manualTsNoResponseDesc: 'The EventTap may have been disabled by the system. Try restarting GridSwitch. If the problem persists, remove GridSwitch from Accessibility settings and re-add it.',

    // Comparison rows
    compLayout: 'Layout',
    compLayoutStd: 'Horizontal strip',
    compLayoutGs: 'Customizable grid',
    compNav: 'Navigation',
    compNavStd: 'Tab only',
    compNavGs: 'Tab, Arrow keys, Number keys',
    compQuit: 'Quick quit',
    compQuitStd: 'Cmd+Q (after switching)',
    compQuitGs: 'Press Q while in the grid',
    compNumber: 'Number shortcuts',
    compNumberStd: '—',
    compNumberGs: 'Press 1–9 to jump directly',
    compBg: 'Custom background',
    compBgStd: '—',
    compBgGs: 'Color, opacity, or image',
    compIcon: 'Icon size',
    compIconStd: 'Fixed',
    compIconGs: 'Adjustable (32–128px)',
    compCols: 'Grid columns',
    compColsStd: 'N/A',
    compColsGs: 'Configurable (4–12)',
    compHide: 'Hide apps',
    compHideStd: '—',
    compHideGs: 'Exclude specific apps',
    compLang: 'Language',
    compLangStd: 'System language',
    compLangGs: 'Japanese & English',
  },
  ja: {
    // Header
    features: '機能',
    download: 'ダウンロード',
    blog: 'ブログ',

    // Hero
    heroTitle1: 'macOSの',
    heroTitle2: 'アプリ切り替え',
    heroTitle3: 'をもっと快適に',
    heroSub: '標準のアプリスイッチャーをビジュアルなグリッドに置き換え。起動中のすべてのアプリを一覧表示して、瞬時に切り替え。',
    heroShortcut1: 'いつもの',
    heroShortcut2: 'をそのまま',
    heroDownload: '無料ダウンロード',
    heroLearnMore: '詳しく見る',

    // Features
    featuresTitle1: '必要なものはすべて、',
    featuresTitle2: '余計なものは一切なし',
    featuresSub: 'macOSネイティブのような使い心地を追求。',
    featureGrid: 'グリッドレイアウト',
    featureGridDesc: '横一列の窮屈な表示ではなく、すっきりしたグリッドで全アプリを一覧表示。どのアプリにも瞬時にアクセス。',
    featureSeamless: 'シームレスな起動',
    featureSeamlessDesc: 'Cmd+Tabをネイティブに傍受。新しいショートカットを覚える必要なし — いつものキーをそのまま使えます。',
    featureNumber: '数字キーショートカット',
    featureNumberDesc: '1〜9を押すだけで、位置で直接アプリにジャンプ。グリッドを見なくてもアプリを切り替え可能。',
    featureCustom: '自由にカスタマイズ',
    featureCustomDesc: 'アイコンサイズ、背景色と透過度、列数、さらに背景画像まで設定可能。',
    featureInput: '多彩な操作方法',
    featureInputDesc: 'Tab、Shift+Tab、矢印キー、数字キーで操作。Qキーで選択中のアプリをその場で終了。',
    featureBilingual: '日英バイリンガル',
    featureBilingualDesc: '日本語と英語の両方に完全対応。お好みの言語に自動的に切り替わります。',

    // How It Works
    howTitle: '使い方',
    howSub: '3ステップ。学習コストゼロ。',
    howStep1Title: 'Cmd + Tab を押す',
    howStep1Desc: 'GridSwitchがショートカットを傍受し、起動中の全アプリをグリッドで表示します。',
    howStep2Title: 'グリッドを操作',
    howStep2Desc: '矢印キー、Tab/Shift+Tab、数字キー(1-9)でアプリを選択。Qキーで選択中のアプリを即終了。',
    howStep3Title: 'Cmd を離す',
    howStep3Desc: 'Commandキーを離すと、選択したアプリが瞬時に最前面に表示されます。',

    // Screenshots
    screenshotsTitle: '実際の画面',
    screenshotsSub: 'すっきりした美しいインターフェース。作業の邪魔をしません。',
    tabGrid: 'グリッド表示',
    tabSettings: '設定',
    tabBackground: 'カスタム背景',
    tabNumbers: '数字キー',

    // Comparison
    compTitle: 'なぜGridSwitch？',
    compSub: '標準のアプリスイッチャーとの比較。',

    // Download
    downloadTitle: 'もっと快適に切り替えよう',
    downloadSub: 'GridSwitchを無料でダウンロードして、macOSでのアプリ切り替えを変革しましょう。',
    downloadBtn: 'GridSwitchをダウンロード',
    downloadReq1: 'macOS 14.0 (Sonoma) 以降が必要',
    downloadReq2: 'キーボード傍受にアクセシビリティ権限が必要',
    downloadFree: '無料・オープンソース',
    downloadEmailHeading: '新しいプロダクトの情報を受け取る',
    downloadEmailPlaceholder: 'メールアドレスを入力',
    downloadEmailSubmit: '登録する',
    downloadEmailSubmitting: '送信中...',
    downloadEmailSuccess: '登録ありがとうございます！',
    downloadEmailError: 'エラーが発生しました。もう一度お試しください。',
    downloadEmailInvalid: '正しいメールアドレスを入力してください。',
    downloadEmailPrivacy: 'スパムは送りません。いつでも解除できます。',

    // Footer
    footerMade: 'Made with \u2665 in Japan',

    // Header / Footer - Manual
    manual: 'マニュアル',

    // Manual page
    manualTitle: 'マニュアル',
    manualSub: 'GridSwitchの使い方をすべて解説します。',
    manualToc: '目次',

    // Manual - Installation
    manualInstall: 'インストール',
    manualInstallDownload: '公式サイトからGridSwitchをダウンロードし、アプリケーションフォルダに移動します。',
    manualInstallReq: 'macOS 14.0 (Sonoma) 以降が必要です。',
    manualInstallAccessibility: 'アクセシビリティ権限',
    manualInstallAccessibilityDesc: 'GridSwitchはキーボードショートカットを傍受するために、アクセシビリティ権限が必要です。初回起動時に権限の許可を求められます。',
    manualInstallAccessibilitySteps: '手動で有効にする場合：',
    manualInstallStep1: 'システム設定を開く',
    manualInstallStep2: 'プライバシーとセキュリティ > アクセシビリティ に移動',
    manualInstallStep3: 'GridSwitchのトグルを有効にする',

    // Manual - Basic Usage
    manualBasic: '基本操作',
    manualBasicOpen: 'スイッチャーを表示',
    manualBasicOpenDesc: 'Cmd+Tabを押すとGridSwitchパネルが開きます。起動中のすべてのアプリがグリッドで表示されます。',
    manualBasicSwitch: 'アプリを切り替え',
    manualBasicSwitchDesc: 'Cmdを押したまま目的のアプリに移動し、Cmdを離すと切り替わります。',
    manualBasicCancel: 'キャンセル',
    manualBasicCancelDesc: 'Escを押すとスイッチャーを閉じ、アプリを切り替えずに戻ります。',

    // Manual - Grid Navigation
    manualGrid: 'グリッド操作',
    manualGridArrows: '矢印キーでグリッド内の選択を移動します。',
    manualGridTab: 'Tabで次のアプリ、Shift+Tabで前のアプリに移動します。',
    manualGridCmdTab: 'グリッド表示中にCmd+Tabを追加で押すと、次のアプリに移動します。',
    manualGridCmdShiftTab: 'Cmd+Shift+Tabで前のアプリに移動します。',
    manualGridMouse: 'マウスでアプリアイコンをクリックして選択・切り替えできます。',

    // Manual - Number Key Shortcuts
    manualNumbers: '数字キーショートカット',
    manualNumbersDesc: 'グリッド表示中に数字キーを押すと、対応する位置のアプリにジャンプします。',
    manualNumbers1to9: '1〜9で1番目〜9番目のアプリに直接ジャンプ。',
    manualNumbers0: '0で10番目のアプリにジャンプ。',
    manualNumbersToggle: 'この機能は設定で有効/無効を切り替えられます。',

    // Manual - Quit App
    manualQuit: 'アプリの即時終了',
    manualQuitDesc: 'グリッド表示中にQキーを押すと、選択中のアプリを即座に終了します。アプリが終了しグリッドから削除されます。',

    // Manual - Settings
    manualSettings: '設定',
    manualSettingsDesc: 'メニューバーアイコンから設定を開いて、GridSwitchをカスタマイズできます。',
    manualSettingsIconSize: 'アイコンサイズ',
    manualSettingsIconSizeDesc: 'アプリアイコンのサイズを調整（32〜128px）。',
    manualSettingsCols: '最大列数',
    manualSettingsColsDesc: '1行あたりの最大アプリ数を設定（4〜12）。',
    manualSettingsBgColor: '背景色・透過率',
    manualSettingsBgColorDesc: 'スイッチャーパネルの背景色と透過率をカスタマイズ。',
    manualSettingsBgImage: '背景画像・画像透過率',
    manualSettingsBgImageDesc: 'カスタム背景画像を設定し、透過率を調整。',
    manualSettingsNumberKeys: '数字キーショートカット',
    manualSettingsNumberKeysDesc: '数字キーショートカット（1〜9、0）の有効/無効を切り替え。',
    manualSettingsAutoLaunch: 'ログイン時に起動',
    manualSettingsAutoLaunchDesc: 'ログイン時にGridSwitchを自動起動。',
    manualSettingsLang: '言語',
    manualSettingsLangDesc: '日本語と英語を切り替え。',
    manualSettingsHidden: '非表示アプリ',
    manualSettingsHiddenDesc: 'グリッドから除外するアプリを管理。',

    // Manual - Menu Bar
    manualMenuBar: 'メニューバー',
    manualMenuBarDesc: 'GridSwitchはメニューバーにグリッドアイコンを追加します。クリックすると以下にアクセスできます：',
    manualMenuBarAbout: 'About — バージョン情報を表示',
    manualMenuBarSettings: 'Settings — 設定ウィンドウを開く',
    manualMenuBarQuit: 'Quit — GridSwitchを終了',

    // Manual - Troubleshooting
    manualTroubleshooting: 'トラブルシューティング',
    manualTsNoShow: 'スイッチャーが表示されない',
    manualTsNoShowDesc: 'アクセシビリティ権限が付与されているか確認してください。システム設定 > プライバシーとセキュリティ > アクセシビリティ でGridSwitchが有効になっているか確認します。',
    manualTsNoResponse: 'キーが反応しない',
    manualTsNoResponseDesc: 'EventTapがシステムによって無効化された可能性があります。GridSwitchを再起動してください。問題が解決しない場合は、アクセシビリティ設定からGridSwitchを一度削除し、再度追加してください。',

    // Comparison rows
    compLayout: 'レイアウト',
    compLayoutStd: '横一列',
    compLayoutGs: 'カスタマイズ可能なグリッド',
    compNav: 'ナビゲーション',
    compNavStd: 'Tabのみ',
    compNavGs: 'Tab、矢印キー、数字キー',
    compQuit: 'アプリ終了',
    compQuitStd: 'Cmd+Q（切替後）',
    compQuitGs: 'グリッド表示中にQキー',
    compNumber: '数字キー',
    compNumberStd: '—',
    compNumberGs: '1〜9で直接ジャンプ',
    compBg: 'カスタム背景',
    compBgStd: '—',
    compBgGs: '色、透過度、画像',
    compIcon: 'アイコンサイズ',
    compIconStd: '固定',
    compIconGs: '調整可能（32〜128px）',
    compCols: 'グリッド列数',
    compColsStd: 'N/A',
    compColsGs: '設定可能（4〜12）',
    compHide: 'アプリ非表示',
    compHideStd: '—',
    compHideGs: '特定アプリを除外可能',
    compLang: '言語',
    compLangStd: 'システム言語',
    compLangGs: '日本語 & 英語',
  },
} as const;
