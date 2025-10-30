
import UIKit
import SnapKit
import Combine
import Alamofire
import ZunzhxGuzie

class PengendaliTampilanBerandaBaru: UIViewController {
    
    // MARK: - ViewModel
    private var viewModel: ViewModelBeranda!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var kontainerGulir: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private lazy var kontainerKonten: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var labelJudul: UILabel = {
        let label = UILabel()
        label.text = "Mahjong\nFollow Rules"
        label.font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        label.textColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.layer.shadowOpacity = 0.25
        label.layer.shadowRadius = 5
        return label
    }()
    
    private lazy var labelSubjudul: UILabel = {
        let label = UILabel()
        label.text = "🀄 Brain Teaser Puzzle"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var kartuModeTantangan: KartuModePermainan = {
        let kartu = KartuModePermainan()
        kartu.konfigurasi(
            ikon: "🎯",
            judul: "Challenge Mode",
            deskripsi: "Progress level by level\nTest your skills!",
            warnaGradien: [
                UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0).cgColor,
                UIColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
            ]
        )
        return kartu
    }()
    
    private lazy var kartuModeWaktu: KartuModePermainan = {
        let kartu = KartuModePermainan()
        kartu.konfigurasi(
            ikon: "⏱",
            judul: "Time Mode",
            deskripsi: "2 minutes challenge\nMaximize your score!",
            warnaGradien: [
                UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0).cgColor,
                UIColor(red: 0.1, green: 0.4, blue: 0.7, alpha: 1.0).cgColor
            ]
        )
        return kartu
    }()
    
    private lazy var tombolPeringkat: UIButton = {
        let tombol = buatTombolNavigasi(judul: "🏆 Leaderboard", warnaLatar: UIColor(red: 0.95, green: 0.7, blue: 0.2, alpha: 1.0))
        tombol.addTarget(self, action: #selector(tombolPeringkatDiketuk), for: .touchUpInside)
        return tombol
    }()
    
    private lazy var tombolPengaturan: UIButton = {
        let tombol = buatTombolNavigasi(judul: "⚙️ Settings", warnaLatar: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0))
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
        
        [labelJudul, labelSubjudul, kartuModeTantangan, kartuModeWaktu,
         tombolPeringkat, tombolPengaturan].forEach {
            kontainerKonten.addSubview($0)
        }
        
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
        }
        
        labelJudul.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(30)
        }
        
        labelSubjudul.snp.makeConstraints { make in
            make.top.equalTo(labelJudul.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        kartuModeTantangan.snp.makeConstraints { make in
            make.top.equalTo(labelSubjudul.snp.bottom).offset(60)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(190)
        }
        
        kartuModeWaktu.snp.makeConstraints { make in
            make.top.equalTo(kartuModeTantangan.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(190)
        }
        
        tombolPeringkat.snp.makeConstraints { make in
            make.top.equalTo(kartuModeWaktu.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(58)
        }
        
        tombolPengaturan.snp.makeConstraints { make in
            make.top.equalTo(tombolPeringkat.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(58)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    
    private func aturGaya() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1.0)
        
        // Tambahkan gradien latar
        let gradienLayer = CAGradientLayer()
        gradienLayer.frame = view.bounds
        gradienLayer.colors = [
            UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0).cgColor
        ]
        gradienLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradienLayer, at: 0)
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
    
    private func buatTombolNavigasi(judul: String, warnaLatar: UIColor) -> UIButton {
        let tombol = UIButton(type: .system)
        tombol.setTitle(judul, for: .normal)
        tombol.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        tombol.setTitleColor(.white, for: .normal)
        tombol.backgroundColor = warnaLatar
        tombol.layer.cornerRadius = 18
        tombol.layer.shadowColor = UIColor.black.cgColor
        tombol.layer.shadowOffset = CGSize(width: 0, height: 5)
        tombol.layer.shadowOpacity = 0.2
        tombol.layer.shadowRadius = 10
        
        // Tambahkan efek tekan
        tombol.addTarget(self, action: #selector(tombolDitekan(_:)), for: .touchDown)
        tombol.addTarget(self, action: #selector(tombolDilepas(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return tombol
    }
    
    @objc private func tombolDitekan(_ pengirim: UIButton) {
        UIView.animate(withDuration: 0.1) {
            pengirim.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            pengirim.alpha = 0.85
        }
    }
    
    @objc private func tombolDilepas(_ pengirim: UIButton) {
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
        let elementsToAnimate: [(view: UIView, delay: TimeInterval, direction: AnimationDirection)] = [
            (labelJudul, 0.1, .top),
            (labelSubjudul, 0.2, .top),
            (kartuModeTantangan, 0.3, .left),
            (kartuModeWaktu, 0.4, .right),
            (tombolPeringkat, 0.5, .bottom),
            (tombolPengaturan, 0.6, .bottom)
        ]
        
        for (view, delay, direction) in elementsToAnimate {
            view.alpha = 0
            view.transform = direction.initialTransform
            
            UIView.animate(
                withDuration: 0.7,
                delay: delay,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.6,
                options: .curveEaseOut
            ) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }
    
    enum AnimationDirection {
        case top, bottom, left, right
        
        var initialTransform: CGAffineTransform {
            switch self {
            case .top: return CGAffineTransform(translationX: 0, y: -40)
            case .bottom: return CGAffineTransform(translationX: 0, y: 40)
            case .left: return CGAffineTransform(translationX: -60, y: 0)
            case .right: return CGAffineTransform(translationX: 60, y: 0)
            }
        }
    }
}

// MARK: - Kartu Mode Permainan (Game Mode Card)
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

