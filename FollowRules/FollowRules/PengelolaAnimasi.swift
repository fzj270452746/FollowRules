//
//  PengelolaAnimasi.swift
//  FollowRules
//
//  Animation Coordinator & Effects Manager
//

import UIKit
import QuartzCore

// MARK: - Koordinator Animasi (Animation Coordinator)
class KoordinatorAnimasi: ProtocolKoordinatorAnimasi {
    
    private var animasiAktif: [String: CALayer] = [:]
    private let pembuatEfekPartikel: PembuatEfekPartikel
    
    init(pembuatEfekPartikel: PembuatEfekPartikel = PembuatEfekPartikel()) {
        self.pembuatEfekPartikel = pembuatEfekPartikel
    }
    
    func tampilkanAnimasi(_ jenisAnimasi: JenisAnimasi, padaKonteks konteks: KonteksAnimasi) {
        switch jenisAnimasi {
        case .munculKartu:
            tampilkanAnimasiMunculKartu(konteks: konteks)
        case .hilangKartu:
            tampilkanAnimasiHilangKartu(konteks: konteks)
        case .pilihanKartu:
            tampilkanAnimasiPilihanKartu(konteks: konteks)
        case .jawabanBenar:
            tampilkanAnimasiJawabanBenar(konteks: konteks)
        case .jawabanSalah:
            tampilkanAnimasiJawabanSalah(konteks: konteks)
        case .transisiTingkat:
            tampilkanAnimasiTransisiTingkat(konteks: konteks)
        case .efekKonfeti:
            tampilkanEfekKonfeti(konteks: konteks)
        case .efekKilau:
            tampilkanEfekKilau(konteks: konteks)
        case .peringatanWaktu:
            tampilkanAnimasiPeringatanWaktu(konteks: konteks)
        }
    }
    
    func hentikanSemuaAnimasi() {
        animasiAktif.values.forEach { $0.removeFromSuperlayer() }
        animasiAktif.removeAll()
    }
    
    // MARK: - Private Animation Methods
    
    private func tampilkanAnimasiMunculKartu(konteks: KonteksAnimasi) {
        guard let tampilan = konteks.tampilan as? UIView else { return }
        
        tampilan.alpha = 0
        tampilan.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            tampilan.alpha = 1
            tampilan.transform = .identity
        }
    }
    
    private func tampilkanAnimasiHilangKartu(konteks: KonteksAnimasi) {
        guard let tampilan = konteks.tampilan as? UIView else { return }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                tampilan.alpha = 0
                tampilan.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            },
            completion: { _ in
                tampilan.removeFromSuperview()
            }
        )
    }
    
    private func tampilkanAnimasiPilihanKartu(konteks: KonteksAnimasi) {
        guard let tampilan = konteks.tampilan as? UIView else { return }
        
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut
        ) {
            tampilan.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                tampilan.transform = .identity
            }
        }
    }
    
    private func tampilkanAnimasiJawabanBenar(konteks: KonteksAnimasi) {
        guard let tampilan = konteks.tampilan as? UIView else { return }
        
        let animasiSkala = CAKeyframeAnimation(keyPath: "transform.scale")
        animasiSkala.values = [1.0, 1.3, 1.0]
        animasiSkala.keyTimes = [0, 0.5, 1.0]
        animasiSkala.duration = 0.6
        animasiSkala.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        tampilan.layer.add(animasiSkala, forKey: "scalePulse")
        
        // Flash hijau
        let warnaAsli = tampilan.backgroundColor
        UIView.animate(withDuration: 0.3, animations: {
            tampilan.backgroundColor = UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 0.4)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                tampilan.backgroundColor = warnaAsli
            }
        }
    }
    
    private func tampilkanAnimasiJawabanSalah(konteks: KonteksAnimasi) {
        guard let tampilan = konteks.tampilan as? UIView else { return }
        
        let animasiGoyang = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animasiGoyang.values = [0, -15, 15, -15, 15, -10, 10, -5, 5, 0]
        animasiGoyang.keyTimes = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
        animasiGoyang.duration = 0.7
        animasiGoyang.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        tampilan.layer.add(animasiGoyang, forKey: "shake")
        
        // Flash merah
        let warnaAsli = tampilan.backgroundColor
        UIView.animate(withDuration: 0.2, animations: {
            tampilan.backgroundColor = UIColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 0.5)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                tampilan.backgroundColor = warnaAsli
            }
        }
    }
    
    private func tampilkanAnimasiTransisiTingkat(konteks: KonteksAnimasi) {
        guard let tampilan = konteks.tampilan as? UIView else { return }
        
        UIView.transition(
            with: tampilan,
            duration: 0.5,
            options: [.transitionFlipFromRight, .curveEaseInOut],
            animations: nil,
            completion: nil
        )
    }
    
    private func tampilkanEfekKonfeti(konteks: KonteksAnimasi) {
        guard let tampilan = konteks.tampilan as? UIView else { return }
        
        let lapisanKonfeti = pembuatEfekPartikel.buatEfekKonfeti(untukTampilan: tampilan)
        simpanAnimasiAktif(lapisan: lapisanKonfeti, kunci: "confetti_\(UUID().uuidString)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            lapisanKonfeti.removeFromSuperlayer()
        }
    }
    
    private func tampilkanEfekKilau(konteks: KonteksAnimasi) {
        guard let tampilan = konteks.tampilan as? UIView,
              let posisi = konteks.posisi else { return }
        
        let lapisanKilau = pembuatEfekPartikel.buatEfekKilau(pada: posisi)
        tampilan.layer.addSublayer(lapisanKilau)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            lapisanKilau.removeFromSuperlayer()
        }
    }
    
    private func tampilkanAnimasiPeringatanWaktu(konteks: KonteksAnimasi) {
        guard let tampilan = konteks.tampilan as? UIView else { return }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.autoreverse, .repeat],
            animations: {
                tampilan.alpha = 0.3
            }
        )
    }
    
    private func simpanAnimasiAktif(lapisan: CALayer, kunci: String) {
        animasiAktif[kunci] = lapisan
    }
}

