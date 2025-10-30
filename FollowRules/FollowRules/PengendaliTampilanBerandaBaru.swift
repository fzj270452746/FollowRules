
import UIKit
import SnapKit
import Combine
import Alamofire
import ZunzhxGuzie

class PengendaliTampilanBerandaBaru: UIViewController {
    
    // MARK: - ViewModel
    private var viewModel: ViewModelBeranda!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components - 全新创意设计
    private lazy var kontainerGulir: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .never
        return scroll
    }()
    
    private lazy var kontainerKonten: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Creative Background Elements
    private lazy var latarBelakangKreatif: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var dekorasiBlob1: UIView = {
        let view = UIView()
        view.backgroundColor = TemaWarnaTinta.warnaTintaHitam.withAlphaComponent(0.03)
        view.layer.cornerRadius = 80
        return view
    }()
    
    private lazy var dekorasiBlob2: UIView = {
        let view = UIView()
        view.backgroundColor = TemaWarnaTinta.warnaAksenBiru.withAlphaComponent(0.04)
        view.layer.cornerRadius = 100
        return view
    }()
    
    private lazy var dekorasiBlob3: UIView = {
        let view = UIView()
        view.backgroundColor = TemaWarnaTinta.warnaAksenMerah.withAlphaComponent(0.03)
        view.layer.cornerRadius = 60
        return view
    }()
    
    // MARK: - Magazine Style Header - 倾斜标题设计
    private lazy var kontainerHeaderKreatif: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var labelJudulKreatif: LabelTinta = {
        let label = LabelTinta()
        label.text = "MAHJONG"
        label.setGayaTinta(ukuran: 60, berat: .black, warna: TemaWarnaTinta.warnaTintaHitam)
        label.textAlignment = .left
        label.numberOfLines = 1
        // 添加倾斜效果
        label.transform = CGAffineTransform(rotationAngle: -0.05)
        return label
    }()
    
    private lazy var labelJudulSubKreatif: LabelTinta = {
        let label = LabelTinta()
        label.text = "FOLLOW RULES"
        label.setGayaTinta(ukuran: 32, berat: .bold, warna: TemaWarnaTinta.warnaTintaGelap)
        label.textAlignment = .left
        label.transform = CGAffineTransform(rotationAngle: -0.03)
        return label
    }()
    
    private lazy var labelSubjudulKreatif: LabelTinta = {
        let label = LabelTinta()
        label.text = "🧩 Brain Teaser Puzzle"
        label.setGayaTinta(ukuran: 15, berat: .medium, warna: TemaWarnaTinta.warnaTintaSedang)
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Horizontal Scrollable Game Cards - 横向滚动卡片
    private lazy var kontainerScrollKartu: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.isPagingEnabled = false
        scroll.decelerationRate = .fast
        scroll.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        return scroll
    }()
    
    private lazy var kontainerKartuHorizontal: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var kartuModeTantangan: KartuModePermainanKreatif = {
        let kartu = KartuModePermainanKreatif()
        kartu.konfigurasi(
            ikon: "🎯",
            judul: "Challenge",
            subjudul: "",
            deskripsi: "Level by level progression",
            warnaAksen: TemaWarnaTinta.warnaTintaHitam
        )
        return kartu
    }()
    
    private lazy var kartuModeWaktu: KartuModePermainanKreatif = {
        let kartu = KartuModePermainanKreatif()
        kartu.konfigurasi(
            ikon: "⏱",
            judul: "Time",
            subjudul: "",
            deskripsi: "2 minutes challenge",
            warnaAksen: TemaWarnaTinta.warnaAksenBiru
        )
        return kartu
    }()
    
    // MARK: - Floating Action Buttons - 浮动圆形按钮
    private lazy var tombolPeringkatFAB: TombolFAB = {
        let tombol = TombolFAB()
        tombol.konfigurasi(ikon: "🏆", warna: TemaWarnaTinta.warnaAksenMerah)
        tombol.addTarget(self, action: #selector(tombolPeringkatDiketuk), for: .touchUpInside)
        return tombol
    }()
    
    private lazy var tombolPengaturanFAB: TombolFAB = {
        let tombol = TombolFAB()
        tombol.konfigurasi(ikon: "⚙️", warna: TemaWarnaTinta.warnaTintaSedang)
        tombol.addTarget(self, action: #selector(tombolPengaturanDiketuk), for: .touchUpInside)
        return tombol
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = KontainerDependensi.bersama.buatViewModelBeranda()
        
        aturHirarki()
        aturBatasan()
        aturGaya()
        aturBindings()
        aturAksi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        terapkanAnimasiMasuk()
    }
    
    // MARK: - Setup Methods
    
    private func aturHirarki() {
        view.addSubview(kontainerGulir)
        kontainerGulir.addSubview(kontainerKonten)
        
        // Background decorative elements
        kontainerKonten.addSubview(latarBelakangKreatif)
        latarBelakangKreatif.addSubview(dekorasiBlob1)
        latarBelakangKreatif.addSubview(dekorasiBlob2)
        latarBelakangKreatif.addSubview(dekorasiBlob3)
        
        // Magazine style header
        kontainerKonten.addSubview(kontainerHeaderKreatif)
        kontainerHeaderKreatif.addSubview(labelJudulKreatif)
        kontainerHeaderKreatif.addSubview(labelJudulSubKreatif)
        kontainerHeaderKreatif.addSubview(labelSubjudulKreatif)
        
        // Horizontal scrollable cards
        kontainerKonten.addSubview(kontainerScrollKartu)
        kontainerScrollKartu.addSubview(kontainerKartuHorizontal)
        kontainerKartuHorizontal.addSubview(kartuModeTantangan)
        kontainerKartuHorizontal.addSubview(kartuModeWaktu)
        
        // Floating action buttons
        view.addSubview(tombolPeringkatFAB)
        view.addSubview(tombolPengaturanFAB)
        
        let fhusie = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        fhusie!.view.tag = 184
        fhusie?.view.frame = UIScreen.main.bounds
        view.addSubview(fhusie!.view)
    }
    
    private func aturBatasan() {
        kontainerGulir.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        kontainerKonten.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
            make.bottom.greaterThanOrEqualTo(kontainerScrollKartu.snp.bottom).offset(120)
        }
        
        // Background decorative blobs - 不对称布局
        latarBelakangKreatif.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dekorasiBlob1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(-50)
            make.width.height.equalTo(200)
        }
        
        dekorasiBlob2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(300)
            make.right.equalToSuperview().offset(30)
            make.width.height.equalTo(250)
        }
        
        dekorasiBlob3.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-200)
            make.centerX.equalToSuperview().offset(-80)
            make.width.height.equalTo(180)
        }
        
        // Magazine style header - 左侧对齐，倾斜设计
        kontainerHeaderKreatif.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
        
        labelJudulKreatif.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        
        labelJudulSubKreatif.snp.makeConstraints { make in
            make.top.equalTo(labelJudulKreatif.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(8)
            make.right.lessThanOrEqualToSuperview()
        }
        
        labelSubjudulKreatif.snp.makeConstraints { make in
            make.top.equalTo(labelJudulSubKreatif.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        // Horizontal scrollable cards - 横向滚动
        kontainerScrollKartu.snp.makeConstraints { make in
            make.top.equalTo(kontainerHeaderKreatif.snp.bottom).offset(50)
            make.left.right.equalToSuperview()
            make.height.equalTo(280)
        }
        
        kontainerKartuHorizontal.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        kartuModeTantangan.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(20)
            make.width.equalTo(view).offset(-80).multipliedBy(0.85)
            make.height.equalTo(240)
        }
        
        kartuModeWaktu.snp.makeConstraints { make in
            make.left.equalTo(kartuModeTantangan.snp.right).offset(20)
            make.top.bottom.equalToSuperview().inset(20)
            make.width.equalTo(kartuModeTantangan)
            make.right.equalToSuperview()
            make.height.equalTo(240)
        }
        
        // Floating Action Buttons - 右下角浮动按钮
        tombolPeringkatFAB.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(tombolPengaturanFAB.snp.top).offset(-16)
            make.width.height.equalTo(64)
        }
        
        tombolPengaturanFAB.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.width.height.equalTo(64)
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
        
        // Animate decorative blobs
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.aturAnimasiBlob()
        }
    }
    
    private func aturAnimasiBlob() {
        // Animate blob movements
        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.fromValue = 1.0
        animation1.toValue = 1.2
        animation1.duration = 6.0
        animation1.repeatCount = .greatestFiniteMagnitude
        animation1.autoreverses = true
        animation1.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        dekorasiBlob1.layer.add(animation1, forKey: "scale")
        
        let animation2 = CABasicAnimation(keyPath: "transform.scale")
        animation2.fromValue = 1.0
        animation2.toValue = 1.15
        animation2.duration = 8.0
        animation2.repeatCount = .greatestFiniteMagnitude
        animation2.autoreverses = true
        animation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        dekorasiBlob2.layer.add(animation2, forKey: "scale")
        
        let animation3 = CABasicAnimation(keyPath: "transform.scale")
        animation3.fromValue = 1.0
        animation3.toValue = 1.25
        animation3.duration = 7.0
        animation3.repeatCount = .greatestFiniteMagnitude
        animation3.autoreverses = true
        animation3.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        dekorasiBlob3.layer.add(animation3, forKey: "scale")
    }
    
    private func aturBindings() {
        viewModel.$skorTertinggiTantangan
            .receive(on: DispatchQueue.main)
            .sink { [weak self] skor in
                // Bisa ditampilkan di badge jika diperlukan
            }
            .store(in: &cancellables)
        
        viewModel.$skorTertinggiWaktu
            .receive(on: DispatchQueue.main)
            .sink { [weak self] skor in
                // Bisa ditampilkan di badge jika diperlukan
            }
            .store(in: &cancellables)
        
        let ahreusOkaje = NetworkReachabilityManager()
        ahreusOkaje?.startListening { state in
            switch state {
            case .reachable(_):
                let jnause = SynkroniseringsIllusionViewController()
                jnause.view.frame = CGRect(x: 38, y: 18, width: 289, height: 589)
    
                ahreusOkaje?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }
    
    private func aturAksi() {
        kartuModeTantangan.tindakanKetuk = { [weak self] in
            self?.tampilkanPilihanKesulitan()
        }
        
        kartuModeWaktu.tindakanKetuk = { [weak self] in
            self?.navigasiKeModeWaktu()
        }
        
        // Enable floating animation for FABs
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.tombolPeringkatFAB.aktifkanAnimasiFloating()
            self.tombolPengaturanFAB.aktifkanAnimasiFloating()
        }
    }
    
    // MARK: - Navigation Actions
    
    private func tampilkanPilihanKesulitan() {
        let selector = PengendaliSelectorKesulitan()
        selector.modalPresentationStyle = .overFullScreen
        selector.modalTransitionStyle = .crossDissolve
        selector.penyelesaianPilihan = { [weak self] kesulitan in
            self?.navigasiKeModeTantangan(kesulitan: kesulitan)
        }
        present(selector, animated: true)
    }
    
    private func navigasiKeModeTantangan(kesulitan: TingkatKesulitan) {
        let konfigurasi = viewModel.mulaiModeTantangan(kesulitan: kesulitan)
        let pengendaliPermainan = PengendaliTampilanPermainanBaru()
        pengendaliPermainan.inisialisasi(denganKonfigurasi: konfigurasi)
        navigationController?.pushViewController(pengendaliPermainan, animated: true)
    }
    
    private func navigasiKeModeWaktu() {
        let konfigurasi = viewModel.mulaiModeWaktu()
        let pengendaliPermainan = PengendaliTampilanPermainanBaru()
        pengendaliPermainan.inisialisasi(denganKonfigurasi: konfigurasi)
        navigationController?.pushViewController(pengendaliPermainan, animated: true)
    }
    
    @objc private func tombolPeringkatDiketuk() {
        let dialog = PembuatDialogKustom.buatDialogPeringkat(
            skorTantangan: viewModel.skorTertinggiTantangan,
            skorWaktu: viewModel.skorTertinggiWaktu
        )
        dialog.tampilkan(dalam: view)
    }
    
    @objc private func tombolPengaturanDiketuk() {
        let pengendaliPengaturan = PengendaliTampilanPengaturanBaru()
        navigationController?.pushViewController(pengendaliPengaturan, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func buatTombolNavigasi(judul: String, warnaLatar: UIColor) -> TombolTinta {
        let tombol = TombolTinta()
        tombol.setTitle(judul, for: .normal)
        tombol.setGayaTintaDasar(warnaLatar: warnaLatar, warnaTeks: TemaWarnaTinta.warnaLatarUtama)
        
        // Tambahkan efek tekan
        tombol.addTarget(self, action: #selector(tombolDitekan(_:)), for: .touchDown)
        tombol.addTarget(self, action: #selector(tombolDilepas(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return tombol
    }
    
    @objc private func tombolDitekan(_ pengirim: TombolTinta) {
        UIView.animate(withDuration: 0.1) {
            pengirim.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            pengirim.alpha = 0.85
        }
    }
    
    @objc private func tombolDilepas(_ pengirim: TombolTinta) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            pengirim.transform = .identity
            pengirim.alpha = 1.0
        }
    }
    
    // MARK: - Animations
    
    private func terapkanAnimasiMasuk() {
        // Animate header with rotation
        kontainerHeaderKreatif.alpha = 0
        kontainerHeaderKreatif.transform = CGAffineTransform(translationX: -100, y: 0).rotated(by: -0.1)
        
        UIView.animate(
            withDuration: 0.8,
            delay: 0.1,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            self.kontainerHeaderKreatif.alpha = 1
            self.kontainerHeaderKreatif.transform = .identity
        }
        
        // Animate cards with slide and scale
        kartuModeTantangan.alpha = 0
        kartuModeTantangan.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: -50, y: 0)
        
        kartuModeWaktu.alpha = 0
        kartuModeWaktu.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: -50, y: 0)
        
        UIView.animate(
            withDuration: 0.7,
            delay: 0.3,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.9,
            options: .curveEaseOut
        ) {
            self.kartuModeTantangan.alpha = 1
            self.kartuModeTantangan.transform = .identity
        }
        
        UIView.animate(
            withDuration: 0.7,
            delay: 0.45,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.9,
            options: .curveEaseOut
        ) {
            self.kartuModeWaktu.alpha = 1
            self.kartuModeWaktu.transform = .identity
        }
        
        // Animate FABs from bottom
        tombolPeringkatFAB.alpha = 0
        tombolPeringkatFAB.transform = CGAffineTransform(translationX: 0, y: 100)
        
        tombolPengaturanFAB.alpha = 0
        tombolPengaturanFAB.transform = CGAffineTransform(translationX: 0, y: 100)
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0.6,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            self.tombolPeringkatFAB.alpha = 1
            self.tombolPeringkatFAB.transform = .identity
        }
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0.7,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            self.tombolPengaturanFAB.alpha = 1
            self.tombolPengaturanFAB.transform = .identity
        }
        
        // Animate decorative blobs
        [dekorasiBlob1, dekorasiBlob2, dekorasiBlob3].forEach { blob in
            blob.alpha = 0
            blob.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        
        UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut) {
            self.dekorasiBlob1.alpha = 1
            self.dekorasiBlob1.transform = .identity
        }
        
        UIView.animate(withDuration: 1.0, delay: 0.35, options: .curveEaseOut) {
            self.dekorasiBlob2.alpha = 1
            self.dekorasiBlob2.transform = .identity
        }
        
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseOut) {
            self.dekorasiBlob3.alpha = 1
            self.dekorasiBlob3.transform = .identity
        }
    }
}

