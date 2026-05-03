#!/usr/bin/env swift
import Foundation
import AppKit
import CoreGraphics

let size: CGFloat = 280
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

ctx.clear(CGRect(x: 0, y: 0, width: size, height: size))

let pad: CGFloat = size * 0.15
let shieldRect = CGRect(x: pad, y: pad, width: size - pad * 2, height: size - pad * 2)
let cx = shieldRect.midX
let topY = shieldRect.maxY
let leftX = shieldRect.minX
let rightX = shieldRect.maxX
let bottomY = shieldRect.minY
let curveY = shieldRect.minY + shieldRect.height * 0.30

let path = CGMutablePath()
path.move(to: CGPoint(x: cx, y: topY))
path.addQuadCurve(
    to: CGPoint(x: leftX, y: curveY + shieldRect.height * 0.45),
    control: CGPoint(x: leftX - 6, y: topY)
)
path.addLine(to: CGPoint(x: leftX, y: curveY))
path.addQuadCurve(
    to: CGPoint(x: cx, y: bottomY),
    control: CGPoint(x: leftX, y: bottomY - 8)
)
path.addQuadCurve(
    to: CGPoint(x: rightX, y: curveY),
    control: CGPoint(x: rightX, y: bottomY - 8)
)
path.addLine(to: CGPoint(x: rightX, y: curveY + shieldRect.height * 0.45))
path.addQuadCurve(
    to: CGPoint(x: cx, y: topY),
    control: CGPoint(x: rightX + 6, y: topY)
)
path.closeSubpath()

ctx.saveGState()
ctx.addPath(path)
ctx.setLineWidth(size * 0.018)
ctx.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 0.85)
ctx.strokePath()
ctx.restoreGState()

let innerInset: CGFloat = size * 0.32
let innerRect = shieldRect.insetBy(dx: (shieldRect.width - innerInset) / 2, dy: (shieldRect.height - innerInset) / 2)
let icx = innerRect.midX
let itopY = innerRect.maxY
let ileftX = innerRect.minX
let irightX = innerRect.maxX
let ibottomY = innerRect.minY
let icurveY = innerRect.minY + innerRect.height * 0.30

let inner = CGMutablePath()
inner.move(to: CGPoint(x: icx, y: itopY))
inner.addQuadCurve(
    to: CGPoint(x: ileftX, y: icurveY + innerRect.height * 0.45),
    control: CGPoint(x: ileftX - 2, y: itopY)
)
inner.addLine(to: CGPoint(x: ileftX, y: icurveY))
inner.addQuadCurve(
    to: CGPoint(x: icx, y: ibottomY),
    control: CGPoint(x: ileftX, y: ibottomY - 3)
)
inner.addQuadCurve(
    to: CGPoint(x: irightX, y: icurveY),
    control: CGPoint(x: irightX, y: ibottomY - 3)
)
inner.addLine(to: CGPoint(x: irightX, y: icurveY + innerRect.height * 0.45))
inner.addQuadCurve(
    to: CGPoint(x: icx, y: itopY),
    control: CGPoint(x: irightX + 2, y: itopY)
)
inner.closeSubpath()

ctx.saveGState()
ctx.addPath(inner)
ctx.setFillColor(red: 1, green: 1, blue: 1, alpha: 0.9)
ctx.fillPath()
ctx.restoreGState()

guard let cgImage = ctx.makeImage() else { exit(2) }
let bitmap = NSBitmapImageRep(cgImage: cgImage)
guard let pngData = bitmap.representation(using: .png, properties: [:]) else { exit(3) }

let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "launch-logo.png"
try pngData.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(outputPath)")
