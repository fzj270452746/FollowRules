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
    private lazy var kontainerHeader: UIView = {
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
    
    private lazy var labelTingkat: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var labelSkor: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private lazy var labelWaktu: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private lazy var kontainerAturan: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var labelAturan: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.textColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
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
    
    private lazy var tombolVerifikasi: UIButton = {
        let tombol = UIButton(type: .system)
        tombol.setTitle("✓ Check Answer", for: .normal)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        tombol.setTitleColor(.white, for: .normal)
        tombol.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        tombol.layer.cornerRadius = 18
        tombol.layer.shadowColor = UIColor.black.cgColor
        tombol.layer.shadowOffset = CGSize(width: 0, height: 6)
        tombol.layer.shadowOpacity = 0.25
        tombol.layer.shadowRadius = 12
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
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1.0)
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
                    self?.labelWaktu.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
                } else {
                    self?.labelWaktu.textColor = .white
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
            
            // Animasi masuk
            tampilanKartu.alpha = 0
            tampilanKartu.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            
            UIView.animate(
                withDuration: 0.5,
                delay: Double(indeks) * 0.04,
                usingSpringWithDamping: 0.65,
                initialSpringVelocity: 0.6,
                options: .curveEaseOut
            ) {
                tampilanKartu.alpha = 1
                tampilanKartu.transform = .identity
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
        // Animasi kartu benar
        for tampilan in tampilanKartuArray {
            if tampilan.adalahTerpilih {
                tampilan.animasiBenar()
            }
        }
        
        // Delay dialog
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
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
        // Animasi kartu salah - hanya untuk kartu yang terpilih
        for tampilan in tampilanKartuArray {
            if tampilan.adalahTerpilih {
                tampilan.animasiSalah()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
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
        let animasiSkala = CAKeyframeAnimation(keyPath: "transform.scale")
        animasiSkala.values = [1.0, 1.3, 1.0]
        animasiSkala.keyTimes = [0, 0.5, 1.0]
        animasiSkala.duration = 0.5
        
        layer.add(animasiSkala, forKey: "correct")
        
        let warnaAsli = kontainerUtama.backgroundColor
        UIView.animate(withDuration: 0.25, animations: {
            self.kontainerUtama.backgroundColor = UIColor(red: 0.2, green: 0.95, blue: 0.3, alpha: 0.5)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.kontainerUtama.backgroundColor = warnaAsli
            }
        }
    }
    
    func animasiSalah() {
        let animasiGoyang = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animasiGoyang.values = [0, -12, 12, -12, 12, -8, 8, -4, 4, 0]
        animasiGoyang.keyTimes = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
        animasiGoyang.duration = 0.6
        
        layer.add(animasiGoyang, forKey: "wrong")
        
        let warnaAsli = kontainerUtama.backgroundColor
        UIView.animate(withDuration: 0.2, animations: {
            self.kontainerUtama.backgroundColor = UIColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 0.5)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.kontainerUtama.backgroundColor = warnaAsli
            }
        }
    }
    
    private func aturTampilan() {
        // Kontainer
        addSubview(kontainerUtama)
        kontainerUtama.backgroundColor = .white
        kontainerUtama.layer.cornerRadius = 10
        kontainerUtama.layer.borderWidth = 2.5
        kontainerUtama.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.88, alpha: 1.0).cgColor
        kontainerUtama.layer.shadowColor = UIColor.black.cgColor
        kontainerUtama.layer.shadowOffset = CGSize(width: 0, height: 3)
        kontainerUtama.layer.shadowOpacity = 0.18
        kontainerUtama.layer.shadowRadius = 6
        
        // Gambar
        gambarView.contentMode = .scaleAspectFit
        gambarView.clipsToBounds = true
        kontainerUtama.addSubview(gambarView)
        
        // Overlay pilihan
        overlayPilihan.backgroundColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.45)
        overlayPilihan.layer.cornerRadius = 10
        overlayPilihan.layer.borderWidth = 5
        overlayPilihan.layer.borderColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
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
        
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }) { _ in
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.8,
                options: .curveEaseOut
            ) {
                self.transform = .identity
            }
        }
    }
}

