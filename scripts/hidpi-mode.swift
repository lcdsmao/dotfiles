import CoreGraphics
import Foundation

private func usage() -> Never {
    fputs("Usage:\n  hidpi-mode list <display-id>\n  hidpi-mode native <display-id>\n  hidpi-mode apply <display-id> <logical-width> <logical-height> [refresh-rate]\n", stderr)
    exit(64)
}

private func fail(_ message: String, code: Int32 = 1) -> Never {
    fputs("hidpi-mode: \(message)\n", stderr)
    exit(code)
}

guard CommandLine.arguments.count >= 3 else { usage() }

let operation = CommandLine.arguments[1]
guard let displayIDValue = UInt32(CommandLine.arguments[2]) else {
    fail("invalid display ID: \(CommandLine.arguments[2])")
}

let displayID = CGDirectDisplayID(displayIDValue)
guard CGDisplayIsOnline(displayID) != 0 else {
    fail("display \(displayIDValue) is not online")
}

let modeOptions = [kCGDisplayShowDuplicateLowResolutionModes as String: true] as CFDictionary
guard let modes = CGDisplayCopyAllDisplayModes(displayID, modeOptions) as? [CGDisplayMode] else {
    fail("could not read display modes for display \(displayIDValue)")
}

func describe(_ mode: CGDisplayMode) -> String {
    let refresh = mode.refreshRate > 0 ? String(format: "%.2fHz", mode.refreshRate) : "unspecified refresh"
    let hidpi = mode.pixelWidth == mode.width * 2 && mode.pixelHeight == mode.height * 2
    return "\(mode.width)x\(mode.height) \(hidpi ? "HiDPI" : "LoDPI") " +
        "(\(mode.pixelWidth)x\(mode.pixelHeight), \(refresh))"
}

if operation == "native" {
    guard let current = CGDisplayCopyDisplayMode(displayID) else {
        fail("could not read the current display mode")
    }

    let currentAspect = Double(current.pixelWidth) / Double(current.pixelHeight)
    let nativeModes = modes.filter { mode in
        let modeAspect = Double(mode.pixelWidth) / Double(mode.pixelHeight)
        return mode.isUsableForDesktopGUI() &&
            mode.pixelWidth == mode.width &&
            mode.pixelHeight == mode.height &&
            abs(modeAspect - currentAspect) < 0.01
    }

    guard let native = nativeModes.max(by: {
        ($0.pixelWidth * $0.pixelHeight) < ($1.pixelWidth * $1.pixelHeight)
    }) else {
        fail("could not infer a native LoDPI mode from the available modes")
    }

    print("\(native.width)\t\(native.height)")
    exit(0)
}

if operation == "list" {
    for mode in modes where mode.isUsableForDesktopGUI() {
        print(describe(mode))
    }
    exit(0)
}

guard operation == "apply", CommandLine.arguments.count >= 5 else { usage() }
guard let logicalWidth = Int(CommandLine.arguments[3]), logicalWidth > 0,
      let logicalHeight = Int(CommandLine.arguments[4]), logicalHeight > 0 else {
    fail("logical resolution must be positive integers")
}

let requestedRefresh: Double
if CommandLine.arguments.count >= 6 {
    guard let value = Double(CommandLine.arguments[5]), value > 0 else {
        fail("refresh rate must be a positive number")
    }
    requestedRefresh = value
} else {
    requestedRefresh = 60
}

let candidates = modes.filter { mode in
    mode.isUsableForDesktopGUI() &&
    Int(mode.width) == logicalWidth &&
    Int(mode.height) == logicalHeight &&
    Int(mode.pixelWidth) == logicalWidth * 2 &&
    Int(mode.pixelHeight) == logicalHeight * 2
}

guard let selected = candidates.min(by: {
    abs($0.refreshRate - requestedRefresh) < abs($1.refreshRate - requestedRefresh)
}) else {
    fail("no HiDPI mode found for \(logicalWidth)x\(logicalHeight); run 'list' after installing the display override")
}

var configuration: CGDisplayConfigRef?
let beginResult = CGBeginDisplayConfiguration(&configuration)
guard beginResult == .success, let configuration else {
    fail("could not begin display configuration (CoreGraphics error \(beginResult.rawValue))")
}

let configureResult = CGConfigureDisplayWithDisplayMode(configuration, displayID, selected, nil)
guard configureResult == .success else {
    CGCancelDisplayConfiguration(configuration)
    fail("could not configure display mode (CoreGraphics error \(configureResult.rawValue))")
}

let completeResult = CGCompleteDisplayConfiguration(configuration, .permanently)
guard completeResult == .success else {
    fail("could not save display mode (CoreGraphics error \(completeResult.rawValue))")
}

print("Applied \(describe(selected)) to display \(displayIDValue)")
