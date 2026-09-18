import AppKit
import ServiceManagement

/// メニューバー常駐アプリが「ログインしても出てこない」状態にならないようにする共通処理。
/// 見落とすのは次の2つ。どちらも「アプリが起動していない」ように見えるので紛らわしい。
///   ・ログイン項目に登録していない   … Mac を再起動すると二度と立ち上がらない
///   ・アイコンの位置を覚えていない   … メニューバー整理アプリの画面外の退避場所に置かれて出てこない
/// 点検は ~/bin/check-menubar-apps.py
enum MenuBarBoot {
    /// メニューバーでの置き場所を覚えるときの名前
    static let autosaveName = "GridSwitch"

    /// 初回だけ、時計寄り（見える側）に出る位置を入れておく。
    /// 位置を覚えていないと、新しく出たアイコンは整理アプリの退避場所へ送られる。
    static func seedPosition() {
        let key = "NSStatusItem Preferred Position \(autosaveName)"
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(300, forKey: key)
        }
    }

    /// 初めて起動したときに、ログイン時に立ち上がるよう登録する。本人が切ったあとは触らない。
    static func ensureRegistered() {
        let key = "menuBarBoot.loginRegistered"
        guard UserDefaults.standard.object(forKey: key) == nil else { return }
        do {
            try SMAppService.mainApp.register()
            UserDefaults.standard.set(true, forKey: key)
        } catch {
            NSLog("GridSwitch: ログイン時起動の登録に失敗しました（%@）", error.localizedDescription)
        }
    }

    /// `--login on|off|status` が来ていたら処理して終了する。画面は出さない。
    static func handleLoginArguments() {
        guard let index = CommandLine.arguments.firstIndex(of: "--login") else { return }
        let action = CommandLine.arguments.count > index + 1 ? CommandLine.arguments[index + 1] : "status"
        let service = SMAppService.mainApp
        func describe() -> String {
            switch service.status {
            case .enabled: return "登録済み（ログイン時に起動します）"
            case .notRegistered: return "未登録（ログイン時に起動しません）"
            case .requiresApproval: return "要許可（システム設定 > 一般 > ログイン項目 で有効にしてください）"
            case .notFound: return "未登録（/Applications に入れてから実行してください）"
            @unknown default: return "不明"
            }
        }
        switch action {
        case "status":
            print(describe())
            exit(service.status == .enabled ? 0 : 1)
        case "on":
            do { try service.register() } catch {
                print("登録に失敗しました: \(error.localizedDescription)")
                exit(1)
            }
            UserDefaults.standard.set(true, forKey: "menuBarBoot.loginRegistered")
            print(describe())
            exit(0)
        case "off":
            do { try service.unregister() } catch {
                print("解除に失敗しました: \(error.localizedDescription)")
                exit(1)
            }
            UserDefaults.standard.set(false, forKey: "menuBarBoot.loginRegistered")
            print(describe())
            exit(0)
        default:
            print("使い方: --login on|off|status")
            exit(1)
        }
    }
}
