//
//  PengendaliTampilanPermainanBaru.swift
//  FollowRules
//
//  Refactored Game View Controller with MVVM
//

import UIKit
import SnapKit
import Combine

class PengendaliTampilanPermainanBaru: UIViewController {
    
    // MARK: - ViewModel
    private var viewModel: ViewModelPermainan!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var kontainerHeader: KontainerTinta = {
        let view = KontainerTinta()
        view.backgroundColor = TemaWarnaTinta.warnaTintaHitam
        view.layer.cornerRadius = 0
        return view
    }()
    
    private lazy var tombolKembali: TombolTinta = {
        let tombol = TombolTinta()
        tombol.setTitle("← Back", for: .normal)
        tombol.setGayaTintaDasar(warnaLatar: .clear, warnaTeks: TemaWarnaTinta.warnaLatarUtama)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tombol.addTarget(self, action: #selector(tombolKembaliDiketuk), for: .touchUpInside)
        return tombol
    }()
    
    private lazy var labelTingkat: LabelTinta = {
        let label = LabelTinta()
        label.setGayaTinta(ukuran: 24, berat: .bold, warna: TemaWarnaTinta.warnaLatarUtama)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var labelSkor: LabelTinta = {
        let label = LabelTinta()
        label.setGayaTinta(ukuran: 18, berat: .semibold, warna: TemaWarnaTinta.warnaLatarUtama)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var labelWaktu: LabelTinta = {
        let label = LabelTinta()
        label.setGayaTinta(ukuran: 18, berat: .semibold, warna: TemaWarnaTinta.warnaLatarUtama)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var kontainerAturan: KontainerTinta = {
        let view = KontainerTinta()
        view.backgroundColor = TemaWarnaTinta.warnaLatarUtama
        return view
    }()
    
    private lazy var labelAturan: LabelTinta = {
        let label = LabelTinta()
        label.setGayaTinta(ukuran: 19, berat: .semibold, warna: TemaWarnaTinta.warnaTintaHitam)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var kontainerKisi: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.clipsToBounds = false
        return view
    }()
    
    private var tampilanKartuArray: [TampilanKartuBaru] = []
    
    private lazy var tombolVerifikasi: TombolTinta = {
        let tombol = TombolTinta()
        tombol.setTitle("✓ Check Answer", for: .normal)
        tombol.setGayaTintaDasar(warnaLatar: TemaWarnaTinta.warnaSukses, warnaTeks: TemaWarnaTinta.warnaLatarUtama)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        tombol.addTarget(self, action: #selector(tombolVerifikasiDiketuk), for: .touchUpInside)
        return tombol
    }()
    
    // MARK: - Lifecycle
    
    func inisialisasi(denganKonfigurasi konfigurasi: KonfigurasiPermainan) {
        viewModel = KontainerDependensi.bersama.buatViewModelPermainan(konfigurasi: konfigurasi)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aturHirarki()
        aturBatasan()
        aturGaya()
        aturBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.keluarPermainan()
    }
    
    // MARK: - Setup Methods
    
    private func aturHirarki() {
        [kontainerHeader, kontainerAturan, kontainerKisi, tombolVerifikasi].forEach {
            view.addSubview($0)
        }
        
        [tombolKembali, labelTingkat, labelSkor, labelWaktu].forEach {
            kontainerHeader.addSubview($0)
        }
        
        kontainerAturan.addSubview(labelAturan)
    }
    
    private func aturBatasan() {
        kontainerHeader.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(120)
        }
        
        tombolKembali.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        labelTingkat.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-14)
        }
        
        labelSkor.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-34)
        }
        
        labelWaktu.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        kontainerAturan.snp.makeConstraints { make in
            make.top.equalTo(kontainerHeader.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(22)
        }
        
        labelAturan.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(22)
        }
        
        kontainerKisi.snp.makeConstraints { make in
            make.top.equalTo(kontainerAturan.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(22)
            make.height.equalTo(100) // Will be updated
            make.bottom.lessThanOrEqualTo(tombolVerifikasi.snp.top).offset(-22)
        }
        
        tombolVerifikasi.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(22)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-22)
        }
    }
    
    private func aturGaya() {
        view.backgroundColor = TemaWarnaTinta.warnaLatarUtama
        
        // Tambahkan latar tingkat tinggi yang sangat visual
        view.tambahkanLatarTingkatTinggi()
        
        // Tambahkan efek tekstur kertas (di atas latar)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            PenciptaEfekTinta.buatEfekTeksturKertas(untukView: self.view)
        }
        
        // Aktifkan efek glow pada header
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            PembuatEfekVisualTingkatTinggi.buatEfekGlow(untukView: self.kontainerHeader, warna: TemaWarnaTinta.warnaTintaHitam, radius: 15)
        }
        
        // Aktifkan efek breathing pada tombol verifikasi
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.tombolVerifikasi.aktifkanEfekPulse()
        }
    }
    
    private func aturBindings() {
        viewModel.$tingkatSekarang
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tingkat in
                self?.labelTingkat.text = "Level \(tingkat)"
            }
            .store(in: &cancellables)
        
        viewModel.$skorSekarang
            .receive(on: DispatchQueue.main)
            .sink { [weak self] skor in
                self?.labelSkor.text = "Score: \(skor)"
            }
            .store(in: &cancellables)
        
        viewModel.$waktuTersisa
            .receive(on: DispatchQueue.main)
            .sink { [weak self] waktu in
                guard let waktu = waktu else {
                    self?.labelWaktu.isHidden = true
                    return
                }
                self?.labelWaktu.isHidden = false
                let menit = Int(waktu) / 60
                let detik = Int(waktu) % 60
                self?.labelWaktu.text = String(format: "⏱ %02d:%02d", menit, detik)
                
                if waktu <= 10 {
                    self?.labelWaktu.textColor = TemaWarnaTinta.warnaError
                } else {
                    self?.labelWaktu.textColor = TemaWarnaTinta.warnaLatarUtama
                }
            }
            .store(in: &cancellables)
        
        viewModel.$aturanSekarang
            .receive(on: DispatchQueue.main)
            .sink { [weak self] aturan in
                self?.labelAturan.text = "📜 \(aturan)"
            }
            .store(in: &cancellables)
        
        viewModel.$kartuSekarang
            .receive(on: DispatchQueue.main)
            .sink { [weak self] kartu in
                self?.muatKartuKeKisi()
            }
            .store(in: &cancellables)
        
        viewModel.$kartuTerpilih
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.perbaruiTampilanKartu()
            }
            .store(in: &cancellables)
        
        viewModel.$statusPermainan
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.tanganiPerubahanStatus(status)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Update Methods
    
    private func muatKartuKeKisi() {
        // Hapus kartu lama
        tampilanKartuArray.forEach { $0.removeFromSuperview() }
        tampilanKartuArray.removeAll()
        
        let kartuArray = viewModel.kartuSekarang
        let ukuranKisi = viewModel.ukuranKisi
        
        guard !kartuArray.isEmpty else { return }
        
        let lebarContainer = view.bounds.width - 44
        let spacing: CGFloat = 10
        let ukuranKartu = (lebarContainer - CGFloat(ukuranKisi + 1) * spacing) / CGFloat(ukuranKisi)
        
        for (indeks, kartu) in kartuArray.enumerated() {
            let baris = indeks / ukuranKisi
            let kolom = indeks % ukuranKisi
            
            let tampilanKartu = TampilanKartuBaru()
            tampilanKartu.konfigurasi(kartu: kartu)
            tampilanKartu.penangananKetuk = { [weak self] in
                self?.viewModel.tanganiKetukanKartu(pada: indeks)
                
                // 添加视觉反馈
                let center = tampilanKartu.superview?.convert(tampilanKartu.center, to: self?.view) ?? CGPoint.zero
                PembuatEfekVisualTingkatTinggi.buatEfekParticleBurst(
                    dariPosisi: center,
                    diView: self?.view ?? tampilanKartu,
                    warna: self?.viewModel.kartuTerpilih.contains(kartu.id) == true ? TemaWarnaTinta.warnaTintaSedang : TemaWarnaTinta.warnaTintaHitam
                )
            }
            
            kontainerKisi.addSubview(tampilanKartu)
            tampilanKartuArray.append(tampilanKartu)
            
            let x = CGFloat(kolom) * (ukuranKartu + spacing) + spacing
            let y = CGFloat(baris) * (ukuranKartu + spacing) + spacing
            
            tampilanKartu.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
                make.width.height.equalTo(ukuranKartu)
            }
            
            // Animasi masuk - 增强版
            tampilanKartu.alpha = 0
            tampilanKartu.transform = CGAffineTransform(scaleX: 0.3, y: 0.3).rotated(by: CGFloat.random(in: -0.3...0.3))
            
            // 添加3D效果
            var transform3D = CATransform3DIdentity
            transform3D.m34 = -1.0 / 500.0
            transform3D = CATransform3DRotate(transform3D, .pi / 4, 1, 0, 0)
            tampilanKartu.layer.transform = transform3D
            
            // 启用交互效果
            tampilanKartu.aktifkanEfekInteraktif()
            
            UIView.animate(
                withDuration: 0.6,
                delay: Double(indeks) * 0.05,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.8,
                options: .curveEaseOut
            ) {
                tampilanKartu.alpha = 1
                tampilanKartu.transform = .identity
                tampilanKartu.layer.transform = CATransform3DIdentity
                
                // 添加粒子效果
                let cardCenter = tampilanKartu.superview?.convert(tampilanKartu.center, to: self.view) ?? CGPoint.zero
                PembuatEfekVisualTingkatTinggi.buatEfekParticleBurst(
                    dariPosisi: cardCenter,
                    diView: self.view,
                    warna: TemaWarnaTinta.warnaTintaTerang
                )
            }
        }
        
        // Update tinggi kontainer
        let tinggiKisi = CGFloat(Int((kartuArray.count + ukuranKisi - 1) / ukuranKisi)) * (ukuranKartu + spacing) + spacing
        kontainerKisi.snp.updateConstraints { make in
            make.height.equalTo(tinggiKisi)
        }
    }
    
    private func perbaruiTampilanKartu() {
        let kartuTerpilih = viewModel.kartuTerpilih
        let kartuArray = viewModel.kartuSekarang
        
        for (indeks, tampilan) in tampilanKartuArray.enumerated() {
            guard indeks < kartuArray.count else { continue }
            let kartu = kartuArray[indeks]
            tampilan.aturStatusPilihan(terpilih: kartuTerpilih.contains(kartu.id))
        }
    }
    
    private func tanganiPerubahanStatus(_ status: StatusPermainan) {
        switch status {
        case .selesaiSukses:
            break // Akan ditangani oleh callback verifikasi
        case .selesaiGagal:
            break // Akan ditangani oleh callback verifikasi
        case .selesaiWaktuHabis:
            tampilkanDialogWaktuHabis()
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @objc private func tombolKembaliDiketuk() {
        let dialog = PembuatDialogKustom.buatDialogKonfirmasi(
            judul: "Leave Game?",
            pesan: "Your progress will be lost"
        ) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        dialog.tampilkan(dalam: view)
    }
    
    @objc private func tombolVerifikasiDiketuk() {
        // 添加触觉反馈
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .medium)
        
        // 添加涟漪效果
        let center = tombolVerifikasi.center
        PembuatEfekVisualTingkatTinggi.buatEfekRipple(dariPosisi: center, diView: view)
        
        viewModel.verifikasiJawaban { [weak self] berhasil, pesan in
            guard let self = self else { return }
            
            if berhasil {
                self.tampilkanDialogJawabanBenar()
            } else {
                self.tampilkanDialogJawabanSalah(pesan: pesan)
            }
        }
    }
    
    private func tampilkanDialogJawabanBenar() {
        // 增强动画：粒子效果 + 光晕
        for tampilan in tampilanKartuArray {
            if tampilan.adalahTerpilih {
                tampilan.animasiBenar()
                
                // 添加涟漪效果
                let center = tampilan.superview?.convert(tampilan.center, to: view) ?? CGPoint.zero
                PembuatEfekVisualTingkatTinggi.buatEfekRipple(dariPosisi: center, diView: view, warna: TemaWarnaTinta.warnaSukses)
            }
        }
        
        // 添加触觉反馈
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .heavy)
        
        // Delay dialog
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let dialog = DialogKustomSederhana(
                judul: "🎉 Correct!",
                pesan: "Great job! Ready for the next level?",
                tombolArray: [
                    (judul: "Next Level", gaya: .sukses, tindakan: { [weak self] in
                        self?.viewModel.lanjutkanTingkatBerikutnya()
                    })
                ]
            )
            dialog.tampilkan(dalam: self.view)
        }
    }
    
    private func tampilkanDialogJawabanSalah(pesan: String?) {
        // 增强动画：震动 + 粒子效果
        for tampilan in tampilanKartuArray {
            if tampilan.adalahTerpilih {
                tampilan.animasiSalah()
            }
        }
        
        // 添加触觉反馈
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .heavy)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            let dialog = DialogKustomSederhana(
                judul: "❌ Wrong!",
                pesan: pesan ?? "Incorrect answer. Try again!",
                tombolArray: [
                    (judul: "Back to Menu", gaya: .utama, tindakan: { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    })
                ]
            )
            dialog.tampilkan(dalam: self.view)
        }
    }
    
    private func tampilkanDialogWaktuHabis() {
        let skor = viewModel.skorSekarang
        
        // 添加粒子爆发效果
        let center = view.center
        PembuatEfekVisualTingkatTinggi.buatEfekParticleBurst(
            dariPosisi: center,
            diView: view,
            warna: TemaWarnaTinta.warnaPeringatan
        )
        
        // 添加触觉反馈
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .heavy)
        
        let dialog = DialogKustomSederhana(
            judul: "⏱ Time's Up!",
            pesan: "Final Score: \(skor) points",
            tombolArray: [
                (judul: "Back to Menu", gaya: .utama, tindakan: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
            ]
        )
        dialog.tampilkan(dalam: view)
    }
}

