#!/usr/bin/env swift
import Foundation
import AppKit
import CoreGraphics

let size: CGFloat = 1024
let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil,
    width: Int(size),
    height: Int(size),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: cs,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else { exit(1) }

let topColor = CGColor(red: 0.07, green: 0.13, blue: 0.22, alpha: 1)
let bottomColor = CGColor(red: 0.02, green: 0.05, blue: 0.10, alpha: 1)
let gradient = CGGradient(
    colorsSpace: cs,
    colors: [topColor, bottomColor] as CFArray,
    locations: [0, 1]
)!
ctx.drawLinearGradient(
    gradient,
    start: CGPoint(x: 0, y: size),
    end: CGPoint(x: 0, y: 0),
    options: []
)

let glowCenter = CGPoint(x: size / 2, y: size * 0.62)
let glow = CGGradient(
    colorsSpace: cs,
    colors: [
        CGColor(red: 0.30, green: 0.55, blue: 1.0, alpha: 0.35),
        CGColor(red: 0.07, green: 0.13, blue: 0.22, alpha: 0)
    ] as CFArray,
    locations: [0, 1]
)!
ctx.drawRadialGradient(
    glow,
    startCenter: glowCenter, startRadius: 0,
    endCenter: glowCenter, endRadius: size * 0.55,
    options: []
)

let shieldRect = CGRect(x: size * 0.22, y: size * 0.18, width: size * 0.56, height: size * 0.66)
let shieldPath = CGMutablePath()
let cx = shieldRect.midX
let topY = shieldRect.maxY
let leftX = shieldRect.minX
let rightX = shieldRect.maxX
let bottomY = shieldRect.minY
let curveY = shieldRect.minY + shieldRect.height * 0.30

shieldPath.move(to: CGPoint(x: cx, y: topY))
shieldPath.addQuadCurve(
    to: CGPoint(x: leftX, y: curveY + shieldRect.height * 0.45),
    control: CGPoint(x: leftX - 20, y: topY)
)
shieldPath.addLine(to: CGPoint(x: leftX, y: curveY))
shieldPath.addQuadCurve(
    to: CGPoint(x: cx, y: bottomY),
    control: CGPoint(x: leftX, y: bottomY - 30)
)
shieldPath.addQuadCurve(
    to: CGPoint(x: rightX, y: curveY),
    control: CGPoint(x: rightX, y: bottomY - 30)
)
shieldPath.addLine(to: CGPoint(x: rightX, y: curveY + shieldRect.height * 0.45))
shieldPath.addQuadCurve(
    to: CGPoint(x: cx, y: topY),
    control: CGPoint(x: rightX + 20, y: topY)
)
shieldPath.closeSubpath()

ctx.saveGState()
ctx.addPath(shieldPath)
ctx.setShadow(
    offset: CGSize(width: 0, height: -16),
    blur: 40,
    color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.4)
)
ctx.setFillColor(red: 1, green: 1, blue: 1, alpha: 0.97)
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
let highlight = CGGradient(
    colorsSpace: cs,
    colors: [
        CGColor(red: 1, green: 1, blue: 1, alpha: 0.0),
        CGColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 0.18)
    ] as CFArray,
    locations: [0, 1]
)!
ctx.addPath(shieldPath)
ctx.clip()
ctx.drawLinearGradient(
    highlight,
    start: CGPoint(x: 0, y: shieldRect.maxY),
    end: CGPoint(x: 0, y: shieldRect.minY),
    options: []
)
ctx.restoreGState()

let letter = "H"
let font = NSFont.systemFont(ofSize: size * 0.36, weight: .heavy)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor(red: 0.05, green: 0.10, blue: 0.18, alpha: 1)
]
let attrStr = NSAttributedString(string: letter, attributes: attrs)
let textSize = attrStr.size()
let textRect = CGRect(
    x: shieldRect.midX - textSize.width / 2,
    y: shieldRect.midY - textSize.height / 2 + size * 0.02,
    width: textSize.width,
    height: textSize.height
)

let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = nsCtx
attrStr.draw(in: textRect)
NSGraphicsContext.restoreGraphicsState()

guard let cgImage = ctx.makeImage() else { exit(2) }
let bitmap = NSBitmapImageRep(cgImage: cgImage)
guard let pngData = bitmap.representation(using: .png, properties: [:]) else { exit(3) }

let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "icon.png"
try pngData.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(outputPath)")
