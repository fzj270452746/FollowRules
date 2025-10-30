//
//  KomponenUIKustom.swift
//  FollowRules
//
//  Custom UI Components
//

import UIKit
import SnapKit

// MARK: - Pengendali Selector Kesulitan
class PengendaliSelectorKesulitan: UIViewController {
    
    var penyelesaianPilihan: ((TingkatKesulitan) -> Void)?
    
    private let kontainerDialog = KontainerTinta()
    private let labelJudul = LabelTinta()
    private let stackTombol = UIStackView()
    private let tombolTutup = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aturTampilan()
    }
    
    private func aturTampilan() {
        view.backgroundColor = TemaWarnaTinta.warnaOverlayGelap
        
        // Dialog kontainer - 水墨风格
        view.addSubview(kontainerDialog)
        kontainerDialog.backgroundColor = TemaWarnaTinta.warnaLatarUtama
        kontainerDialog.layer.cornerRadius = 24
        PenciptaEfekTinta.terapkanShadowTinta(keView: kontainerDialog, intensitas: 0.25)
        
        // Tambahkan efek tekstur
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            PenciptaEfekTinta.buatEfekTeksturKertas(untukView: self.kontainerDialog)
        }
        
        // Judul
        labelJudul.text = "Select Difficulty"
        labelJudul.setGayaTinta(ukuran: 28, berat: .bold, warna: TemaWarnaTinta.warnaTintaHitam)
        labelJudul.textAlignment = .center
        kontainerDialog.addSubview(labelJudul)
        
        // Stack tombol
        stackTombol.axis = .vertical
        stackTombol.spacing = 18
        stackTombol.distribution = .fillEqually
        
        let pilihan: [(judul: String, kesulitan: TingkatKesulitan, warna: UIColor)] = [
            ("🟢 Easy (3×3)", .mudah, TemaWarnaTinta.warnaSukses),
            ("🟡 Medium (4×4)", .sedang, TemaWarnaTinta.warnaPeringatan),
            ("🔴 Hard (5×5)", .sulit, TemaWarnaTinta.warnaError),
            ("⚫️ Expert (6×6)", .pakar, TemaWarnaTinta.warnaTintaHitam)
        ]
        
        for (index, (judul, _, warna)) in pilihan.enumerated() {
            let tombol = buatTombolKesulitan(judul: judul, warna: warna)
            tombol.tag = index
            tombol.addTarget(self, action: #selector(kesulitanDipilih(_:)), for: .touchUpInside)
            stackTombol.addArrangedSubview(tombol)
        }
        
        kontainerDialog.addSubview(stackTombol)
        
        // Tombol tutup
        tombolTutup.setTitle("✕", for: .normal)
        tombolTutup.setTitleColor(TemaWarnaTinta.warnaTintaSedang, for: .normal)
        tombolTutup.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: .light)
        tombolTutup.addTarget(self, action: #selector(tutup), for: .touchUpInside)
        kontainerDialog.addSubview(tombolTutup)
        
        // Constraints
        kontainerDialog.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(35)
        }
        
        labelJudul.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35)
            make.centerX.equalToSuperview()
        }
        
        stackTombol.snp.makeConstraints { make in
            make.top.equalTo(labelJudul.snp.bottom).offset(35)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(280)
            make.bottom.equalToSuperview().offset(-35)
        }
        
        tombolTutup.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.width.height.equalTo(44)
        }
        
        // Animasi masuk
        kontainerDialog.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        kontainerDialog.alpha = 0
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.kontainerDialog.transform = .identity
            self.kontainerDialog.alpha = 1
        }
    }
    
    private func buatTombolKesulitan(judul: String, warna: UIColor) -> TombolTinta {
        let tombol = TombolTinta()
        tombol.setTitle(judul, for: .normal)
        tombol.setGayaTintaDasar(warnaLatar: warna, warnaTeks: TemaWarnaTinta.warnaLatarUtama)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        return tombol
    }
    
    @objc private func kesulitanDipilih(_ pengirim: TombolTinta) {
        let kesulitanArray: [TingkatKesulitan] = [.mudah, .sedang, .sulit, .pakar]
        let kesulitan = kesulitanArray[pengirim.tag]
        
        dismiss(animated: true) { [weak self] in
            self?.penyelesaianPilihan?(kesulitan)
        }
    }
    
    @objc private func tutup() {
        dismiss(animated: true)
    }
}

// MARK: - Pembuat Dialog Kustom
class PembuatDialogKustom {
    
    static func buatDialogPeringkat(skorTantangan: Int, skorWaktu: Int) -> DialogKustomSederhana {
        let pesan = """
        🎯 Challenge Mode
        Highest Level: \(skorTantangan)
        
        ⏱ Time Mode
        Best Score: \(skorWaktu) points
        """
        
        return DialogKustomSederhana(
            judul: "🏆 Leaderboard",
            pesan: pesan,
            tombolArray: [
                (judul: "OK", gaya: .utama, tindakan: {})
            ]
        )
    }
    
    static func buatDialogKonfirmasi(judul: String, pesan: String, onKonfirmasi: @escaping () -> Void) -> DialogKustomSederhana {
        return DialogKustomSederhana(
            judul: judul,
            pesan: pesan,
            tombolArray: [
                (judul: "Cancel", gaya: .sekunder, tindakan: {}),
                (judul: "Confirm", gaya: .utama, tindakan: onKonfirmasi)
            ]
        )
    }
    
