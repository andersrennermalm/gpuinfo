#!/usr/bin/env swift

import Foundation
import Metal
import IOKit

// MARK: - Version
let VERSION = "1.0.0"

// MARK: - GPU Info Structure
struct GPUInfo {
    let name: String
    let utilizationPercentage: Double?
    let coreCount: Int?
    let memorySize: Int64?
    let metalVersion: String?
    let rendererUtilization: Double?
    let tilerUtilization: Double?
}

// MARK: - GPU Monitoring
class GPUMonitor {
    private var device: MTLDevice?
    private let kIOAcceleratorClassName = "IOAccelerator"
    
    init() {
        self.device = MTLCreateSystemDefaultDevice()
    }
    
    func getGPUInfo() -> GPUInfo {
        guard let device = device else {
            return GPUInfo(name: "Unknown GPU", utilizationPercentage: nil,
                          coreCount: nil, memorySize: nil, metalVersion: nil,
                          rendererUtilization: nil, tilerUtilization: nil)
        }
        
        let gpuName = device.name
        let (utilization, renderer, tiler) = getGPUUtilization()
        let coreCount = getCoreCount()
        let memorySize = getMemorySize()
        let metalVersion = getMetalVersion()
        
        return GPUInfo(name: gpuName, utilizationPercentage: utilization,
                      coreCount: coreCount, memorySize: memorySize,
                      metalVersion: metalVersion, rendererUtilization: renderer,
                      tilerUtilization: tiler)
    }
    
    private func getGPUUtilization() -> (Double?, Double?, Double?) {
        return fetchIOService()
    }
    
    private func getCoreCount() -> Int? {
        guard device != nil else { return nil }
        // Apple Silicon GPUs don't expose core count directly through Metal
        // Try to extract from device name or other properties
        return nil
    }
    
    private func getMemorySize() -> Int64? {
        guard let device = device else { return nil }
        if device.hasUnifiedMemory {
            // For Apple Silicon, return system memory size as it's shared
            let physicalMemory = ProcessInfo.processInfo.physicalMemory
            return Int64(physicalMemory)
        }
        return nil
    }
    
    private func getMetalVersion() -> String? {
        guard let device = device else { return nil }
        
        if #available(macOS 13.0, *) {
            if device.supportsFamily(.apple9) { return "Metal 3" }
        }
        if #available(macOS 12.0, *) {
            if device.supportsFamily(.apple8) { return "Metal 3" }
        }
        if #available(macOS 11.0, *) {
            if device.supportsFamily(.apple7) { return "Metal 2.4" }
        }
        return "Metal 2+"
    }
    
    private func fetchIOService() -> (Double?, Double?, Double?) {
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, 
                                                IOServiceMatching(kIOAcceleratorClassName), 
                                                &iterator)
        
        if result != KERN_SUCCESS {
            return (nil, nil, nil)
        }
        
        defer { IOObjectRelease(iterator) }
        
        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer { IOObjectRelease(service) }
            
            var properties: Unmanaged<CFMutableDictionary>?
            let propertiesResult = IORegistryEntryCreateCFProperties(service, &properties, 
                                                                   kCFAllocatorDefault, 0)
            
            if propertiesResult == KERN_SUCCESS, 
               let props = properties?.takeRetainedValue() as? [String: Any],
               let stats = props["PerformanceStatistics"] as? [String: Any] {
                
                // Extract device utilization
                let utilization: Int? = stats["Device Utilization %"] as? Int ?? 
                                       stats["GPU Activity(%)"] as? Int ?? nil
                
                // Extract renderer utilization
                let renderer: Int? = stats["Renderer Utilization %"] as? Int ?? nil
                
                // Extract tiler utilization
                let tiler: Int? = stats["Tiler Utilization %"] as? Int ?? nil
                
                let deviceUtil = utilization.map { Double(min(max($0, 0), 100)) }
                let rendererUtil = renderer.map { Double(min(max($0, 0), 100)) }
                let tilerUtil = tiler.map { Double(min(max($0, 0), 100)) }
                
                return (deviceUtil, rendererUtil, tilerUtil)
            }
            
            service = IOIteratorNext(iterator)
        }
        
        return (nil, nil, nil)
    }
}

