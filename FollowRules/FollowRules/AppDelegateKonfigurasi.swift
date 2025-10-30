//
//  AppDelegateKonfigurasi.swift
//  FollowRules
//
//  App Configuration and Initialization
//

import UIKit

// MARK: - Ekstensi AppDelegate
extension AppDelegate {
    
    func konfigurasiArsitektur() {
        // Inisialisasi kontainer dependensi
        _ = KontainerDependensi.bersama
        
        // Konfigurasi appearance global
        konfigurasiTampilanGlobal()
    }
    
    private func konfigurasiTampilanGlobal() {
        // Navigation Bar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = .white
        
        // Tab Bar (jika diperlukan di masa depan)
        UITabBar.appearance().tintColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
    }
}

// MARK: - Ekstensi SceneDelegate
extension SceneDelegate {
    
    func konfigurasiJendelaUtama(scene: UIScene, with options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Buat window
        let window = UIWindow(windowScene: windowScene)
        
        // Buat root view controller
        let pengendaliBerandaBaru = PengendaliTampilanBerandaBaru()
        let navigasiPengendali = UINavigationController(rootViewController: pengendaliBerandaBaru)
        navigasiPengendali.interactivePopGestureRecognizer?.isEnabled = true
        
        // Set root
        window.rootViewController = navigasiPengendali
        window.makeKeyAndVisible()
        
        self.window = window
    }
}

// MARK: - Koordinator Navigasi (Navigation Coordinator)
class KoordinatorNavigasi {
    
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func tampilkanBeranda() {
        let pengendali = PengendaliTampilanBerandaBaru()
        navigationController?.setViewControllers([pengendali], animated: false)
    }
    
    func tampilkanPermainan(denganKonfigurasi konfigurasi: KonfigurasiPermainan) {
        let pengendali = PengendaliTampilanPermainanBaru()
        pengendali.inisialisasi(denganKonfigurasi: konfigurasi)
        navigationController?.pushViewController(pengendali, animated: true)
    }
    
    func tampilkanPengaturan() {
        let pengendali = PengendaliTampilanPengaturanBaru()
        navigationController?.pushViewController(pengendali, animated: true)
    }
    
    func kembali(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func kembaliKeBeranda(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
}

