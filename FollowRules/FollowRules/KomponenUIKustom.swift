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
    
    private let kontainerDialog = UIView()
    private let labelJudul = UILabel()
    private let stackTombol = UIStackView()
    private let tombolTutup = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aturTampilan()
    }
    
    private func aturTampilan() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        
        // Dialog kontainer
        view.addSubview(kontainerDialog)
        kontainerDialog.backgroundColor = .white
        kontainerDialog.layer.cornerRadius = 28
        kontainerDialog.layer.shadowColor = UIColor.black.cgColor
        kontainerDialog.layer.shadowOffset = CGSize(width: 0, height: 10)
        kontainerDialog.layer.shadowOpacity = 0.3
        kontainerDialog.layer.shadowRadius = 20
        
        // Judul
        labelJudul.text = "Select Difficulty"
        labelJudul.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        labelJudul.textColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        labelJudul.textAlignment = .center
        kontainerDialog.addSubview(labelJudul)
        
        // Stack tombol
        stackTombol.axis = .vertical
        stackTombol.spacing = 18
        stackTombol.distribution = .fillEqually
        
        let pilihan: [(judul: String, kesulitan: TingkatKesulitan, warna: UIColor)] = [
            ("🟢 Easy (3×3)", .mudah, UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)),
            ("🟡 Medium (4×4)", .sedang, UIColor(red: 0.95, green: 0.65, blue: 0.2, alpha: 1.0)),
            ("🔴 Hard (5×5)", .sulit, UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)),
            ("⚫️ Expert (6×6)", .pakar, UIColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 1.0))
        ]
        
        for (index, (judul, kesulitan, warna)) in pilihan.enumerated() {
            let tombol = buatTombolKesulitan(judul: judul, warna: warna)
            tombol.tag = index
            tombol.addTarget(self, action: #selector(kesulitanDipilih(_:)), for: .touchUpInside)
            stackTombol.addArrangedSubview(tombol)
        }
        
        kontainerDialog.addSubview(stackTombol)
        
        // Tombol tutup
        tombolTutup.setTitle("✕", for: .normal)
        tombolTutup.setTitleColor(.gray, for: .normal)
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
    
    private func buatTombolKesulitan(judul: String, warna: UIColor) -> UIButton {
        let tombol = UIButton(type: .system)
        tombol.setTitle(judul, for: .normal)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        tombol.setTitleColor(.white, for: .normal)
        tombol.backgroundColor = warna
        tombol.layer.cornerRadius = 16
        tombol.layer.shadowColor = UIColor.black.cgColor
        tombol.layer.shadowOffset = CGSize(width: 0, height: 4)
        tombol.layer.shadowOpacity = 0.2
        tombol.layer.shadowRadius = 8
        return tombol
    }
    
    @objc private func kesulitanDipilih(_ pengirim: UIButton) {
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
            case .utama: return UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
            case .sekunder: return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            case .sukses: return UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
            case .bahaya: return UIColor(red: 0.95, green: 0.3, blue: 0.2, alpha: 1.0)
            }
        }
        
        var warnaTeks: UIColor {
            switch self {
            case .sekunder: return .darkGray
            default: return .white
            }
        }
    }
    
    private let kontainerDialog = UIView()
    private let labelJudul = UILabel()
    private let labelPesan = UILabel()
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
        backgroundColor = UIColor.black.withAlphaComponent(0.65)
        
        // Dialog kontainer
        addSubview(kontainerDialog)
        kontainerDialog.backgroundColor = .white
        kontainerDialog.layer.cornerRadius = 26
        kontainerDialog.layer.shadowColor = UIColor.black.cgColor
        kontainerDialog.layer.shadowOffset = CGSize(width: 0, height: 10)
        kontainerDialog.layer.shadowOpacity = 0.3
        kontainerDialog.layer.shadowRadius = 20
        
        // Judul
        labelJudul.text = judul
        labelJudul.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        labelJudul.textColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        labelJudul.textAlignment = .center
        labelJudul.numberOfLines = 0
        kontainerDialog.addSubview(labelJudul)
        
        // Pesan
        labelPesan.text = pesan
        labelPesan.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        labelPesan.textColor = .darkGray
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
    
    private func buatTombol(judul: String, gaya: GayaTombol) -> UIButton {
        let tombol = UIButton(type: .system)
        tombol.setTitle(judul, for: .normal)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tombol.setTitleColor(gaya.warnaTeks, for: .normal)
        tombol.backgroundColor = gaya.warna
        tombol.layer.cornerRadius = 14
        return tombol
    }
    
    @objc private func tombolDiketuk(_ pengirim: UIButton) {
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