// MARK: - Pembuat Efek Partikel (Particle Effect Creator)
class PembuatEfekPartikel {
    
    func buatEfekKonfeti(untukTampilan tampilan: UIView) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: tampilan.bounds.midX, y: -50)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: tampilan.bounds.width, height: 1)
        
        let warna: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPurple, .systemOrange
        ]
        
        var sel: [CAEmitterCell] = []
        for warnaItem in warna {
            let selItem = buatSelKonfeti(warna: warnaItem)
            sel.append(selItem)
        }
        
        emitter.emitterCells = sel
        tampilan.layer.addSublayer(emitter)
        
        return emitter
    }
    
    func buatEfekKilau(pada posisi: CGPoint) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = posisi
        emitter.emitterShape = .point
        emitter.emitterSize = CGSize(width: 1, height: 1)
        
        let sel = CAEmitterCell()
        sel.contents = buatGambarBintang().cgImage
        sel.birthRate = 20
        sel.lifetime = 1.0
        sel.velocity = 40
        sel.velocityRange = 30
        sel.emissionRange = .pi * 2
        sel.scale = 0.3
        sel.scaleRange = 0.2
        sel.alphaSpeed = -1.0
        sel.spin = 3
        sel.spinRange = 5
        
        emitter.emitterCells = [sel]
        
        return emitter
    }
    
    func buatEfekSukses(pada posisi: CGPoint) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = posisi
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 50, height: 50)
        emitter.renderMode = .additive
        
        let sel1 = buatSelPartikel(warna: UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1.0))
        let sel2 = buatSelPartikel(warna: UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0))
        
        emitter.emitterCells = [sel1, sel2]
        
        return emitter
    }
    
    func buatEfekError(pada posisi: CGPoint) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = posisi
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 30, height: 30)
        
        let sel = buatSelPartikel(warna: UIColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 1.0))
        sel.velocity = 50
        sel.velocityRange = 30
        
        emitter.emitterCells = [sel]
        
        return emitter
    }
    
    // MARK: - Helper Methods
    
    private func buatSelKonfeti(warna: UIColor) -> CAEmitterCell {
        let sel = CAEmitterCell()
        sel.contents = buatGambarPersegi(warna: warna).cgImage
        sel.birthRate = 3
        sel.lifetime = 10.0
        sel.velocity = 250
        sel.velocityRange = 60
        sel.emissionRange = .pi / 8
        sel.emissionLongitude = .pi
        sel.yAcceleration = 250
        sel.scale = 0.7
        sel.scaleRange = 0.4
        sel.spin = 5
        sel.spinRange = 10
        sel.alphaSpeed = -0.1
        
        return sel
    }
    
    private func buatSelPartikel(warna: UIColor) -> CAEmitterCell {
        let sel = CAEmitterCell()
        sel.contents = buatGambarLingkaran(warna: warna).cgImage
        sel.birthRate = 15
        sel.lifetime = 2.0
        sel.velocity = 120
        sel.velocityRange = 60
        sel.emissionRange = .pi * 2
        sel.scale = 0.5
        sel.scaleRange = 0.3
        sel.alphaSpeed = -0.6
        sel.spin = 3
        sel.spinRange = 6
        
        return sel
    }
    
    private func buatGambarLingkaran(warna: UIColor) -> UIImage {
        let ukuran: CGFloat = 24
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: ukuran, height: ukuran))
        return renderer.image { konteks in
            warna.setFill()
            konteks.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: ukuran, height: ukuran))
        }
    }
    
    private func buatGambarPersegi(warna: UIColor) -> UIImage {
        let ukuran: CGFloat = 12
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: ukuran, height: ukuran))
        return renderer.image { konteks in
            warna.setFill()
            konteks.cgContext.fill(CGRect(x: 0, y: 0, width: ukuran, height: ukuran))
        }
    }
    
    private func buatGambarBintang() -> UIImage {
        let ukuran: CGFloat = 24
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: ukuran, height: ukuran))
        return renderer.image { _ in
            let jalur = buatJalurBintang(dalam: CGRect(x: 0, y: 0, width: ukuran, height: ukuran))
            UIColor.yellow.setFill()
            jalur.fill()
        }
    }
    
    private func buatJalurBintang(dalam kotak: CGRect) -> UIBezierPath {
        let jalur = UIBezierPath()
        let pusat = CGPoint(x: kotak.midX, y: kotak.midY)
        let radiusLuar = kotak.width / 2
        let radiusDalam = radiusLuar * 0.4
        let jumlahTitik = 5
        
        for i in 0..<jumlahTitik * 2 {
            let sudut = CGFloat(i) * .pi / CGFloat(jumlahTitik) - .pi / 2
            let radius = i % 2 == 0 ? radiusLuar : radiusDalam
            let x = pusat.x + radius * cos(sudut)
            let y = pusat.y + radius * sin(sudut)
            
            if i == 0 {
                jalur.move(to: CGPoint(x: x, y: y))
            } else {
                jalur.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        jalur.close()
        return jalur
    }
}