// MARK: - Tampilan Kartu Baru (New Card View)
class TampilanKartuBaru: UIView {
    
    var penangananKetuk: (() -> Void)?
    var adalahTerpilih: Bool = false
    
    private let kontainerUtama = UIView()
    private let gambarView = UIImageView()
    private let overlayPilihan = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturTampilan()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func konfigurasi(kartu: EntitasKartu) {
        gambarView.image = UIImage(named: kartu.namaAset)
    }
    
    func aturStatusPilihan(terpilih: Bool) {
        adalahTerpilih = terpilih
        
        UIView.animate(withDuration: 0.2) {
            self.overlayPilihan.alpha = terpilih ? 1.0 : 0.0
        }
    }
    
    func animasiBenar() {
        // 增强版动画：缩放 + 旋转 + 光晕
        let animasiSkala = CAKeyframeAnimation(keyPath: "transform.scale")
        animasiSkala.values = [1.0, 1.4, 1.2, 1.0]
        animasiSkala.keyTimes = [0, 0.3, 0.7, 1.0]
        animasiSkala.duration = 0.7
        
        let animasiRotasi = CAKeyframeAnimation(keyPath: "transform.rotation")
        animasiRotasi.values = [0, 0.1, -0.1, 0]
        animasiRotasi.keyTimes = [0, 0.3, 0.7, 1.0]
        animasiRotasi.duration = 0.7
        
        layer.add(animasiSkala, forKey: "correctScale")
        layer.add(animasiRotasi, forKey: "correctRotate")
        
        // 添加光晕效果
        PembuatEfekVisualTingkatTinggi.buatEfekGlow(untukView: self, warna: TemaWarnaTinta.warnaSukses, radius: 30)
        
        // 添加粒子爆发
        let center = superview?.convert(self.center, to: nil) ?? CGPoint.zero
        PembuatEfekVisualTingkatTinggi.buatEfekParticleBurst(dariPosisi: center, diView: self.superview ?? self, warna: TemaWarnaTinta.warnaSukses)
        
        let warnaAsli = kontainerUtama.backgroundColor
        UIView.animate(withDuration: 0.25, animations: {
            self.kontainerUtama.backgroundColor = TemaWarnaTinta.warnaSukses.withAlphaComponent(0.5)
        }) { _ in
            UIView.animate(withDuration: 0.4) {
                self.kontainerUtama.backgroundColor = warnaAsli
            }
        }
    }
    
