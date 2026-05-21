// マニュアルページの文字列
export const manual = {
  en: {
    // Page header
    manualTitle: 'Manual',
    manualSub: 'Everything you need to know to get started with GridSwitch.',
    manualToc: 'Table of Contents',

    // Installation
    manualInstall: 'Installation',
    manualInstallDownload: 'Download GridSwitch from the official website and move it to your Applications folder.',
    manualInstallReq: 'Requires macOS 14.0 (Sonoma) or later.',
    manualInstallAccessibility: 'Accessibility Permission',
    manualInstallAccessibilityDesc: 'GridSwitch needs Accessibility permission to intercept keyboard shortcuts. On first launch, you will be prompted to grant permission.',
    manualInstallAccessibilitySteps: 'If you need to enable it manually:',
    manualInstallStep1: 'Open System Settings',
    manualInstallStep2: 'Go to Privacy & Security > Accessibility',
    manualInstallStep3: 'Enable the toggle for GridSwitch',

    // Basic Usage
    manualBasic: 'Basic Usage',
    manualBasicOpen: 'Show the switcher',
    manualBasicOpenDesc: 'Press Cmd+Tab to open the GridSwitch panel. All running applications are displayed in a grid.',
    manualBasicSwitch: 'Switch to an app',
    manualBasicSwitchDesc: 'While holding Cmd, navigate to the desired app, then release Cmd to switch to it.',
    manualBasicCancel: 'Cancel',
    manualBasicCancelDesc: 'Press Esc to close the switcher without switching apps.',

    // Grid Navigation
    manualGrid: 'Grid Navigation',
    manualGridArrows: 'Use arrow keys to move selection in the grid.',
    manualGridTab: 'Press Tab to move to the next app, or Shift+Tab to move to the previous app.',
    manualGridCmdTab: 'Press Cmd+Tab again (while the grid is open) to move to the next app.',
    manualGridCmdShiftTab: 'Press Cmd+Shift+Tab to move to the previous app.',
    manualGridCtrl: 'While holding Cmd, press Ctrl to move to the previous app.',
    manualGridMouse: 'Click on any app icon with the mouse to select and switch to it.',

    // Number Key Shortcuts
    manualNumbers: 'Number Key Shortcuts',
    manualNumbersDesc: 'Quickly jump to any app by pressing its number key while the grid is open.',
    manualNumbers1to9: 'Press 1 through 9 to jump to the 1st through 9th app.',
    manualNumbers0: 'Press 0 to jump to the 10th app.',
    manualNumbersToggle: 'This feature can be enabled or disabled in Settings.',

    // Quit App
    manualQuit: 'Quit Apps Instantly',
    manualQuitDesc: 'While the grid is open, press Q to immediately quit the currently selected app. The app will close and be removed from the grid.',

    // Settings
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

    // Menu Bar
    manualMenuBar: 'Menu Bar',
    manualMenuBarDesc: 'GridSwitch adds a grid icon to your menu bar. Click it to access:',
    manualMenuBarAbout: 'About — View version information',
    manualMenuBarSettings: 'Settings — Open the settings window',
    manualMenuBarQuit: 'Quit — Exit GridSwitch',

    // Troubleshooting
    manualTroubleshooting: 'Troubleshooting',
    manualTsNoShow: 'The switcher does not appear',
    manualTsNoShowDesc: 'Make sure Accessibility permission is granted. Go to System Settings > Privacy & Security > Accessibility and verify that GridSwitch is enabled.',
    manualTsNoResponse: 'Keys are not responding',
    manualTsNoResponseDesc: 'The EventTap may have been disabled by the system. Try restarting GridSwitch. If the problem persists, remove GridSwitch from Accessibility settings and re-add it.',
  },
  ja: {
    // Page header
    manualTitle: 'マニュアル',
    manualSub: 'GridSwitchの使い方をすべて解説します。',
    manualToc: '目次',

    // Installation
    manualInstall: 'インストール',
    manualInstallDownload: '公式サイトからGridSwitchをダウンロードし、アプリケーションフォルダに移動します。',
    manualInstallReq: 'macOS 14.0 (Sonoma) 以降が必要です。',
    manualInstallAccessibility: 'アクセシビリティ権限',
    manualInstallAccessibilityDesc: 'GridSwitchはキーボードショートカットを傍受するために、アクセシビリティ権限が必要です。初回起動時に権限の許可を求められます。',
    manualInstallAccessibilitySteps: '手動で有効にする場合：',
    manualInstallStep1: 'システム設定を開く',
    manualInstallStep2: 'プライバシーとセキュリティ > アクセシビリティ に移動',
    manualInstallStep3: 'GridSwitchのトグルを有効にする',

    // Basic Usage
    manualBasic: '基本操作',
    manualBasicOpen: 'スイッチャーを表示',
    manualBasicOpenDesc: 'Cmd+Tabを押すとGridSwitchパネルが開きます。起動中のすべてのアプリがグリッドで表示されます。',
    manualBasicSwitch: 'アプリを切り替え',
    manualBasicSwitchDesc: 'Cmdを押したまま目的のアプリに移動し、Cmdを離すと切り替わります。',
    manualBasicCancel: 'キャンセル',
    manualBasicCancelDesc: 'Escを押すとスイッチャーを閉じ、アプリを切り替えずに戻ります。',

    // Grid Navigation
    manualGrid: 'グリッド操作',
    manualGridArrows: '矢印キーでグリッド内の選択を移動します。',
    manualGridTab: 'Tabで次のアプリ、Shift+Tabで前のアプリに移動します。',
    manualGridCmdTab: 'グリッド表示中にCmd+Tabを追加で押すと、次のアプリに移動します。',
    manualGridCmdShiftTab: 'Cmd+Shift+Tabで前のアプリに移動します。',
    manualGridCtrl: 'Cmdを押したまま、Ctrlを押すと前のアプリに移動します。',
    manualGridMouse: 'マウスでアプリアイコンをクリックして選択・切り替えできます。',

    // Number Key Shortcuts
    manualNumbers: '数字キーショートカット',
    manualNumbersDesc: 'グリッド表示中に数字キーを押すと、対応する位置のアプリにジャンプします。',
    manualNumbers1to9: '1〜9で1番目〜9番目のアプリに直接ジャンプ。',
    manualNumbers0: '0で10番目のアプリにジャンプ。',
    manualNumbersToggle: 'この機能は設定で有効/無効を切り替えられます。',

    // Quit App
    manualQuit: 'アプリの即時終了',
    manualQuitDesc: 'グリッド表示中にQキーを押すと、選択中のアプリを即座に終了します。アプリが終了しグリッドから削除されます。',

    // Settings
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

    // Menu Bar
    manualMenuBar: 'メニューバー',
    manualMenuBarDesc: 'GridSwitchはメニューバーにグリッドアイコンを追加します。クリックすると以下にアクセスできます：',
    manualMenuBarAbout: 'About — バージョン情報を表示',
    manualMenuBarSettings: 'Settings — 設定ウィンドウを開く',
    manualMenuBarQuit: 'Quit — GridSwitchを終了',

    // Troubleshooting
    manualTroubleshooting: 'トラブルシューティング',
    manualTsNoShow: 'スイッチャーが表示されない',
    manualTsNoShowDesc: 'アクセシビリティ権限が付与されているか確認してください。システム設定 > プライバシーとセキュリティ > アクセシビリティ でGridSwitchが有効になっているか確認します。',
    manualTsNoResponse: 'キーが反応しない',
    manualTsNoResponseDesc: 'EventTapがシステムによって無効化された可能性があります。GridSwitchを再起動してください。問題が解決しない場合は、アクセシビリティ設定からGridSwitchを一度削除し、再度追加してください。',
  },
} as const;
