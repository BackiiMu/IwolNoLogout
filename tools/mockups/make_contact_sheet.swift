import AppKit
import Foundation

guard CommandLine.arguments.count >= 4 else {
    fputs("Usage: make_contact_sheet output.png columns [--bright] input1.png ...\n", stderr)
    exit(1)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])
guard let columns = Int(CommandLine.arguments[2]), columns > 0 else {
    fputs("Columns must be a positive integer.\n", stderr)
    exit(1)
}

let isBright = CommandLine.arguments.count > 3 && CommandLine.arguments[3] == "--bright"
let inputStartIndex = isBright ? 4 : 3
let inputURLs = CommandLine.arguments.dropFirst(inputStartIndex).map { URL(fileURLWithPath: $0) }
let thumbnailWidth = 480
let thumbnailHeight = 270
let labelHeight = 28
let rows = Int(ceil(Double(inputURLs.count) / Double(columns)))
let sheetWidth = columns * thumbnailWidth
let sheetHeight = rows * (thumbnailHeight + labelHeight)

guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: sheetWidth,
    pixelsHigh: sheetHeight,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fputs("Unable to create contact sheet.\n", stderr)
    exit(1)
}

NSGraphicsContext.saveGraphicsState()
guard let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fputs("Unable to create graphics context.\n", stderr)
    exit(1)
}
NSGraphicsContext.current = graphicsContext
(isBright
    ? NSColor(calibratedRed: 0.97, green: 0.99, blue: 1.00, alpha: 1)
    : NSColor(calibratedRed: 0.02, green: 0.04, blue: 0.08, alpha: 1)
).setFill()
NSRect(x: 0, y: 0, width: sheetWidth, height: sheetHeight).fill()

let paragraphStyle = NSMutableParagraphStyle()
paragraphStyle.alignment = .center
let textAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 15, weight: .semibold),
    .foregroundColor: isBright
        ? NSColor(calibratedRed: 0.06, green: 0.16, blue: 0.23, alpha: 1)
        : NSColor(calibratedRed: 0.75, green: 0.82, blue: 0.88, alpha: 1),
    .paragraphStyle: paragraphStyle,
]

for (index, inputURL) in inputURLs.enumerated() {
    guard let image = NSImage(contentsOf: inputURL) else {
        continue
    }
    let column = index % columns
    let row = index / columns
    let originX = column * thumbnailWidth
    let originY = sheetHeight - (row + 1) * (thumbnailHeight + labelHeight)
    image.draw(
        in: NSRect(x: originX, y: originY + labelHeight, width: thumbnailWidth, height: thumbnailHeight),
        from: .zero,
        operation: .copy,
        fraction: 1
    )
    let label = inputURL.deletingPathExtension().lastPathComponent
    label.draw(
        in: NSRect(x: originX + 4, y: originY + 5, width: thumbnailWidth - 8, height: labelHeight - 8),
        withAttributes: textAttributes
    )
}

NSGraphicsContext.restoreGraphicsState()

guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Unable to encode contact sheet.\n", stderr)
    exit(1)
}
try pngData.write(to: outputURL)
