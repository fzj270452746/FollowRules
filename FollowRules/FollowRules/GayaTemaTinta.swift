//
//  GayaTemaTinta.swift
//  FollowRules
//
//  Ink Painting Style Theme
//

import UIKit
import CoreGraphics

// MARK: - Tema Warna Tinta (Ink Color Theme)
struct TemaWarnaTinta {
    // Background Colors - 宣纸质感
    static let warnaLatarUtama = UIColor(red: 0.99, green: 0.98, blue: 0.95, alpha: 1.0) // 宣纸白
    static let warnaLatarSekunder = UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1.0) // 淡米色
    static let warnaLatarTersier = UIColor(red: 0.93, green: 0.91, blue: 0.87, alpha: 1.0) // 米黄
    
    // Ink Colors - 墨色
    static let warnaTintaHitam = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) // 浓墨
    static let warnaTintaGelap = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) // 深墨
    static let warnaTintaSedang = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) // 中墨
    static let warnaTintaTerang = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // 淡墨
    static let warnaTintaSangatTerang = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) // 极淡墨
    
    // Accent Colors - 淡彩
    static let warnaAksenBiru = UIColor(red: 0.3, green: 0.45, blue: 0.55, alpha: 1.0) // 淡青
    static let warnaAksenMerah = UIColor(red: 0.65, green: 0.3, blue: 0.3, alpha: 1.0) // 淡朱
    static let warnaAksenHijau = UIColor(red: 0.35, green: 0.55, blue: 0.4, alpha: 1.0) // 淡绿
    
    // 强烈色彩 - 增强视觉冲击
    static let warnaMerahTua = UIColor(red: 0.75, green: 0.15, blue: 0.15, alpha: 1.0) // 朱红
    static let warnaBiruTua = UIColor(red: 0.2, green: 0.35, blue: 0.65, alpha: 1.0) // 群青
    static let warnaHijauTua = UIColor(red: 0.25, green: 0.65, blue: 0.35, alpha: 1.0) // 石绿
    static let warnaKuningTua = UIColor(red: 0.85, green: 0.65, blue: 0.2, alpha: 1.0) // 藤黄
    static let warnaUnguTua = UIColor(red: 0.55, green: 0.3, blue: 0.65, alpha: 1.0) // 紫色
    static let warnaOranyeTua = UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1.0) // 橘色
    
    // 渐变色彩组合
    static let gradienMerah = [UIColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 1.0), UIColor(red: 0.6, green: 0.1, blue: 0.1, alpha: 1.0)]
    static let gradienBiru = [UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0), UIColor(red: 0.15, green: 0.3, blue: 0.6, alpha: 1.0)]
    static let gradienHijau = [UIColor(red: 0.35, green: 0.75, blue: 0.45, alpha: 1.0), UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0)]
    static let gradienUngu = [UIColor(red: 0.7, green: 0.4, blue: 0.8, alpha: 1.0), UIColor(red: 0.5, green: 0.25, blue: 0.6, alpha: 1.0)]
    
    // Overlay Colors
    static let warnaOverlayGelap = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.7)
    static let warnaOverlayTerang = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)
    
    // Status Colors
    static let warnaSukses = UIColor(red: 0.25, green: 0.5, blue: 0.35, alpha: 1.0) // 墨绿
    static let warnaPeringatan = UIColor(red: 0.65, green: 0.5, blue: 0.3, alpha: 1.0) // 赭色
    static let warnaError = UIColor(red: 0.6, green: 0.35, blue: 0.35, alpha: 1.0) // 淡红
}

// MARK: - Pencipta Efek Tinta (Ink Effect Creator)
class PenciptaEfekTinta {
    
