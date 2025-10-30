//
//  SistemLatarVisualTingkatTinggi.swift
//  FollowRules
//
//  Advanced Background Visual System
//

import UIKit
import QuartzCore

// MARK: - 高级背景视觉系统
class SistemLatarVisualTingkatTinggi: UIView {
    
    private var lapisanLatarGradien: CAGradientLayer!
    private var lapisanTintaDinamis: CALayer!
    private var lapisanPartikel: CAEmitterLayer!
    private var lapisanTekstur: CALayer!
    private var lapisanSinar: CALayer!
    private var lapisanTintaBerwarna: CALayer!
    private var lapisanGradienBerwarna: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        aturLatarTingkatTinggi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        aturLatarTingkatTinggi()
    }
    
    private func aturLatarTingkatTinggi() {
        // 1. 多层渐变背景（彩色增强版）
        buatLatarGradien()
        
        // 2. 彩色渐变层
        buatLapisanGradienBerwarna()
        
        // 3. 大型动态水墨流动效果（彩色版）
        buatEfekTintaBesarMengalir()
        
        // 4. 彩色水墨晕染
        buatTintaBerwarna()
        
        // 5. 粒子系统（彩色版）
        buatSistemPartikel()
        
        // 6. 彩色光效层
        buatLapisanSinar()
        
        // 7. 纹理叠加
        buatLapisanTekstur()
    }
    
    // MARK: - 多层渐变背景（增强彩色版）
    private func buatLatarGradien() {
        lapisanLatarGradien = CAGradientLayer()
        lapisanLatarGradien.frame = bounds
        // 使用更丰富的色彩渐变
        lapisanLatarGradien.colors = [
            TemaWarnaTinta.warnaLatarUtama.cgColor,
            UIColor(red: 0.98, green: 0.92, blue: 0.85, alpha: 1.0).cgColor, // 淡米黄
            UIColor(red: 0.95, green: 0.88, blue: 0.80, alpha: 1.0).cgColor, // 暖米色
            UIColor(red: 0.92, green: 0.85, blue: 0.75, alpha: 1.0).cgColor, // 米黄色
            UIColor(red: 0.95, green: 0.88, blue: 0.80, alpha: 1.0).cgColor, // 暖米色
            UIColor(red: 0.98, green: 0.92, blue: 0.85, alpha: 1.0).cgColor, // 淡米黄
            TemaWarnaTinta.warnaLatarUtama.cgColor
        ]
        lapisanLatarGradien.locations = [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0]
        lapisanLatarGradien.startPoint = CGPoint(x: 0, y: 0)
        lapisanLatarGradien.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(lapisanLatarGradien, at: 0)
        
        // 渐变动画（更快速）
        let animasiStartPoint = CABasicAnimation(keyPath: "startPoint")
        animasiStartPoint.fromValue = CGPoint(x: 0, y: 0)
        animasiStartPoint.toValue = CGPoint(x: 1, y: 1)
        animasiStartPoint.duration = 6.0
        animasiStartPoint.repeatCount = .greatestFiniteMagnitude
        animasiStartPoint.autoreverses = true
        animasiStartPoint.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let animasiEndPoint = CABasicAnimation(keyPath: "endPoint")
        animasiEndPoint.fromValue = CGPoint(x: 1, y: 1)
        animasiEndPoint.toValue = CGPoint(x: 0, y: 0)
        animasiEndPoint.duration = 6.0
        animasiEndPoint.repeatCount = .greatestFiniteMagnitude
        animasiEndPoint.autoreverses = true
        animasiEndPoint.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        lapisanLatarGradien.add(animasiStartPoint, forKey: "startPoint")
        lapisanLatarGradien.add(animasiEndPoint, forKey: "endPoint")
    }
    
    // MARK: - 彩色渐变层
    private func buatLapisanGradienBerwarna() {
        lapisanGradienBerwarna = CAGradientLayer()
        lapisanGradienBerwarna.frame = bounds
        lapisanGradienBerwarna.opacity = 0.3
        
        // 使用强烈的彩色渐变
        lapisanGradienBerwarna.colors = [
            TemaWarnaTinta.warnaMerahTua.withAlphaComponent(0.15).cgColor,
            TemaWarnaTinta.warnaBiruTua.withAlphaComponent(0.12).cgColor,
            TemaWarnaTinta.warnaHijauTua.withAlphaComponent(0.15).cgColor,
            TemaWarnaTinta.warnaUnguTua.withAlphaComponent(0.12).cgColor,
            TemaWarnaTinta.warnaMerahTua.withAlphaComponent(0.15).cgColor
        ]
        lapisanGradienBerwarna.locations = [0.0, 0.25, 0.5, 0.75, 1.0]
        lapisanGradienBerwarna.startPoint = CGPoint(x: 0, y: 0)
        lapisanGradienBerwarna.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(lapisanGradienBerwarna, at: 1)
        
        // 色彩流动动画
        let animasiStartPoint = CABasicAnimation(keyPath: "startPoint")
        animasiStartPoint.fromValue = CGPoint(x: 0, y: 0)
        animasiStartPoint.toValue = CGPoint(x: 1, y: 1)
        animasiStartPoint.duration = 10.0
        animasiStartPoint.repeatCount = .greatestFiniteMagnitude
        animasiStartPoint.autoreverses = true
        
        let animasiEndPoint = CABasicAnimation(keyPath: "endPoint")
        animasiEndPoint.fromValue = CGPoint(x: 1, y: 1)
        animasiEndPoint.toValue = CGPoint(x: 0, y: 0)
        animasiEndPoint.duration = 10.0
        animasiEndPoint.repeatCount = .greatestFiniteMagnitude
        animasiEndPoint.autoreverses = true
        
        // 颜色动画
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = lapisanGradienBerwarna.colors
        colorAnimation.toValue = [
            TemaWarnaTinta.warnaBiruTua.withAlphaComponent(0.15).cgColor,
            TemaWarnaTinta.warnaHijauTua.withAlphaComponent(0.12).cgColor,
            TemaWarnaTinta.warnaUnguTua.withAlphaComponent(0.15).cgColor,
            TemaWarnaTinta.warnaMerahTua.withAlphaComponent(0.12).cgColor,
            TemaWarnaTinta.warnaBiruTua.withAlphaComponent(0.15).cgColor
        ]
        colorAnimation.duration = 8.0
        colorAnimation.repeatCount = .greatestFiniteMagnitude
        colorAnimation.autoreverses = true
        
        lapisanGradienBerwarna.add(animasiStartPoint, forKey: "startPoint")
        lapisanGradienBerwarna.add(animasiEndPoint, forKey: "endPoint")
        lapisanGradienBerwarna.add(colorAnimation, forKey: "colors")
    }
    
    
    // MARK: - 大型动态水墨流动效果（彩色增强版）
    private func buatEfekTintaBesarMengalir() {
        lapisanTintaDinamis = CALayer()
        lapisanTintaDinamis.frame = bounds
        lapisanTintaDinamis.opacity = 0.35
        
        // 创建多个大型彩色水墨晕染
        let jumlahBlot = 15
        for i in 0..<jumlahBlot {
            let inkBlot = buatLapisanTintaBesarBerwarna(indeks: i)
            lapisanTintaDinamis.addSublayer(inkBlot)
            
            // 复杂路径动画
            buatAnimasiJalurKompleks(untukLayer: inkBlot)
        }
        
        layer.insertSublayer(lapisanTintaDinamis, at: 2)
    }
    
    private func buatLapisanTintaBesarBerwarna(indeks: Int) -> CALayer {
        let size: CGFloat = CGFloat(180 + indeks * 35)
        let inkBlot = CALayer()
        
        // 根据索引选择不同的颜色
        let warnaArray: [UIColor] = [
            TemaWarnaTinta.warnaMerahTua,
            TemaWarnaTinta.warnaBiruTua,
            TemaWarnaTinta.warnaHijauTua,
            TemaWarnaTinta.warnaUnguTua,
            TemaWarnaTinta.warnaKuningTua,
            TemaWarnaTinta.warnaOranyeTua,
            TemaWarnaTinta.warnaTintaHitam
        ]
        let warnaPilihan = warnaArray[indeks % warnaArray.count]
        
        // 创建不规则形状的墨点
        let path = UIBezierPath()
        let center = CGPoint(x: size/2, y: size/2)
        let radius = size / 2
        
        // 创建花瓣形状
        for i in 0..<10 {
            let angle = CGFloat(i) * CGFloat.pi * 2 / 10
            let r = radius * (0.6 + CGFloat.random(in: 0...0.4))
            let x = center.x + r * cos(angle)
            let y = center.y + r * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        
        // 渐变填充（彩色）
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        gradientLayer.colors = [
            warnaPilihan.withAlphaComponent(0.35).cgColor,
            warnaPilihan.withAlphaComponent(0.20).cgColor,
            warnaPilihan.withAlphaComponent(0.08).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.4, 0.7, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        gradientLayer.mask = maskLayer
        
        inkBlot.addSublayer(gradientLayer)
        inkBlot.frame = CGRect(
            x: CGFloat.random(in: -size/2...(bounds.width - size/2)),
            y: CGFloat.random(in: -size/2...(bounds.height - size/2)),
            width: size,
            height: size
        )
        
        // 添加彩色模糊阴影
        inkBlot.shadowColor = warnaPilihan.cgColor
        inkBlot.shadowOffset = .zero
        inkBlot.shadowRadius = size / 2.5
        inkBlot.shadowOpacity = 0.6
        
        return inkBlot
    }
    
    // MARK: - 彩色水墨晕染层
    private func buatTintaBerwarna() {
        lapisanTintaBerwarna = CALayer()
        lapisanTintaBerwarna.frame = bounds
        lapisanTintaBerwarna.opacity = 0.4
        
        let warnaArray: [(color: UIColor, count: Int)] = [
            (TemaWarnaTinta.warnaMerahTua, 4),
            (TemaWarnaTinta.warnaBiruTua, 4),
            (TemaWarnaTinta.warnaHijauTua, 3),
            (TemaWarnaTinta.warnaUnguTua, 3)
        ]
        
        var totalCount = 0
        for (warna, count) in warnaArray {
            for _ in 0..<count {
                let blot = buatTintaBerwarnaKecil(warna: warna, indeks: totalCount)
                lapisanTintaBerwarna.addSublayer(blot)
                totalCount += 1
            }
        }
        
        layer.insertSublayer(lapisanTintaBerwarna, at: 3)
    }
    
    private func buatTintaBerwarnaKecil(warna: UIColor, indeks: Int) -> CALayer {
        let size: CGFloat = CGFloat(80 + indeks * 15)
        let blot = CALayer()
        
        let path = UIBezierPath()
        let center = CGPoint(x: size/2, y: size/2)
        let radius = size / 2
        
        for i in 0..<6 {
            let angle = CGFloat(i) * CGFloat.pi * 2 / 6
            let r = radius * (0.7 + CGFloat.random(in: 0...0.3))
            let x = center.x + r * cos(angle)
            let y = center.y + r * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        gradientLayer.colors = [
            warna.withAlphaComponent(0.4).cgColor,
            warna.withAlphaComponent(0.2).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.6, 1.0]
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        gradientLayer.mask = maskLayer
        
        blot.addSublayer(gradientLayer)
        blot.frame = CGRect(
            x: CGFloat.random(in: 0...(bounds.width - size)),
            y: CGFloat.random(in: 0...(bounds.height - size)),
            width: size,
            height: size
        )
        
        // 动画：缓慢移动和旋转
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.fromValue = NSValue(cgPoint: CGPoint(x: blot.position.x, y: blot.position.y))
        moveAnimation.toValue = NSValue(cgPoint: CGPoint(
            x: CGFloat.random(in: size/2...(bounds.width - size/2)),
            y: CGFloat.random(in: size/2...(bounds.height - size/2))
        ))
        moveAnimation.duration = Double.random(in: 12...20)
        moveAnimation.repeatCount = .greatestFiniteMagnitude
        moveAnimation.autoreverses = true
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = CGFloat.pi * 2
        rotateAnimation.duration = Double.random(in: 15...25)
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        
        blot.add(moveAnimation, forKey: "move")
        blot.add(rotateAnimation, forKey: "rotate")
        
        return blot
    }
    
    private func buatAnimasiJalurKompleks(untukLayer layer: CALayer) {
        // 创建贝塞尔曲线路径
        let path = UIBezierPath()
        let startPoint = CGPoint(x: layer.position.x, y: layer.position.y)
        path.move(to: startPoint)
        
        // 创建波浪形路径
        for i in 1...5 {
            let controlPoint1 = CGPoint(
                x: startPoint.x + CGFloat(i * 100) + CGFloat.random(in: -50...50),
                y: startPoint.y + CGFloat.random(in: -100...100)
            )
            let controlPoint2 = CGPoint(
                x: startPoint.x + CGFloat(i * 100) + CGFloat.random(in: -50...50),
                y: startPoint.y + CGFloat.random(in: -100...100)
            )
            let endPoint = CGPoint(
                x: startPoint.x + CGFloat(i * 100),
                y: startPoint.y + CGFloat.random(in: -50...50)
            )
            path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = Double.random(in: 15...25)
        animation.repeatCount = .greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.7
        scaleAnimation.toValue = 1.3
        scaleAnimation.duration = Double.random(in: 8...12)
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        scaleAnimation.autoreverses = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0
            rotateAnimation.toValue = CGFloat.pi * 2
            rotateAnimation.duration = Double.random(in: 20...30)
            rotateAnimation.repeatCount = .greatestFiniteMagnitude
            rotateAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        layer.add(animation, forKey: "position")
        layer.add(scaleAnimation, forKey: "scale")
        layer.add(rotateAnimation, forKey: "rotation")
    }
    
    // MARK: - 粒子系统（彩色增强版）
    private func buatSistemPartikel() {
        lapisanPartikel = CAEmitterLayer()
        lapisanPartikel.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        lapisanPartikel.emitterShape = .rectangle
        lapisanPartikel.emitterSize = CGSize(width: bounds.width, height: bounds.height)
        lapisanPartikel.emitterMode = .volume
        
        var cells: [CAEmitterCell] = []
        
        // 创建多种彩色粒子
        let warnaPartikel: [UIColor] = [
            TemaWarnaTinta.warnaMerahTua,
            TemaWarnaTinta.warnaBiruTua,
            TemaWarnaTinta.warnaHijauTua,
            TemaWarnaTinta.warnaUnguTua,
            TemaWarnaTinta.warnaKuningTua,
            TemaWarnaTinta.warnaOranyeTua
        ]
        
        for i in 0..<warnaPartikel.count {
            let cell = CAEmitterCell()
            cell.contents = buatGambarPartikelTinta(warna: warnaPartikel[i].withAlphaComponent(0.25)).cgImage
            cell.birthRate = Float(0.8 + Double(i) * 0.4)
            cell.lifetime = Float(12.0 + Double(i) * 6.0)
            cell.velocity = CGFloat(25 + i * 12)
            cell.velocityRange = CGFloat(15 + i * 8)
            cell.emissionRange = CGFloat.pi * 2
            cell.scale = 0.4 + CGFloat(i) * 0.15
            cell.scaleRange = 0.3
            cell.alphaSpeed = -0.04
            cell.spin = CGFloat(1.5 + Double(i))
            cell.spinRange = CGFloat(3.0 + Double(i))
            cell.yAcceleration = CGFloat(-8 - i * 3)
            
            cells.append(cell)
        }
        
        lapisanPartikel.emitterCells = cells
        layer.insertSublayer(lapisanPartikel, at: 4)
    }
    
    // MARK: - 彩色光效层
    private func buatLapisanSinar() {
        lapisanSinar = CALayer()
        lapisanSinar.frame = bounds
        
        // 创建多个彩色光斑
        let jumlahSinar = 8
        let warnaSinar: [UIColor] = [
            TemaWarnaTinta.warnaMerahTua,
            TemaWarnaTinta.warnaBiruTua,
            TemaWarnaTinta.warnaHijauTua,
            TemaWarnaTinta.warnaUnguTua,
            TemaWarnaTinta.warnaKuningTua,
            TemaWarnaTinta.warnaOranyeTua,
            TemaWarnaTinta.warnaAksenMerah,
            TemaWarnaTinta.warnaAksenBiru
        ]
        
        for i in 0..<jumlahSinar {
            let sunbeam = CALayer()
            let size: CGFloat = CGFloat(220 + i * 45)
            let angle = CGFloat(i) * CGFloat.pi * 2 / CGFloat(jumlahSinar)
            let distance: CGFloat = bounds.width * 0.35
            let centerX = bounds.midX + distance * cos(angle)
            let centerY = bounds.midY + distance * sin(angle)
            
            sunbeam.frame = CGRect(x: centerX - size/2, y: centerY - size/2, width: size, height: size)
            
            // 径向渐变（彩色）
            let gradient = CAGradientLayer()
            gradient.frame = sunbeam.bounds
            let warnaSinarPilihan = warnaSinar[i % warnaSinar.count]
            gradient.colors = [
                warnaSinarPilihan.withAlphaComponent(0.25).cgColor,
                warnaSinarPilihan.withAlphaComponent(0.15).cgColor,
                warnaSinarPilihan.withAlphaComponent(0.08).cgColor,
                UIColor.clear.cgColor
            ]
            gradient.locations = [0.0, 0.3, 0.6, 1.0]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            
            // 圆形遮罩
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(arcCenter: CGPoint(x: size/2, y: size/2), radius: size/2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
            gradient.mask = maskLayer
            
            sunbeam.addSublayer(gradient)
            
            // 旋转动画
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0
            rotateAnimation.toValue = CGFloat.pi * 2
            rotateAnimation.duration = Double(25 + i * 4)
            rotateAnimation.repeatCount = .greatestFiniteMagnitude
            rotateAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
            
            // 呼吸动画
            let breathingAnimation = CABasicAnimation(keyPath: "opacity")
            breathingAnimation.fromValue = 0.5
            breathingAnimation.toValue = 1.0
            breathingAnimation.duration = Double(3.0 + Double(i) * 0.5)
            breathingAnimation.repeatCount = .greatestFiniteMagnitude
            breathingAnimation.autoreverses = true
            
            sunbeam.add(rotateAnimation, forKey: "rotation")
            sunbeam.add(breathingAnimation, forKey: "breathing")
            lapisanSinar.addSublayer(sunbeam)
        }
        
        layer.insertSublayer(lapisanSinar, at: 5)
    }
    
    // MARK: - 纹理叠加
    private func buatLapisanTekstur() {
        lapisanTekstur = CALayer()
        lapisanTekstur.frame = bounds
        lapisanTekstur.opacity = 0.15
        
        // 创建宣纸纹理
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(TemaWarnaTinta.warnaTintaHitam.withAlphaComponent(0.1).cgColor)
        context.setLineWidth(1.0)
        
        // 绘制纹理线条
        let spacing: CGFloat = 3
        for i in stride(from: 0, to: bounds.height, by: spacing) {
            context.move(to: CGPoint(x: 0, y: i))
            context.addLine(to: CGPoint(x: bounds.width, y: i))
            context.strokePath()
        }
        
        // 添加随机噪点
        for _ in 0..<500 {
            let x = CGFloat.random(in: 0...bounds.width)
            let y = CGFloat.random(in: 0...bounds.height)
            let size = CGFloat.random(in: 0.5...2)
            context.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
        }
        
        if let textureImage = UIGraphicsGetImageFromCurrentImageContext() {
            lapisanTekstur.contents = textureImage.cgImage
            layer.insertSublayer(lapisanTekstur, at: 4)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lapisanLatarGradien?.frame = bounds
        lapisanGradienBerwarna?.frame = bounds
        lapisanTintaDinamis?.frame = bounds
        lapisanTintaBerwarna?.frame = bounds
        lapisanPartikel?.emitterSize = CGSize(width: bounds.width, height: bounds.height)
        lapisanPartikel?.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        lapisanTekstur?.frame = bounds
        lapisanSinar?.frame = bounds
        
        // 更新光斑位置
        if let lapisanSinar = lapisanSinar {
            let jumlahSinar = lapisanSinar.sublayers?.count ?? 8
            for (i, sunbeam) in (lapisanSinar.sublayers ?? []).enumerated() {
                let size = sunbeam.frame.width
                let angle = CGFloat(i) * CGFloat.pi * 2 / CGFloat(jumlahSinar)
                let distance: CGFloat = bounds.width * 0.35
                let centerX = bounds.midX + distance * cos(angle)
                let centerY = bounds.midY + distance * sin(angle)
                sunbeam.frame = CGRect(x: centerX - size/2, y: centerY - size/2, width: size, height: size)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func buatGambarPartikelTinta(warna: UIColor) -> UIImage {
        let size: CGFloat = 12
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            warna.setFill()
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: size/2, y: 0))
            path.addCurve(to: CGPoint(x: size, y: size/2), controlPoint1: CGPoint(x: size*0.7, y: size*0.2), controlPoint2: CGPoint(x: size*0.9, y: size*0.3))
            path.addCurve(to: CGPoint(x: size/2, y: size), controlPoint1: CGPoint(x: size*0.9, y: size*0.7), controlPoint2: CGPoint(x: size*0.7, y: size*0.8))
            path.addCurve(to: CGPoint(x: 0, y: size/2), controlPoint1: CGPoint(x: size*0.3, y: size*0.8), controlPoint2: CGPoint(x: size*0.1, y: size*0.7))
            path.addCurve(to: CGPoint(x: size/2, y: 0), controlPoint1: CGPoint(x: size*0.1, y: size*0.3), controlPoint2: CGPoint(x: size*0.3, y: size*0.2))
            path.close()
            
            path.fill()
        }
    }
}

// MARK: - 工具方法：快速应用到视图
extension UIView {
    func tambahkanLatarTingkatTinggi() {
        let latarTingkatTinggi = SistemLatarVisualTingkatTinggi(frame: bounds)
        latarTingkatTinggi.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(latarTingkatTinggi, at: 0)
    }
}