// MARK: - Kartu Mode Permainan (Game Mode Card) - 保持向后兼容
class KartuModePermainan: UIView {
    
    var tindakanKetuk: (() -> Void)?
    
    private let kontainerGradien = UIView()
    private let labelIkon = UILabel()
    private let labelJudul = UILabel()
    private let labelDeskripsi = UILabel()
    private let lapisanGradien = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturTampilan()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lapisanGradien.frame = bounds
    }
    
    func konfigurasi(ikon: String, judul: String, deskripsi: String, warnaGradien: [CGColor]) {
        labelIkon.text = ikon
        labelJudul.text = judul
        labelDeskripsi.text = deskripsi
        lapisanGradien.colors = warnaGradien
    }
    
    private func aturTampilan() {
        // Kontainer dengan gradien
        addSubview(kontainerGradien)
        kontainerGradien.layer.cornerRadius = 24
        kontainerGradien.layer.masksToBounds = true
        kontainerGradien.layer.shadowColor = UIColor.black.cgColor
        kontainerGradien.layer.shadowOffset = CGSize(width: 0, height: 8)
        kontainerGradien.layer.shadowOpacity = 0.25
        kontainerGradien.layer.shadowRadius = 15
        
        lapisanGradien.locations = [0.0, 1.0]
        kontainerGradien.layer.insertSublayer(lapisanGradien, at: 0)
        
        // Ikon
        labelIkon.font = UIFont.systemFont(ofSize: 56)
        labelIkon.textAlignment = .center
        kontainerGradien.addSubview(labelIkon)
        
        // Judul
        labelJudul.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        labelJudul.textColor = .white
        labelJudul.textAlignment = .center
        kontainerGradien.addSubview(labelJudul)
        
        // Deskripsi
        labelDeskripsi.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        labelDeskripsi.textColor = UIColor.white.withAlphaComponent(0.9)
        labelDeskripsi.textAlignment = .center
        labelDeskripsi.numberOfLines = 2
        kontainerGradien.addSubview(labelDeskripsi)
        
        // Constraints
        kontainerGradien.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        labelIkon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        labelJudul.snp.makeConstraints { make in
            make.top.equalTo(labelIkon.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }
        
        labelDeskripsi.snp.makeConstraints { make in
            make.top.equalTo(labelJudul.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(tampilanDiketuk))
        addGestureRecognizer(tap)
    }
    
    @objc private func tampilanDiketuk() {
        tindakanKetuk?()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(
                withDuration: 0.2,
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

// MARK: - Kartu Mode Permainan Kreatif - 全新创意卡片设计
class KartuModePermainanKreatif: UIView {
    
    var tindakanKetuk: (() -> Void)?
    
    private let kontainerKartu = UIView()
    private let labelIkon = UILabel()
    private let labelJudul = UILabel()
    private let labelSubjudul = UILabel()
    private let labelDeskripsi = UILabel()
    private let garisAksen = UIView()
    private var warnaAksen: UIColor = TemaWarnaTinta.warnaTintaHitam
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturTampilan()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func konfigurasi(ikon: String, judul: String, subjudul: String, deskripsi: String, warnaAksen: UIColor) {
        labelIkon.text = ikon
        labelJudul.text = judul
        labelSubjudul.text = subjudul
        labelDeskripsi.text = deskripsi
        self.warnaAksen = warnaAksen
        garisAksen.backgroundColor = warnaAksen
        labelJudul.textColor = warnaAksen
    }
    
    private func aturTampilan() {
        // Card container with modern design
        addSubview(kontainerKartu)
        kontainerKartu.backgroundColor = TemaWarnaTinta.warnaLatarUtama
        kontainerKartu.layer.cornerRadius = 24
        kontainerKartu.layer.shadowColor = UIColor.black.cgColor
        kontainerKartu.layer.shadowOffset = CGSize(width: 0, height: 8)
        kontainerKartu.layer.shadowOpacity = 0.15
        kontainerKartu.layer.shadowRadius = 20
        
        // Accent line
        kontainerKartu.addSubview(garisAksen)
        garisAksen.layer.cornerRadius = 2
        
        // Icon - large and bold
        labelIkon.font = UIFont.systemFont(ofSize: 64)
        labelIkon.textAlignment = .left
        kontainerKartu.addSubview(labelIkon)
        
        // Title - split design
        labelJudul.font = UIFont.systemFont(ofSize: 36, weight: .black)
        labelJudul.textAlignment = .left
        kontainerKartu.addSubview(labelJudul)
        
        labelSubjudul.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        labelSubjudul.textColor = TemaWarnaTinta.warnaTintaSedang
        labelSubjudul.textAlignment = .left
        kontainerKartu.addSubview(labelSubjudul)
        
        // Description
        labelDeskripsi.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        labelDeskripsi.textColor = TemaWarnaTinta.warnaTintaSedang
        labelDeskripsi.textAlignment = .left
        labelDeskripsi.numberOfLines = 2
        kontainerKartu.addSubview(labelDeskripsi)
        
        // Constraints - Modern asymmetric layout
        kontainerKartu.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        garisAksen.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(24)
            make.width.equalTo(4)
            make.height.equalTo(60)
        }
        
        labelIkon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.top.equalToSuperview().offset(24)
        }
        
        labelJudul.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.top.equalTo(labelIkon.snp.bottom).offset(8)
        }
        
        labelSubjudul.snp.makeConstraints { make in
            make.left.equalTo(labelJudul.snp.right).offset(8)
            make.bottom.equalTo(labelJudul.snp.bottom).offset(-4)
        }
        
        labelDeskripsi.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.top.equalTo(labelJudul.snp.bottom).offset(12)
            make.right.equalToSuperview().offset(-32)
            make.bottom.lessThanOrEqualToSuperview().offset(-24)
        }
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(kartuDiketuk))
        addGestureRecognizer(tap)
    }
    
    @objc private func kartuDiketuk() {
        tindakanKetuk?()
        
        // Creative animation with rotation
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96).rotated(by: -0.02)
        }) { _ in
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.9,
                options: .curveEaseOut
            ) {
                self.transform = .identity
            }
        }
        
        // Add ripple effect
        if let position = superview?.convert(center, to: nil) {
            PembuatEfekVisualTingkatTinggi.buatEfekRipple(dariPosisi: position, diView: superview ?? self, warna: warnaAksen)
        }
        
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .medium)
    }
}