    static func buatDialogInfo(judul: String, pesan: String) -> DialogKustomSederhana {
        return DialogKustomSederhana(
            judul: judul,
            pesan: pesan,
            tombolArray: [
                (judul: "OK", gaya: .utama, tindakan: {})
            ]
        )
    }
}

// MARK: - Dialog Kustom Sederhana
class DialogKustomSederhana: UIView {
    
    enum GayaTombol {
        case utama, sekunder, sukses, bahaya
        
        var warna: UIColor {
            switch self {
            case .utama: return TemaWarnaTinta.warnaTintaHitam
            case .sekunder: return TemaWarnaTinta.warnaTintaTerang
            case .sukses: return TemaWarnaTinta.warnaSukses
            case .bahaya: return TemaWarnaTinta.warnaError
            }
        }
        
        var warnaTeks: UIColor {
            switch self {
            case .sekunder: return TemaWarnaTinta.warnaTintaHitam
            default: return TemaWarnaTinta.warnaLatarUtama
            }
        }
    }
    
    private let kontainerDialog = KontainerTinta()
    private let labelJudul = LabelTinta()
    private let labelPesan = LabelTinta()
    private let stackTombol = UIStackView()
    
    private var tindakanArray: [() -> Void] = []
    
    init(judul: String, pesan: String, tombolArray: [(judul: String, gaya: GayaTombol, tindakan: () -> Void)]) {
        super.init(frame: .zero)
        
        for tombol in tombolArray {
            tindakanArray.append(tombol.tindakan)
        }
        
        aturTampilan(judul: judul, pesan: pesan, tombolArray: tombolArray)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func aturTampilan(judul: String, pesan: String, tombolArray: [(judul: String, gaya: GayaTombol, tindakan: () -> Void)]) {
        backgroundColor = TemaWarnaTinta.warnaOverlayGelap
        
        // Dialog kontainer - 水墨风格
        addSubview(kontainerDialog)
        kontainerDialog.backgroundColor = TemaWarnaTinta.warnaLatarUtama
        
        // Tambahkan efek tekstur
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            PenciptaEfekTinta.buatEfekTeksturKertas(untukView: self.kontainerDialog)
        }
        
        // Judul
        labelJudul.text = judul
        labelJudul.setGayaTinta(ukuran: 26, berat: .bold, warna: TemaWarnaTinta.warnaTintaHitam)
        labelJudul.textAlignment = .center
        labelJudul.numberOfLines = 0
        kontainerDialog.addSubview(labelJudul)
        
        // Pesan
        labelPesan.text = pesan
        labelPesan.setGayaTinta(ukuran: 17, berat: .medium, warna: TemaWarnaTinta.warnaTintaSedang)
        labelPesan.textAlignment = .center
        labelPesan.numberOfLines = 0
        kontainerDialog.addSubview(labelPesan)
        
        // Stack tombol
        stackTombol.axis = .horizontal
        stackTombol.spacing = 15
        stackTombol.distribution = .fillEqually
        
        for (index, (judulTombol, gaya, _)) in tombolArray.enumerated() {
            let tombol = buatTombol(judul: judulTombol, gaya: gaya)
            tombol.tag = index
            tombol.addTarget(self, action: #selector(tombolDiketuk(_:)), for: .touchUpInside)
            stackTombol.addArrangedSubview(tombol)
        }
        
        kontainerDialog.addSubview(stackTombol)
        
        // Constraints
        kontainerDialog.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        }
        
        labelJudul.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.right.equalToSuperview().inset(25)
        }
        
        labelPesan.snp.makeConstraints { make in
            make.top.equalTo(labelJudul.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(25)
        }
        
        stackTombol.snp.makeConstraints { make in
            make.top.equalTo(labelPesan.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-25)
        }
        
        // Animasi awal
        kontainerDialog.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        kontainerDialog.alpha = 0
    }
    
    private func buatTombol(judul: String, gaya: GayaTombol) -> TombolTinta {
        let tombol = TombolTinta()
        tombol.setTitle(judul, for: .normal)
        tombol.setGayaTintaDasar(warnaLatar: gaya.warna, warnaTeks: gaya.warnaTeks)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return tombol
    }
    
    @objc private func tombolDiketuk(_ pengirim: TombolTinta) {
        let index = pengirim.tag
        
        sembunyikan { [weak self] in
            guard let self = self, index < self.tindakanArray.count else { return }
            self.tindakanArray[index]()
        }
    }
    
    func tampilkan(dalam tampilan: UIView) {
        tampilan.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加粒子效果
        let center = tampilan.center
        PembuatEfekVisualTingkatTinggi.buatEfekParticleBurst(
            dariPosisi: center,
            diView: tampilan,
            warna: TemaWarnaTinta.warnaTintaHitam
        )
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.7,
            options: .curveEaseOut
        ) {
            self.kontainerDialog.transform = .identity
            self.kontainerDialog.alpha = 1
        }
    }
    
    private func sembunyikan(selesai: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.kontainerDialog.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                self.kontainerDialog.alpha = 0
                self.alpha = 0
            },
            completion: { _ in
                self.removeFromSuperview()
                selesai?()
            }
        )
    }
}

