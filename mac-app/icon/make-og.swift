// Generates a 1200x630 OpenGraph banner for the landing page.
// Usage: swift make-og.swift <iconPng> <outPng>
import AppKit

let args = CommandLine.arguments
let iconPath = args.count > 1 ? args[1] : "docs/icon.png"
let outPath = args.count > 2 ? args[2] : "docs/og.png"

let W: CGFloat = 1200, H: CGFloat = 630
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(W), pixelsHigh: Int(H),
                          bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                          colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
let ctx = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = ctx
let cg = ctx.cgContext

// Background: near-black with a blue undertone
cg.setFillColor(NSColor(red: 0.039, green: 0.047, blue: 0.070, alpha: 1).cgColor)
cg.fill(CGRect(x: 0, y: 0, width: W, height: H))

// Blurple radial glow, upper-left-ish
let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                      colors: [NSColor(red: 0.345, green: 0.396, blue: 0.949, alpha: 0.55).cgColor,
                               NSColor(red: 0.345, green: 0.396, blue: 0.949, alpha: 0).cgColor] as CFArray,
                      locations: [0, 1])!
cg.drawRadialGradient(glow, startCenter: CGPoint(x: 340, y: 430), startRadius: 0,
                      endCenter: CGPoint(x: 340, y: 430), endRadius: 520, options: [])

// Subtle grid lines
cg.setStrokeColor(NSColor(white: 1, alpha: 0.035).cgColor)
cg.setLineWidth(1)
var x: CGFloat = 0
while x < W { cg.move(to: CGPoint(x: x, y: 0)); cg.addLine(to: CGPoint(x: x, y: H)); x += 48 }
var y: CGFloat = 0
while y < H { cg.move(to: CGPoint(x: 0, y: y)); cg.addLine(to: CGPoint(x: W, y: y)); y += 48 }
cg.strokePath()

// App icon (left)
if let icon = NSImage(contentsOfFile: iconPath) {
    let size: CGFloat = 300
    let rect = NSRect(x: 96, y: (H - size) / 2, width: size, height: size)
    icon.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
}

// Text (right of icon)
func draw(_ s: String, _ font: NSFont, _ color: NSColor, at p: CGPoint) {
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    NSAttributedString(string: s, attributes: attrs).draw(at: p)
}
let tx: CGFloat = 452
draw("Undiscord", NSFont.systemFont(ofSize: 96, weight: .heavy), .white, at: CGPoint(x: tx, y: 350))
draw("Erase your Discord past.", NSFont.systemFont(ofSize: 40, weight: .semibold),
     NSColor(red: 0.60, green: 0.65, blue: 0.98, alpha: 1), at: CGPoint(x: tx + 4, y: 286))
draw("Bulk-delete your own messages — DMs, servers, full history.",
     NSFont.systemFont(ofSize: 27, weight: .regular),
     NSColor(white: 0.68, alpha: 1), at: CGPoint(x: tx + 4, y: 236))
draw("Native macOS app  ·  open source",
     NSFont.monospacedSystemFont(ofSize: 22, weight: .medium),
     NSColor(red: 0.42, green: 0.47, blue: 0.62, alpha: 1), at: CGPoint(x: tx + 4, y: 188))

NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: outPath))
print("Wrote \(outPath)")
