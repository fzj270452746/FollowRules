

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var koordinatorNavigasi: KoordinatorNavigasi?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Konfigurasi window dengan arsitektur baru
        konfigurasiJendelaUtama(scene: scene, with: connectionOptions)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Cleanup resources
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Resume tasks if needed
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Pause tasks if needed
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Update UI if needed
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save state if needed
    }
}

