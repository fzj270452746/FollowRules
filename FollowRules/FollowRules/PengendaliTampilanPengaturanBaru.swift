//
//  PengendaliTampilanPengaturanBaru.swift
//  FollowRules
//
//  Refactored Settings View Controller with MVVM
//

import UIKit
import SnapKit
import Combine

class PengendaliTampilanPengaturanBaru: UIViewController {
    
    // MARK: - ViewModel
    private var viewModel: ViewModelPengaturan!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var kontainerGulir: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private lazy var kontainerKonten: UIView = {
        return UIView()
    }()
    
    private lazy var kontainerNavigasi: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        return view
    }()
    
    private lazy var tombolKembali: UIButton = {
        let tombol = UIButton(type: .system)
        tombol.setTitle("← Back", for: .normal)
        tombol.setTitleColor(.white, for: .normal)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tombol.addTarget(self, action: #selector(tombolKembaliDiketuk), for: .touchUpInside)
        return tombol
    }()
    
    private lazy var labelJudulNavigasi: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var itemCaraBermain: ItemPengaturan = {
        let item = ItemPengaturan()
        item.konfigurasi(ikon: "🎮", judul: "How to Play", warna: UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0))
        return item
    }()
    
    private lazy var itemUmpanBalik: ItemPengaturan = {
        let item = ItemPengaturan()
        item.konfigurasi(ikon: "💬", judul: "Feedback", warna: UIColor(red: 0.95, green: 0.6, blue: 0.2, alpha: 1.0))
        return item
    }()
    
    private lazy var itemPenilaian: ItemPengaturan = {
        let item = ItemPengaturan()
        item.konfigurasi(ikon: "⭐️", judul: "Rate Us", warna: UIColor(red: 0.95, green: 0.7, blue: 0.2, alpha: 1.0))
        return item
    }()
    
    private lazy var itemReset: ItemPengaturan = {
        let item = ItemPengaturan()
        item.konfigurasi(ikon: "🔄", judul: "Reset Scores", warna: UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0))
        return item
    }()
    
    private lazy var labelVersi: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = KontainerDependensi.bersama.buatViewModelPengaturan()
        
        aturHirarki()
        aturBatasan()
        aturGaya()
        aturBindings()
        aturAksi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup Methods
    
    private func aturHirarki() {
        view.addSubview(kontainerNavigasi)
        [tombolKembali, labelJudulNavigasi].forEach {
            kontainerNavigasi.addSubview($0)
        }
        
        view.addSubview(kontainerGulir)
        kontainerGulir.addSubview(kontainerKonten)
        
        [itemCaraBermain, itemUmpanBalik, itemPenilaian, itemReset, labelVersi].forEach {
            kontainerKonten.addSubview($0)
        }
    }
    
    private func aturBatasan() {
        kontainerNavigasi.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        tombolKembali.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        labelJudulNavigasi.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-14)
        }
        
        kontainerGulir.snp.makeConstraints { make in
            make.top.equalTo(kontainerNavigasi.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        kontainerKonten.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        itemCaraBermain.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.left.right.equalToSuperview().inset(22)
            make.height.equalTo(70)
        }
        
        itemUmpanBalik.snp.makeConstraints { make in
            make.top.equalTo(itemCaraBermain.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(22)
            make.height.equalTo(70)
        }
        
        itemPenilaian.snp.makeConstraints { make in
            make.top.equalTo(itemUmpanBalik.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(22)
            make.height.equalTo(70)
        }
        
        itemReset.snp.makeConstraints { make in
            make.top.equalTo(itemPenilaian.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(22)
            make.height.equalTo(70)
        }
        
        labelVersi.snp.makeConstraints { make in
            make.top.equalTo(itemReset.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    
    private func aturGaya() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1.0)
    }
    
    private func aturBindings() {
        viewModel.$versiAplikasi
            .receive(on: DispatchQueue.main)
            .sink { [weak self] versi in
                self?.labelVersi.text = "Version \(versi)"
            }
            .store(in: &cancellables)
    }
    
    private func aturAksi() {
        itemCaraBermain.penangananKetuk = { [weak self] in
            self?.tampilkanCaraBermain()
        }
        
        itemUmpanBalik.penangananKetuk = { [weak self] in
            self?.tampilkanUmpanBalik()
        }
        
        itemPenilaian.penangananKetuk = { [weak self] in
            self?.tampilkanPenilaian()
        }
        
        itemReset.penangananKetuk = { [weak self] in
            self?.tampilkanKonfirmasiReset()
        }
    }
    
    // MARK: - Actions
    
    @objc private func tombolKembaliDiketuk() {
        navigationController?.popViewController(animated: true)
    }
    
    private func tampilkanCaraBermain() {
        let pengendaliCaraBermain = PengendaliCaraBermainBaru()
        pengendaliCaraBermain.teksKonten = viewModel.dapatkanTeksCaraBermain()
        navigationController?.pushViewController(pengendaliCaraBermain, animated: true)
    }
    
    private func tampilkanUmpanBalik() {
        let email = viewModel.bukaEmailUmpanBalik()
        let dialog = PembuatDialogKustom.buatDialogInfo(
            judul: "Feedback",
            pesan: "We'd love to hear from you!\n\nContact us at:\n\(email)"
        )
        dialog.tampilkan(dalam: view)
    }
    
    private func tampilkanPenilaian() {
        let dialog = DialogKustomSederhana(
            judul: "Rate Our App",
            pesan: "If you enjoy Mahjong Follow Rules, please rate us!",
            tombolArray: [
                (judul: "Cancel", gaya: .sekunder, tindakan: {}),
                (judul: "Rate Now", gaya: .sukses, tindakan: { [weak self] in
                    self?.bukaPenilaian()
                })
            ]
        )
        dialog.tampilkan(dalam: view)
    }
    
    private func bukaPenilaian() {
        guard let urlString = viewModel.bukaURLPenilaian(),
              let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    private func tampilkanKonfirmasiReset() {
        let dialog = DialogKustomSederhana(
            judul: "Reset Scores?",
            pesan: "This will delete all your high scores. This cannot be undone.",
            tombolArray: [
                (judul: "Cancel", gaya: .sekunder, tindakan: {}),
                (judul: "Reset", gaya: .bahaya, tindakan: { [weak self] in
                    self?.prosesReset()
                })
            ]
        )
        dialog.tampilkan(dalam: view)
    }
    
    private func prosesReset() {
        viewModel.resetSemuaSkor { [weak self] berhasil in
            guard let self = self else { return }
            
            let dialog: DialogKustomSederhana
            if berhasil {
                dialog = PembuatDialogKustom.buatDialogInfo(
                    judul: "✓ Success",
                    pesan: "All scores have been reset"
                )
            } else {
                dialog = PembuatDialogKustom.buatDialogInfo(
                    judul: "Error",
                    pesan: "Failed to reset scores"
                )
            }
            dialog.tampilkan(dalam: self.view)
        }
    }
}

// MARK: - Item Pengaturan (Settings Item)
class ItemPengaturan: UIView {
    
    var penangananKetuk: (() -> Void)?
    
    private let kontainerUtama = UIView()
    private let labelIkon = UILabel()
    private let labelJudul = UILabel()
    private let labelPanah = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturTampilan()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func konfigurasi(ikon: String, judul: String, warna: UIColor) {
        labelIkon.text = ikon
        labelJudul.text = judul
        labelPanah.textColor = warna
    }
    
    private func aturTampilan() {
        addSubview(kontainerUtama)
        kontainerUtama.backgroundColor = .white
        kontainerUtama.layer.cornerRadius = 16
        kontainerUtama.layer.shadowColor = UIColor.black.cgColor
        kontainerUtama.layer.shadowOffset = CGSize(width: 0, height: 3)
        kontainerUtama.layer.shadowOpacity = 0.12
        kontainerUtama.layer.shadowRadius = 8
        
        // Ikon
        labelIkon.font = UIFont.systemFont(ofSize: 32)
        labelIkon.textAlignment = .center
        kontainerUtama.addSubview(labelIkon)
        
        // Judul
        labelJudul.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        labelJudul.textColor = .darkGray
        kontainerUtama.addSubview(labelJudul)
        
        // Panah
        labelPanah.text = "→"
        labelPanah.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        kontainerUtama.addSubview(labelPanah)
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(itemDiketuk))
        addGestureRecognizer(tap)
        
        // Constraints
        kontainerUtama.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        labelIkon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
        
        labelJudul.snp.makeConstraints { make in
            make.left.equalTo(labelIkon.snp.right).offset(18)
            make.centerY.equalToSuperview()
        }
        
        labelPanah.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func itemDiketuk() {
        penangananKetuk?()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.kontainerUtama.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.kontainerUtama.alpha = 0.85
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.kontainerUtama.transform = .identity
                self.kontainerUtama.alpha = 1.0
            }
        }
    }
}

// MARK: - Pengendali Cara Bermain Baru
class PengendaliCaraBermainBaru: UIViewController {
    
    var teksKonten: String = ""
    
    private lazy var kontainerNavigasi: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        return view
    }()
    
    private lazy var tombolKembali: UIButton = {
        let tombol = UIButton(type: .system)
        tombol.setTitle("← Back", for: .normal)
        tombol.setTitleColor(.white, for: .normal)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tombol.addTarget(self, action: #selector(tombolKembaliDiketuk), for: .touchUpInside)
        return tombol
    }()
    
    private lazy var labelJudul: UILabel = {
        let label = UILabel()
        label.text = "How to Play"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var kontainerGulir: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = true
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private lazy var kontainerKonten: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var labelTeks: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aturHirarki()
        aturBatasan()
        aturGaya()
        labelTeks.text = teksKonten
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func aturHirarki() {
        view.addSubview(kontainerNavigasi)
        [tombolKembali, labelJudul].forEach {
            kontainerNavigasi.addSubview($0)
        }
        
        view.addSubview(kontainerGulir)
        kontainerGulir.addSubview(kontainerKonten)
        kontainerKonten.addSubview(labelTeks)
    }
    
    private func aturBatasan() {
        kontainerNavigasi.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        tombolKembali.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        labelJudul.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-14)
        }
        
        kontainerGulir.snp.makeConstraints { make in
            make.top.equalTo(kontainerNavigasi.snp.bottom).offset(20)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        kontainerKonten.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(22)
            make.width.equalTo(view).offset(-44)
        }
        
        labelTeks.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(22)
        }
    }
    
    private func aturGaya() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1.0)
    }
    
    @objc private func tombolKembaliDiketuk() {
        navigationController?.popViewController(animated: true)
    }
}

