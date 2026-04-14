import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let s = CGFloat(size)

let ctx = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: size * 4,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!

// ── Dark stone background ──

ctx.setFillColor(CGColor(srgbRed: 0.08, green: 0.07, blue: 0.065, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))

srand48(42)

for _ in 0..<800 {
    let x = CGFloat(drand48()) * s
    let y = CGFloat(drand48()) * s
    let r = 40 + CGFloat(drand48()) * 100
    let bright = 0.05 + CGFloat(drand48()) * 0.07
    ctx.setFillColor(CGColor(srgbRed: bright, green: bright * 0.95, blue: bright * 0.90, alpha: 0.2))
    ctx.fillEllipse(in: CGRect(x: x - r/2, y: y - r/2, width: r, height: r))
}

for _ in 0..<50000 {
    let x = CGFloat(drand48()) * s
    let y = CGFloat(drand48()) * s
    let bright = 0.04 + CGFloat(drand48()) * 0.10
    let sz = 1.0 + CGFloat(drand48()) * 3.0
    ctx.setFillColor(CGColor(srgbRed: bright, green: bright * 0.96, blue: bright * 0.90, alpha: 0.3))
    ctx.fillEllipse(in: CGRect(x: x, y: y, width: sz, height: sz))
}

for _ in 0..<12000 {
    let x = CGFloat(drand48()) * s
    let y = CGFloat(drand48()) * s
    let bright = 0.15 + CGFloat(drand48()) * 0.10
    ctx.setFillColor(CGColor(srgbRed: bright, green: bright * 0.95, blue: bright * 0.88, alpha: 0.12))
    ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
}

ctx.setLineCap(.round)
for _ in 0..<40 {
    let x = CGFloat(drand48()) * s
    let y = CGFloat(drand48()) * s
    let len = 20 + CGFloat(drand48()) * 80
    let angle = CGFloat(drand48()) * .pi * 2
    let b = drand48() < 0.6 ? 0.03 : 0.14
    ctx.setStrokeColor(CGColor(srgbRed: b, green: b * 0.96, blue: b * 0.90, alpha: 0.2))
    ctx.setLineWidth(0.5 + CGFloat(drand48()) * 0.8)
    ctx.move(to: CGPoint(x: x, y: y))
    ctx.addLine(to: CGPoint(x: x + cos(angle) * len, y: y + sin(angle) * len))
    ctx.strokePath()
}

for i in 0..<100 {
    let inset = CGFloat(i) * 2
    let alpha = 0.018 * (1.0 - CGFloat(i) / 100.0)
    ctx.setStrokeColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: alpha))
    ctx.setLineWidth(4)
    ctx.stroke(CGRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2))
}

// ── Render ᚠ ──

let rune = "ᚠ"
let fontSize: CGFloat = 900

let font = CTFontCreateWithName("Helvetica" as CFString, fontSize, nil)

func makeRuneLine(color: CGColor) -> CTLine {
    let str = CFAttributedStringCreateMutable(nil, 0)!
    CFAttributedStringReplaceString(str, CFRange(location: 0, length: 0), rune as CFString)
    let range = CFRange(location: 0, length: CFAttributedStringGetLength(str))
    CFAttributedStringSetAttribute(str, range, kCTFontAttributeName, font)
    CFAttributedStringSetAttribute(str, range, kCTForegroundColorAttributeName, color)
    return CTLineCreateWithAttributedString(str)
}

// Measure using image bounds (actual pixel extent of glyphs)
let measureLine = makeRuneLine(color: CGColor(gray: 1, alpha: 1))
ctx.textPosition = .zero
let bounds = CTLineGetImageBounds(measureLine, ctx)
print("Image bounds: \(bounds)")

// Shift right so the stave (left edge of glyph) sits near center
let drawX = (s - bounds.width) / 2 - bounds.origin.x + bounds.width * 0.3
let drawY = (s - bounds.height) / 2 - bounds.origin.y
print("Draw position: \(drawX), \(drawY)")

// Shadow bevel
let shadowLine = makeRuneLine(color: CGColor(srgbRed: 0.01, green: 0.01, blue: 0.01, alpha: 0.85))
ctx.textPosition = CGPoint(x: drawX - 3, y: drawY + 3)
CTLineDraw(shadowLine, ctx)

// Light bevel
let lightLine = makeRuneLine(color: CGColor(srgbRed: 0.55, green: 0.55, blue: 0.58, alpha: 0.5))
ctx.textPosition = CGPoint(x: drawX + 3, y: drawY - 3)
CTLineDraw(lightLine, ctx)

// Main rune — silver
let mainLine = makeRuneLine(color: CGColor(srgbRed: 0.75, green: 0.75, blue: 0.78, alpha: 1))
ctx.textPosition = CGPoint(x: drawX, y: drawY)
CTLineDraw(mainLine, ctx)

// ── Save ──

let image = ctx.makeImage()!
let url = URL(fileURLWithPath: "Glyph/Assets.xcassets/AppIcon.appiconset/icon.png")
let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, image, nil)
CGImageDestinationFinalize(dest)
print("Icon saved.")