    // Membuat efek tepi bergerigi seperti brush stroke
    static func buatEfekTepiBrushtroke(untukView view: UIView, radius: CGFloat = 8) {
        let path = UIBezierPath()
        let rect = view.bounds
        
        // Buat tepi tidak rata seperti brush stroke
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: radius * 0.8, y: radius * 0.3),
            CGPoint(x: radius * 1.2, y: radius * 0.7),
            CGPoint(x: radius * 0.5, y: radius),
            CGPoint(x: rect.width - radius, y: 0),
            CGPoint(x: rect.width - radius * 0.3, y: radius * 0.5),
            CGPoint(x: rect.width, y: radius),
            CGPoint(x: rect.width, y: rect.height - radius),
            CGPoint(x: rect.width - radius * 0.5, y: rect.height - radius * 0.3),
            CGPoint(x: rect.width - radius, y: rect.height),
            CGPoint(x: radius, y: rect.height),
            CGPoint(x: radius * 0.7, y: rect.height - radius * 0.2),
            CGPoint(x: 0, y: rect.height - radius)
        ]
        
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        path.close()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
    
    // Membuat shadow seperti tinta menyerap ke kertas
    static func terapkanShadowTinta(keView view: UIView, intensitas: CGFloat = 0.15) {
        view.layer.shadowColor = TemaWarnaTinta.warnaTintaHitam.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowOpacity = Float(intensitas)
        view.layer.shadowRadius = 8
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
    }
    
    // Membuat efek tekstur kertas
    static func buatEfekTeksturKertas(untukView view: UIView) {
        let textureLayer = CALayer()
        textureLayer.frame = view.bounds
        textureLayer.opacity = 0.03
        
        // Buat pola tekstur sederhana
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(TemaWarnaTinta.warnaTintaHitam.cgColor)
        context.setLineWidth(0.5)
        
        // Gambar garis tekstur
        for i in 0..<Int(view.bounds.height) where i % 3 == 0 {
            context.move(to: CGPoint(x: 0, y: CGFloat(i)))
            context.addLine(to: CGPoint(x: view.bounds.width, y: CGFloat(i)))
            context.strokePath()
        }
        
        if let textureImage = UIGraphicsGetImageFromCurrentImageContext() {
            textureLayer.contents = textureImage.cgImage
            view.layer.addSublayer(textureLayer)
        }
    }
    
    // Membuat gradien tinta
    static func buatGradienTinta(dariWarna: UIColor, keWarna: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [dariWarna.cgColor, keWarna.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }
}

// MARK: - Komponen Tinta (Ink Components)
class LabelTinta: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturGayaTinta()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        aturGayaTinta()
    }
    
    private func aturGayaTinta() {
        self.textColor = TemaWarnaTinta.warnaTintaHitam
        self.font = UIFont.systemFont(ofSize: font.pointSize, weight: .medium)
    }
    
    func setGayaTinta(ukuran: CGFloat, berat: UIFont.Weight = .medium, warna: UIColor = TemaWarnaTinta.warnaTintaHitam) {
        self.font = UIFont.systemFont(ofSize: ukuran, weight: berat)
        self.textColor = warna
    }
}

class TombolTinta: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturGayaTinta()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        aturGayaTinta()
    }
    
    private func aturGayaTinta() {
        self.layer.cornerRadius = 12
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        PenciptaEfekTinta.terapkanShadowTinta(keView: self, intensitas: 0.12)
    }
    
    func setGayaTintaDasar(warnaLatar: UIColor = TemaWarnaTinta.warnaTintaHitam, warnaTeks: UIColor = TemaWarnaTinta.warnaLatarUtama) {
        self.backgroundColor = warnaLatar
        self.setTitleColor(warnaTeks, for: .normal)
    }
    
    func setGayaTintaGradien(warnaAwal: UIColor, warnaAkhir: UIColor, warnaTeks: UIColor = TemaWarnaTinta.warnaLatarUtama) {
        let gradientLayer = PenciptaEfekTinta.buatGradienTinta(dariWarna: warnaAwal, keWarna: warnaAkhir)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        layer.insertSublayer(gradientLayer, at: 0)
        self.setTitleColor(warnaTeks, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
    }
}

