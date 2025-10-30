//
//  EfekVisualTingkatTinggi.swift
//  FollowRules
//
//  Advanced Visual Effects for Ink Style UI
//

import UIKit
import QuartzCore
import CoreHaptics

// MARK: - Pembuat Efek Visual Tingkat Tinggi
class PembuatEfekVisualTingkatTinggi {
    
    // MARK: - 动态背景水墨效果
    static func buatEfekLatarTintaDinamis(untukView view: UIView) {
        let animationLayer = CALayer()
        animationLayer.frame = view.bounds
        animationLayer.opacity = 0.15
        
        // 创建多个水墨晕染点
        for i in 0..<8 {
            let inkBlot = CALayer()
            let size: CGFloat = CGFloat(100 + i * 30)
            let x = CGFloat.random(in: 0...(view.bounds.width - size))
            let y = CGFloat.random(in: 0...(view.bounds.height - size))
            
            inkBlot.frame = CGRect(x: x, y: y, width: size, height: size)
            inkBlot.backgroundColor = TemaWarnaTinta.warnaTintaHitam.withAlphaComponent(0.08).cgColor
            inkBlot.cornerRadius = size / 2
            
            // 添加模糊效果
            inkBlot.shadowColor = TemaWarnaTinta.warnaTintaHitam.cgColor
            inkBlot.shadowOffset = .zero
            inkBlot.shadowRadius = size / 2
            inkBlot.shadowOpacity = 0.3
            
            animationLayer.addSublayer(inkBlot)
            
            // 动画：缓慢移动和缩放
            let moveAnimation = CABasicAnimation(keyPath: "position")
            moveAnimation.fromValue = NSValue(cgPoint: CGPoint(x: x + size/2, y: y + size/2))
            moveAnimation.toValue = NSValue(cgPoint: CGPoint(
                x: CGFloat.random(in: size/2...(view.bounds.width - size/2)),
                y: CGFloat.random(in: size/2...(view.bounds.height - size/2))
            ))
            moveAnimation.duration = Double.random(in: 8...15)
            moveAnimation.repeatCount = .greatestFiniteMagnitude
            moveAnimation.autoreverses = true
            moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 0.8
            scaleAnimation.toValue = 1.2
            scaleAnimation.duration = Double.random(in: 5...10)
            scaleAnimation.repeatCount = .greatestFiniteMagnitude
            scaleAnimation.autoreverses = true
            
            inkBlot.add(moveAnimation, forKey: "move")
            inkBlot.add(scaleAnimation, forKey: "scale")
        }
        
        view.layer.insertSublayer(animationLayer, at: 0)
    }
    
    // MARK: - 光晕效果
    static func buatEfekGlow(untukView view: UIView, warna: UIColor, radius: CGFloat = 20) {
        view.layer.shadowColor = warna.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = 0.8
        
        // 动画脉冲光晕
        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.fromValue = 0.5
        glowAnimation.toValue = 1.0
        glowAnimation.duration = 1.5
        glowAnimation.repeatCount = .greatestFiniteMagnitude
        glowAnimation.autoreverses = true
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer.add(glowAnimation, forKey: "glow")
    }
    