    func animasiSalah() {
        // 增强版动画：震动 + 光晕
        let animasiGoyang = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animasiGoyang.values = [0, -15, 15, -15, 15, -10, 10, -5, 5, 0]
        animasiGoyang.keyTimes = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
        animasiGoyang.duration = 0.7
        
        let animasiRotasi = CAKeyframeAnimation(keyPath: "transform.rotation")
        animasiRotasi.values = [0, -0.1, 0.1, -0.05, 0]
        animasiRotasi.keyTimes = [0, 0.2, 0.4, 0.6, 1.0]
        animasiRotasi.duration = 0.7
        
        layer.add(animasiGoyang, forKey: "wrongShake")
        layer.add(animasiRotasi, forKey: "wrongRotate")
        
        // 添加红色光晕
        PembuatEfekVisualTingkatTinggi.buatEfekGlow(untukView: self, warna: TemaWarnaTinta.warnaError, radius: 25)
        
        let warnaAsli = kontainerUtama.backgroundColor
        UIView.animate(withDuration: 0.2, animations: {
            self.kontainerUtama.backgroundColor = TemaWarnaTinta.warnaError.withAlphaComponent(0.5)
        }) { _ in
            UIView.animate(withDuration: 0.4) {
                self.kontainerUtama.backgroundColor = warnaAsli
            }
        }
    }
    
