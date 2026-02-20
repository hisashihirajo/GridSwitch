#!/usr/bin/env swift
// GridSwitchアプリアイコン生成スクリプト
// 2x2グリッドをモチーフにしたアイコンを作成

import AppKit

func generateIcon(size: Int) -> NSImage {
  let image = NSImage(size: NSSize(width: size, height: size))
  image.lockFocus()

  let s = CGFloat(size)

  // 背景: 角丸矩形にグラデーション
  let bgRect = NSRect(x: 0, y: 0, width: s, height: s)
  let cornerRadius = s * 0.22
  let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)

  // グラデーション（濃い青 → 紫）
  let gradient = NSGradient(
    starting: NSColor(red: 0.15, green: 0.35, blue: 0.85, alpha: 1.0),
    ending: NSColor(red: 0.50, green: 0.20, blue: 0.80, alpha: 1.0)
  )!
  gradient.draw(in: bgPath, angle: -45)

  // 2x2グリッドのセル
  let padding = s * 0.18
  let gap = s * 0.06
  let cellSize = (s - padding * 2 - gap) / 2

  let positions: [(CGFloat, CGFloat)] = [
    (padding, s - padding - cellSize),           // 左上
    (padding + cellSize + gap, s - padding - cellSize), // 右上
    (padding, padding),                           // 左下
    (padding + cellSize + gap, padding),          // 右下
  ]

  let cellCorner = cellSize * 0.20

  // セルの色（白、少し透明感を変えて立体感）
  let cellAlphas: [CGFloat] = [0.95, 0.85, 0.80, 0.90]

  for (i, pos) in positions.enumerated() {
    let cellRect = NSRect(x: pos.0, y: pos.1, width: cellSize, height: cellSize)
    let cellPath = NSBezierPath(roundedRect: cellRect, xRadius: cellCorner, yRadius: cellCorner)

    // セルの背景（白 + 透明度）
    NSColor(white: 1.0, alpha: cellAlphas[i]).setFill()
    cellPath.fill()
  }

  image.unlockFocus()
  return image
}

// iconset ディレクトリを作成
let iconsetPath = "/Users/admin/dev/Cursor/switcher/Resources/AppIcon.iconset"
let fm = FileManager.default
try? fm.removeItem(atPath: iconsetPath)
try! fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

// 必要なサイズを生成
let sizes: [(String, Int)] = [
  ("icon_16x16.png", 16),
  ("icon_16x16@2x.png", 32),
  ("icon_32x32.png", 32),
  ("icon_32x32@2x.png", 64),
  ("icon_128x128.png", 128),
  ("icon_128x128@2x.png", 256),
  ("icon_256x256.png", 256),
  ("icon_256x256@2x.png", 512),
  ("icon_512x512.png", 512),
  ("icon_512x512@2x.png", 1024),
]

for (filename, size) in sizes {
  let image = generateIcon(size: size)
  guard let tiffData = image.tiffRepresentation,
    let rep = NSBitmapImageRep(data: tiffData),
    let pngData = rep.representation(using: .png, properties: [:])
  else {
    print("Failed to generate \(filename)")
    continue
  }
  let filePath = "\(iconsetPath)/\(filename)"
  try! pngData.write(to: URL(fileURLWithPath: filePath))
  print("Generated: \(filename) (\(size)x\(size))")
}

print("Iconset generated at: \(iconsetPath)")
print("Converting to .icns...")
