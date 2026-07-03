// Generates Undiscord.iconset (all sizes) by drawing the icon with AppKit.
// Usage: swift make-icon.swift [outputDir]
// Then: iconutil -c icns <outputDir>/Undiscord.iconset -o ../Sources/UndiscordApp/Undiscord.icns
import AppKit

func drawTrash(_ cg: CGContext, in r: CGRect) {
    let w = r.width
    let cx = r.midX
    let Wc = w * 0.46
    let Hc = w * 0.52
    let topY = r.midY + Hc * 0.42          // top of lid (CG y-up)
    let bottomY = r.midY - Hc * 0.5

    cg.setFillColor(NSColor.white.cgColor)

    // Lid bar
    let lidW = Wc, lidH = w * 0.072
    let lidRect = CGRect(x: cx - lidW / 2, y: topY, width: lidW, height: lidH)
    cg.addPath(CGPath(roundedRect: lidRect, cornerWidth: lidH * 0.45, cornerHeight: lidH * 0.45, transform: nil))
    cg.fillPath()

    // Handle notch on top of lid
    let hW = Wc * 0.36, hH = w * 0.05
    let hRect = CGRect(x: cx - hW / 2, y: topY + lidH - hH * 0.25, width: hW, height: hH)
    cg.addPath(CGPath(roundedRect: hRect, cornerWidth: hH * 0.5, cornerHeight: hH * 0.5, transform: nil))
    cg.fillPath()

    // Body (rounded trapezoid), tapering inward toward the bottom
    let bodyTop = topY - w * 0.015
    let topHalf = Wc * 0.43, botHalf = Wc * 0.33
    let rc = w * 0.035
    let p = CGMutablePath()
    p.move(to: CGPoint(x: cx - topHalf, y: bodyTop))
    p.addLine(to: CGPoint(x: cx + topHalf, y: bodyTop))
    p.addArc(tangent1End: CGPoint(x: cx + botHalf, y: bottomY),
             tangent2End: CGPoint(x: cx + botHalf - rc, y: bottomY), radius: rc)
    p.addArc(tangent1End: CGPoint(x: cx - botHalf, y: bottomY),
             tangent2End: CGPoint(x: cx - botHalf, y: bottomY + rc), radius: rc)
    p.closeSubpath()
    cg.addPath(p)
    cg.fillPath()

    // Engraved slots (blurple) inside the body
    cg.setFillColor(NSColor(red: 0.30, green: 0.34, blue: 0.80, alpha: 1).cgColor)
    let slotH = (bodyTop - bottomY) * 0.56
    let slotW = w * 0.030
    let slotY = bottomY + (bodyTop - bottomY) * 0.22
    for dx in [-Wc * 0.17, 0, Wc * 0.17] {
        let sr = CGRect(x: cx + dx - slotW / 2, y: slotY, width: slotW, height: slotH)
        cg.addPath(CGPath(roundedRect: sr, cornerWidth: slotW / 2, cornerHeight: slotW / 2, transform: nil))
        cg.fillPath()
    }
}

func render(_ size: CGFloat) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
                              bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                              colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = ctx
    let cg = ctx.cgContext

    cg.clear(CGRect(x: 0, y: 0, width: size, height: size))

    let s = size
    let inset = s * 0.095
    let rect = CGRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset)
    let radius = rect.width * 0.2237
    let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)

    // Drop shadow
    cg.saveGState()
    cg.setShadow(offset: CGSize(width: 0, height: -s * 0.010), blur: s * 0.03,
                 color: NSColor(white: 0, alpha: 0.35).cgColor)
    cg.addPath(path)
    cg.setFillColor(NSColor(red: 0.345, green: 0.396, blue: 0.949, alpha: 1).cgColor)
    cg.fillPath()
    cg.restoreGState()

    // Blurple gradient (light top -> dark bottom), clipped to the squircle
    cg.saveGState()
    cg.addPath(path)
    cg.clip()
    let colors = [NSColor(red: 0.408, green: 0.451, blue: 0.980, alpha: 1).cgColor,
                  NSColor(red: 0.275, green: 0.318, blue: 0.769, alpha: 1).cgColor] as CFArray
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
    cg.drawLinearGradient(grad, start: CGPoint(x: rect.midX, y: rect.maxY),
                          end: CGPoint(x: rect.midX, y: rect.minY), options: [])
    // soft top gloss (no hard seam): white fading to transparent over the top half
    let gloss = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                           colors: [NSColor(white: 1, alpha: 0.10).cgColor,
                                    NSColor(white: 1, alpha: 0).cgColor] as CFArray,
                           locations: [0, 1])!
    cg.drawLinearGradient(gloss, start: CGPoint(x: rect.midX, y: rect.maxY),
                          end: CGPoint(x: rect.midX, y: rect.midY), options: [])
    cg.restoreGState()

    drawTrash(cg, in: rect)

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let iconset = (outDir as NSString).appendingPathComponent("Undiscord.iconset")
try? FileManager.default.createDirectory(atPath: iconset, withIntermediateDirectories: true)

let specs: [(String, CGFloat)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024),
]
for (name, size) in specs {
    let data = render(size)
    let file = (iconset as NSString).appendingPathComponent("\(name).png")
    try! data.write(to: URL(fileURLWithPath: file))
}
// preview for eyeballing
try! render(1024).write(to: URL(fileURLWithPath: (outDir as NSString).appendingPathComponent("preview.png")))
print("Wrote \(iconset) and preview.png")