    // MARK: - 水墨晕染动画
    static func buatAnimasiInkBlot(untukView view: UIView, dariPosisi posisi: CGPoint) {
        let inkBlot = CALayer()
        inkBlot.frame = CGRect(x: posisi.x - 50, y: posisi.y - 50, width: 100, height: 100)
        inkBlot.backgroundColor = TemaWarnaTinta.warnaTintaHitam.cgColor
        inkBlot.cornerRadius = 50
        
        view.layer.addSublayer(inkBlot)
        
        // 缩放和淡出动画
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.5
        scaleAnimation.toValue = 3.0
        scaleAnimation.duration = 0.8
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.6
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = 0.8
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.duration = 0.8
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        
        inkBlot.add(group, forKey: "inkBlot")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            inkBlot.removeFromSuperlayer()
        }
    }
    
    // MARK: - 3D翻转效果
    static func buatAnimasiFlip3D(untukView view: UIView, arah: FlipDirection = .horizontal) {
        var transform3D = CATransform3DIdentity
        transform3D.m34 = -1.0 / 500.0
        
        let rotationAngle: CGFloat = arah == .horizontal ? .pi : .pi
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D: CATransform3DRotate(transform3D, rotationAngle, arah == .horizontal ? 0 : 1, arah == .horizontal ? 1 : 0, 0))
        animation.duration = 0.6
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer.add(animation, forKey: "flip3D")
    }
    
    enum FlipDirection {
        case horizontal, vertical
    }
    
    // MARK: - 粒子爆发效果
    static func buatEfekParticleBurst(dariPosisi posisi: CGPoint, diView view: UIView, warna: UIColor = TemaWarnaTinta.warnaTintaHitam) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = posisi
        emitter.emitterShape = .point
        emitter.emitterSize = CGSize(width: 1, height: 1)
        
        let cell = CAEmitterCell()
        cell.contents = buatGambarPartikelTinta(warna: warna).cgImage
        cell.birthRate = 50
        cell.lifetime = 1.5
        cell.velocity = 80
        cell.velocityRange = 60
        cell.emissionRange = .pi * 2
        cell.scale = 0.3
        cell.scaleRange = 0.2
        cell.alphaSpeed = -0.7
        cell.spin = 3
        cell.spinRange = 5
        
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            emitter.removeFromSuperlayer()
        }
    }
    
    // MARK: - 波纹效果
    static func buatEfekRipple(dariPosisi posisi: CGPoint, diView view: UIView, warna: UIColor = TemaWarnaTinta.warnaTintaHitam) {
        let rippleLayer = CAShapeLayer()
        let radius: CGFloat = 0
        let finalRadius: CGFloat = 200
        
        rippleLayer.path = UIBezierPath(arcCenter: posisi, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        rippleLayer.strokeColor = warna.withAlphaComponent(0.4).cgColor
        rippleLayer.fillColor = UIColor.clear.cgColor
        rippleLayer.lineWidth = 3
        
        view.layer.addSublayer(rippleLayer)
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = UIBezierPath(arcCenter: posisi, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        pathAnimation.toValue = UIBezierPath(arcCenter: posisi, radius: finalRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 0.0
        
        let group = CAAnimationGroup()
        group.animations = [pathAnimation, opacityAnimation]
        group.duration = 1.0
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        
        rippleLayer.add(group, forKey: "ripple")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            rippleLayer.removeFromSuperlayer()
        }
    }
    
    // MARK: - 渐变流动动画
    static func buatAnimasiGradienMengalir(untukLayer layer: CAGradientLayer, warna: [UIColor]) {
        layer.colors = warna.map { $0.cgColor }
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        
        let startPointAnimation = CABasicAnimation(keyPath: "startPoint")
        startPointAnimation.fromValue = CGPoint(x: 0, y: 0)
        startPointAnimation.toValue = CGPoint(x: 1, y: 1)
        startPointAnimation.duration = 3.0
        startPointAnimation.repeatCount = .greatestFiniteMagnitude
        startPointAnimation.autoreverses = true
        
        let endPointAnimation = CABasicAnimation(keyPath: "endPoint")
        endPointAnimation.fromValue = CGPoint(x: 1, y: 1)
        endPointAnimation.toValue = CGPoint(x: 0, y: 0)
        endPointAnimation.duration = 3.0
        endPointAnimation.repeatCount = .greatestFiniteMagnitude
        endPointAnimation.autoreverses = true
        
        layer.add(startPointAnimation, forKey: "startPoint")
        layer.add(endPointAnimation, forKey: "endPoint")
    }
    
    // MARK: - 呼吸灯效果
    static func buatEfekBreathing(untukView view: UIView, durasi: TimeInterval = 2.0) {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.6
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = durasi
        opacityAnimation.repeatCount = .greatestFiniteMagnitude
        opacityAnimation.autoreverses = true
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer.add(opacityAnimation, forKey: "breathing")
    }
    
    // MARK: - 触觉反馈
    static func berikanHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Helper Methods
    private static func buatGambarPartikelTinta(warna: UIColor) -> UIImage {
        let size: CGFloat = 8
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            warna.setFill()
            
            // 创建不规则形状的墨点
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

// MARK: - Extensions untuk增强UI组件
extension KartuModePermainanTinta {
    
    func aktifkanEfekHover() {
        // 添加3D变换
        var transform3D = CATransform3DIdentity
        transform3D.m34 = -1.0 / 500.0
        
        // 添加光晕效果
        PembuatEfekVisualTingkatTinggi.buatEfekGlow(untukView: self, warna: UIColor.white.withAlphaComponent(0.3))
        
        // 轻微浮动动画
        let floatAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        floatAnimation.fromValue = 0
        floatAnimation.toValue = -5
        floatAnimation.duration = 2.0
        floatAnimation.repeatCount = .greatestFiniteMagnitude
        floatAnimation.autoreverses = true
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(floatAnimation, forKey: "float")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .light)
        
        if let touch = touches.first {
            let position = touch.location(in: self)
            let positionInSuperview = convert(position, to: superview)
            PembuatEfekVisualTingkatTinggi.buatEfekRipple(dariPosisi: positionInSuperview, diView: superview ?? self)
        }
        
        // 添加缩放动画
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesEnded(touches, with: event)
    }
}

extension TombolTinta {
    
    func aktifkanEfekPulse() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.05
        scaleAnimation.duration = 1.0
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        scaleAnimation.autoreverses = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(scaleAnimation, forKey: "pulse")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .medium)
        
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.9
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesEnded(touches, with: event)
    }
}

extension TampilanKartuBaru {
    
    func aktifkanEfekInteraktif() {
        // 添加悬停效果
        var transform3D = CATransform3DIdentity
        transform3D.m34 = -1.0 / 800.0
        
        // 添加阴影增强
        layer.shadowColor = TemaWarnaTinta.warnaTintaHitam.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.2
        
        // 添加呼吸效果
        PembuatEfekVisualTingkatTinggi.buatEfekBreathing(untukView: self, durasi: 3.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        PembuatEfekVisualTingkatTinggi.berikanHapticFeedback(style: .light)
        
        // 添加涟漪效果
        if let touch = touches.first {
            let position = touch.location(in: self)
            let positionInSuperview = convert(position, to: superview)
            PembuatEfekVisualTingkatTinggi.buatEfekRipple(dariPosisi: positionInSuperview, diView: superview ?? self)
        }
        
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92).rotated(by: CGFloat.random(in: -0.05...0.05))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.9,
            options: .curveEaseOut
        ) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesEnded(touches, with: event)
    }
}