    private func aturTampilan() {
        // Kontainer - 水墨风格
        addSubview(kontainerUtama)
        kontainerUtama.backgroundColor = TemaWarnaTinta.warnaLatarUtama
        kontainerUtama.layer.cornerRadius = 12
        kontainerUtama.layer.borderWidth = 2
        kontainerUtama.layer.borderColor = TemaWarnaTinta.warnaTintaTerang.cgColor
        PenciptaEfekTinta.terapkanShadowTinta(keView: kontainerUtama, intensitas: 0.12)
        
        // Gambar
        gambarView.contentMode = .scaleAspectFit
        gambarView.clipsToBounds = true
        kontainerUtama.addSubview(gambarView)
        
        // Overlay pilihan - 水墨风格选中效果
        overlayPilihan.backgroundColor = TemaWarnaTinta.warnaTintaHitam.withAlphaComponent(0.25)
        overlayPilihan.layer.cornerRadius = 12
        overlayPilihan.layer.borderWidth = 4
        overlayPilihan.layer.borderColor = TemaWarnaTinta.warnaTintaHitam.cgColor
        overlayPilihan.alpha = 0
        overlayPilihan.isUserInteractionEnabled = false
        kontainerUtama.addSubview(overlayPilihan)
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(tampilanDiketuk))
        addGestureRecognizer(tap)
        
        // Constraints
        kontainerUtama.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gambarView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.72)
        }
        
        overlayPilihan.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func tampilanDiketuk() {
        penangananKetuk?()
        
        // 增强动画：缩放 + 旋转 + 涟漪
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.88, y: 0.88).rotated(by: CGFloat.random(in: -0.08...0.08))
        }) { _ in
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 1.0,
                options: .curveEaseOut
            ) {
                self.transform = .identity
            }
        }
        
        // 添加涟漪效果
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let centerInSuperview = convert(center, to: superview)
        PembuatEfekVisualTingkatTinggi.buatEfekRipple(dariPosisi: centerInSuperview, diView: superview ?? self)
    }
}