// MARK: - Command Line Interface
func printUsage() {
    print("gpuinfo v\(VERSION) - macOS GPU Usage Monitor")
    print("")
    print("Usage: gpuinfo [options]")
    print("  -h, --help     Show this help message")
    print("  -v, --version  Show version information")
    print("  -w, --watch    Watch GPU usage continuously")
    print("  -i, --interval Set update interval in seconds (default: 1)")
    print("  -p, --percent  Show only the percentage number")
    print("  -f, --full     Show full GPU information")
}

func printVersion() {
    print("gpuinfo version \(VERSION)")
    print("A macOS GPU usage monitoring tool")
    print("Copyright (c) 2025 Anders Rennermalm")
    print("Licensed under MIT License")
}

func formatOutput(_ gpuInfo: GPUInfo, percentOnly: Bool = false, fullInfo: Bool = false) {
    if percentOnly {
        if let utilization = gpuInfo.utilizationPercentage {
            print("\(Int(utilization))")
        } else {
            print("N/A")
        }
        return
    }
    
    if fullInfo {
        formatFullOutput(gpuInfo)
        return
    }
    
    // Default output
    if let utilization = gpuInfo.utilizationPercentage {
        print("GPU: \(Int(utilization))%")
    } else {
        print("GPU: \(gpuInfo.name) (monitoring not available)")
    }
}

func formatFullOutput(_ gpuInfo: GPUInfo) {
    print("GPU Information:")
    print("  Name: \(gpuInfo.name)")
    
    if let utilization = gpuInfo.utilizationPercentage {
        print("  Utilization: \(Int(utilization))%")
    } else {
        print("  Utilization: N/A")
    }
    
    if let renderer = gpuInfo.rendererUtilization {
        print("  Renderer: \(Int(renderer))%")
    }
    
    if let tiler = gpuInfo.tilerUtilization {
        print("  Tiler: \(Int(tiler))%")
    }
    
    if let metalVersion = gpuInfo.metalVersion {
        print("  Metal: \(metalVersion)")
    }
    
    if let memorySize = gpuInfo.memorySize {
        let memorySizeGB = Double(memorySize) / (1024 * 1024 * 1024)
        print("  Memory: \(String(format: "%.1f", memorySizeGB)) GB (Unified)")
    }
    
    if let coreCount = gpuInfo.coreCount {
        print("  Cores: \(coreCount)")
    }
}

// MARK: - Main Function
func main() {
    let arguments = CommandLine.arguments
    var watchMode = false
    var interval: TimeInterval = 1.0
    var percentOnly = false
    var fullInfo = false
    
    // Parse command line arguments
    var i = 1
    while i < arguments.count {
        let arg = arguments[i]
        switch arg {
        case "-h", "--help":
            printUsage()
            exit(0)
        case "-v", "--version":
            printVersion()
            exit(0)
        case "-w", "--watch":
            watchMode = true
        case "-p", "--percent":
            percentOnly = true
        case "-f", "--full":
            fullInfo = true
        case "-i", "--interval":
            if i + 1 < arguments.count {
                if let parsedInterval = Double(arguments[i + 1]) {
                    interval = parsedInterval
                    i += 1
                } else {
                    print("Error: Invalid interval value")
                    exit(1)
                }
            } else {
                print("Error: Missing interval value")
                exit(1)
            }
        default:
            print("Error: Unknown option \(arg)")
            printUsage()
            exit(1)
        }
        i += 1
    }
    
    let monitor = GPUMonitor()
    
    if watchMode {
        if !percentOnly && !fullInfo {
            print("Watching GPU usage (press Ctrl+C to stop)...")
        }
        while true {
            let gpuInfo = monitor.getGPUInfo()
            formatOutput(gpuInfo, percentOnly: percentOnly, fullInfo: fullInfo)
            Thread.sleep(forTimeInterval: interval)
        }
    } else {
        let gpuInfo = monitor.getGPUInfo()
        formatOutput(gpuInfo, percentOnly: percentOnly, fullInfo: fullInfo)
    }
}

// Run main function
main()