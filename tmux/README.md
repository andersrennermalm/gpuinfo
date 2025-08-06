# tmux Integration for gpuinfo

Beautiful GPU usage monitoring in your tmux status bar with dynamic colors.

## Features

- 🎨 **Dynamic Catppuccin Colors** - Background changes based on GPU load
- 󰢮 **Beautiful GPU Icon** - Matches other system monitoring icons
- ⚡ **Real-time Updates** - Configurable refresh intervals
- 🔄 **Seamless Integration** - Works with existing Catppuccin tmux theme

## Color Coding

The GPU module uses dynamic colors to indicate usage levels:

- 🔵 **Blue (0-25%)** - Low usage, idle state
- 🟨 **Yellow (25-50%)** - Medium usage, light workload
- 🟧 **Orange (50-80%)** - High usage, heavy processing
- 🟥 **Red (80%+)** - Critical usage, maximum load

Perfect for monitoring AI workloads like Ollama, Stable Diffusion, or any GPU-intensive tasks!

## Quick Setup

### Prerequisites
- tmux with [Catppuccin theme](https://github.com/catppuccin/tmux) installed
- `gpuinfo` installed system-wide (`sudo make install` from project root)

### Installation

1. **Copy the GPU module to your tmux config:**
```bash
# Add this line to your ~/.tmux.conf after the CPU module
set -ag status-right "#(/path/to/gpuinfo/tmux/tmux-gpu.tmux)"
```

2. **Set update interval (optional but recommended):**
```bash
# Add to ~/.tmux.conf for 5-second updates
set -g status-interval 5
```

3. **Reload tmux:**
```bash
tmux source-file ~/.tmux.conf
# Or press your reload keybind (usually Ctrl+s then 'r')
```

## Example Configuration

Here's how to integrate with a typical Catppuccin tmux setup:

```bash
# ~/.tmux.conf excerpt
set -g status-right "#{E:@catppuccin_status_application}"
set -agF status-right "#{E:@catppuccin_status_cpu}"
set -ag status-right "#(/Users/yourusername/projects/mac/gpuinfo/tmux/tmux-gpu.tmux)"
set -ag status-right "#{E:@catppuccin_status_session}"
set -ag status-right "#{E:@catppuccin_status_uptime}"
set -agF status-right "#{E:@catppuccin_status_battery}"

# Recommended: Update every 5 seconds for responsive monitoring
set -g status-interval 5
```

## Update Intervals

Choose the refresh rate that works best for your workflow:

| Interval | Use Case | Impact |
|----------|----------|--------|
| 1-2 seconds | Development/debugging | High CPU usage, very responsive |
| 5 seconds | **Recommended** - AI/LLM monitoring | Good balance |
| 15 seconds | General use | Default tmux setting |
| 30+ seconds | Battery saving | Low resource usage |

## Files

- `tmux-gpu.tmux` - Main GPU monitoring script with Catppuccin styling
- `catppuccin_gpu.conf` - Advanced Catppuccin module configuration (future use)
- `install_gpu_module.sh` - Automated installation script
- `README.md` - This documentation

## Troubleshooting

**GPU shows 0% or N/A:**
- Ensure `gpuinfo` is installed: `which gpuinfo`
- Test manually: `gpuinfo -p`
- Check path in tmux config matches your installation

**Colors don't match theme:**
- Verify you're using Catppuccin Mocha flavor
- Check that other Catppuccin modules work correctly

**Not updating:**
- Check `tmux show-options -g status-interval`
- Reload config: `tmux source-file ~/.tmux.conf`

## Customization

To modify colors or thresholds, edit the variables in `tmux-gpu.tmux`:

```bash
# Usage thresholds (percentages)
if [ "$gpu_usage" -lt 25 ]; then    # Low
elif [ "$gpu_usage" -lt 50 ]; then  # Medium  
elif [ "$gpu_usage" -lt 80 ]; then  # High
else                                # Critical

# Catppuccin Mocha colors
local bg_low="#313244"      # surface0
local bg_medium="#f9e2af"   # yellow
local bg_high="#fab387"     # peach
local bg_critical="#f38ba8" # red
```

## Integration Examples

**Watch Ollama in action:**
```bash
# Terminal 1: Monitor GPU
tmux  # Your status bar shows GPU usage

# Terminal 2: Run LLM
ollama run llama2
# Watch the GPU module change from blue → yellow → orange as the model loads and processes
```

**Monitor training workloads:**
```bash
# The GPU module provides instant visual feedback for:
# - PyTorch model training
# - Stable Diffusion generation
# - Video encoding/decoding
# - Any Metal/OpenCL workloads
```

Perfect for keeping an eye on your M1/M2/M3 GPU utilization! 🚀