class KontainerTinta: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturGayaTinta()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        aturGayaTinta()
    }
    
    private func aturGayaTinta() {
        self.backgroundColor = TemaWarnaTinta.warnaLatarUtama
        self.layer.cornerRadius = 16
        PenciptaEfekTinta.terapkanShadowTinta(keView: self, intensitas: 0.08)
        
        // Tambahkan efek tekstur kertas
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            PenciptaEfekTinta.buatEfekTeksturKertas(untukView: self)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        PenciptaEfekTinta.terapkanShadowTinta(keView: self, intensitas: 0.08)
    }
}

// MARK: - Kartu Mode Permainan Tinta
class KartuModePermainanTinta: UIView {
    
    var tindakanKetuk: (() -> Void)?
    
    private let kontainerGradien = UIView()
    private let labelIkon = UILabel()
    private let labelJudul = LabelTinta()
    private let labelDeskripsi = LabelTinta()
    private let lapisanGradien = CAGradientLayer()
    private let lapisanTekstur = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturTampilan()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lapisanGradien.frame = kontainerGradien.bounds
        lapisanTekstur.frame = kontainerGradien.bounds
    }
    
    func konfigurasi(ikon: String, judul: String, deskripsi: String, warnaGradien: [CGColor]) {
        labelIkon.text = ikon
        labelJudul.text = judul
        labelDeskripsi.text = deskripsi
        lapisanGradien.colors = warnaGradien
        
        // Aktifkan gradien流动动画
        PembuatEfekVisualTingkatTinggi.buatAnimasiGradienMengalir(
            untukLayer: lapisanGradien,
            warna: warnaGradien.compactMap { UIColor(cgColor: $0) }
        )
    }
    
    private func aturTampilan() {
        // Kontainer dengan gradien tinta
        addSubview(kontainerGradien)
        kontainerGradien.layer.cornerRadius = 20
        kontainerGradien.layer.masksToBounds = true
        
        // Shadow seperti tinta
        PenciptaEfekTinta.terapkanShadowTinta(keView: kontainerGradien, intensitas: 0.2)
        
        lapisanGradien.locations = [0.0, 1.0]
        lapisanGradien.startPoint = CGPoint(x: 0, y: 0)
        lapisanGradien.endPoint = CGPoint(x: 1, y: 1)
        kontainerGradien.layer.insertSublayer(lapisanGradien, at: 0)
        
        // Ikon - lebih besar untuk efek tinta
        labelIkon.font = UIFont.systemFont(ofSize: 64)
        labelIkon.textAlignment = .center
        labelIkon.alpha = 0.95
        kontainerGradien.addSubview(labelIkon)
        
        // Judul
        labelJudul.setGayaTinta(ukuran: 26, berat: .bold, warna: .white)
        labelJudul.textAlignment = .center
        labelJudul.alpha = 0.95
        kontainerGradien.addSubview(labelJudul)
        
        // Deskripsi
        labelDeskripsi.setGayaTinta(ukuran: 16, berat: .medium, warna: UIColor.white.withAlphaComponent(0.9))
        labelDeskripsi.textAlignment = .center
        labelDeskripsi.numberOfLines = 2
        kontainerGradien.addSubview(labelDeskripsi)
        
        // Constraints
        kontainerGradien.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        labelIkon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
        }
        
        labelJudul.snp.makeConstraints { make in
            make.top.equalTo(labelIkon.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        labelDeskripsi.snp.makeConstraints { make in
            make.top.equalTo(labelJudul.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(tampilanDiketuk))
        addGestureRecognizer(tap)
    }
    
    @objc private func tampilanDiketuk() {
        tindakanKetuk?()
        
        // 增强动画：缩放 + 粒子效果
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            self.alpha = 0.85
        }) { _ in
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 1.0,
                options: .curveEaseOut
            ) {
                self.transform = .identity
                self.alpha = 1.0
            }
        }
        
        // 添加水墨晕染效果
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let centerInSuperview = convert(center, to: superview)
        PembuatEfekVisualTingkatTinggi.buatAnimasiInkBlot(untukView: self, dariPosisi: centerInSuperview)
        
        // 添加触觉反馈
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .medium)
    }
}