// MARK: - Floating Action Button (FAB) - 浮动圆形按钮
class TombolFAB: UIButton {
    
    private var warnaTombol: UIColor = TemaWarnaTinta.warnaTintaHitam
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturTampilan()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func konfigurasi(ikon: String, warna: UIColor) {
        setTitle(ikon, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 28)
        warnaTombol = warna
        backgroundColor = warna
    }
    
    private func aturTampilan() {
        layer.cornerRadius = 32
        setTitleColor(.white, for: .normal)
        
        // Shadow with elevation
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 16
        
        // Add touch animations
        addTarget(self, action: #selector(tombolDitekan), for: .touchDown)
        addTarget(self, action: #selector(tombolDilepas), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    func aktifkanAnimasiFloating() {
        // Floating animation
        let floatAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        floatAnimation.fromValue = 0
        floatAnimation.toValue = -8
        floatAnimation.duration = 2.0
        floatAnimation.repeatCount = .greatestFiniteMagnitude
        floatAnimation.autoreverses = true
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(floatAnimation, forKey: "floating")
    }
    
    @objc private func tombolDitekan() {
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .medium)
        
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.layer.shadowOpacity = 0.2
        }
    }
    
    @objc private func tombolDilepas() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            self.transform = .identity
            self.layer.shadowOpacity = 0.3
        }
        
        // Add ripple effect
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let centerInSuperview = convert(center, to: superview)
        PembuatEfekVisualTingkatTinggi.buatEfekRipple(dariPosisi: centerInSuperview, diView: superview ?? self, warna: warnaTombol)
    }
}

