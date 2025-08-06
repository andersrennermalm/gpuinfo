# gpuinfo - macOS GPU Usage Monitor

A simple command-line tool to monitor GPU usage percentage on macOS, particularly useful for monitoring local LLMs like Ollama that utilize GPU resources.

## Features

- Display current GPU utilization percentage
- Percent-only mode for scripts and automation
- Full GPU information mode with detailed specs
- Watch mode for continuous monitoring
- Works with Apple Silicon Macs (M1, M2, M3, etc.)
- Lightweight and fast

## Usage

```bash
# Show current GPU usage once
./gpuinfo

# Show only the percentage number (useful for scripts)
./gpuinfo -p

# Show full GPU information
./gpuinfo -f

# Watch GPU usage continuously (updates every second)
./gpuinfo -w

# Watch with custom interval (e.g., every 2 seconds)
./gpuinfo -w -i 2

# Watch in percent-only mode
./gpuinfo -w -p

# Show help
./gpuinfo -h
```

## Installation

### Quick Build and Test
```bash
make build
./gpuinfo
```

### Install System-wide
```bash
make install
```

This installs `gpuinfo` to `/usr/local/bin/` so you can run it from anywhere:

```bash
gpuinfo
```

### Uninstall
```bash
make uninstall
```

## Examples

Check if your Ollama model is using GPU:
```bash
# Terminal 1: Start monitoring
gpuinfo -w

# Terminal 2: Run your LLM
ollama run llama2
```

You should see GPU usage spike when the model is processing requests.

### Output Examples

**Default output:**
```
$ gpuinfo
GPU: 85%
```

**Percent-only mode (great for scripts):**
```
$ gpuinfo -p
85
```

**Full information mode:**
```
$ gpuinfo -f
GPU Information:
  Name: Apple M3
  Utilization: 85%
  Renderer: 80%
  Tiler: 90%
  Metal: Metal 3
  Memory: 24.0 GB (Unified)
```

## Requirements

- macOS (tested on Apple Silicon)
- Xcode Command Line Tools (`xcode-select --install`)

## Implementation Notes

This tool uses IOKit to read GPU performance statistics from the IOAccelerator service, similar to how the popular [Stats](https://github.com/exelban/stats) application works. It reads the "Device Utilization %" or "GPU Activity(%)" properties from the PerformanceStatistics dictionary.

## Troubleshooting

If you see "GPU: [GPU Name] (monitoring not available)", it means the performance statistics aren't accessible. This can happen if:
- The system doesn't expose GPU utilization data
- There are permission issues
- The GPU isn't currently active

Try running a GPU-intensive task to see if monitoring becomes available.