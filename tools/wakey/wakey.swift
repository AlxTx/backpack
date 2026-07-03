#!/usr/bin/swift
import Foundation
import CoreGraphics

let defaultInterval: TimeInterval = 30
let defaultPixels: Int = 2

func parseDuration(_ value: String) -> TimeInterval? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let last = trimmed.last else { return nil }
    let unit = String(last)
    let numberPart = String(trimmed.dropLast())
    guard let amount = Int(numberPart), amount > 0 else { return nil }

    switch unit {
    case "s": return TimeInterval(amount)
    case "m": return TimeInterval(amount * 60)
    case "h": return TimeInterval(amount * 3600)
    default: return nil
    }
}

func printUsage() {
    print("Usage: wakey start [--interval <10s|2m|1h>] [--pixels <n>]")
}

func moveMouseByPixels(_ pixels: Int) {
    let location = CGEvent(source: nil)?.location ?? .zero

    if let moveOut = CGEvent(
        mouseEventSource: nil,
        mouseType: .mouseMoved,
        mouseCursorPosition: CGPoint(x: location.x + CGFloat(pixels), y: location.y),
        mouseButton: .left
    ) {
        moveOut.post(tap: .cghidEventTap)
    }

    usleep(100_000)

    if let moveBack = CGEvent(
        mouseEventSource: nil,
        mouseType: .mouseMoved,
        mouseCursorPosition: location,
        mouseButton: .left
    ) {
        moveBack.post(tap: .cghidEventTap)
    }
}

func runStart(interval: TimeInterval, pixels: Int) -> Int32 {
    print("Wakey started.")
    print("Moving mouse every \(Int(interval))s by \(pixels)px.")
    print("Press Ctrl+C to stop.")

    while true {
        moveMouseByPixels(pixels)
        Thread.sleep(forTimeInterval: interval)
    }
}

func main() -> Int32 {
    var args = CommandLine.arguments
    _ = args.removeFirst()

    guard let command = args.first else {
        printUsage()
        return 2
    }

    guard command == "start" else {
        printUsage()
        return 2
    }

    var interval = defaultInterval
    var pixels = defaultPixels

    var index = 1
    while index < args.count {
        let token = args[index]
        switch token {
        case "--interval":
            guard index + 1 < args.count, let parsed = parseDuration(args[index + 1]) else {
                fputs("Invalid interval. Use formats like 10s, 30s, 2m, 1h.\n", stderr)
                return 2
            }
            interval = parsed
            index += 2
        case "--pixels":
            guard index + 1 < args.count, let parsed = Int(args[index + 1]), parsed > 0 else {
                fputs("Invalid pixels. Must be a positive integer.\n", stderr)
                return 2
            }
            pixels = parsed
            index += 2
        default:
            fputs("Unknown option: \(token)\n", stderr)
            printUsage()
            return 2
        }
    }

    return runStart(interval: interval, pixels: pixels)
}

exit(main())
