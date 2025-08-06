#!/usr/bin/make -f

# macOS GPU Info Tool Makefile

SWIFT_FILE = src/gpuinfo.swift
EXECUTABLE = gpuinfo
INSTALL_PATH = /usr/local/bin
VERSION = 1.0.0

.PHONY: all build install uninstall clean help version release

all: build

# Build the executable
build:
	@echo "Building GPU info tool v$(VERSION)..."
	swiftc -o $(EXECUTABLE) $(SWIFT_FILE) -framework Metal -framework IOKit -framework Foundation

# Install to system path
install: build
	@echo "Installing to $(INSTALL_PATH)..."
	sudo cp $(EXECUTABLE) $(INSTALL_PATH)/
	sudo chmod +x $(INSTALL_PATH)/$(EXECUTABLE)
	@echo "Installed successfully. You can now run 'gpuinfo' from anywhere."

# Uninstall from system
uninstall:
	@echo "Removing from $(INSTALL_PATH)..."
	sudo rm -f $(INSTALL_PATH)/$(EXECUTABLE)
	@echo "Uninstalled successfully."

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(EXECUTABLE)
	rm -rf release/

# Show version
version:
	@echo "gpuinfo version $(VERSION)"

# Create release package
release: clean build
	@echo "Creating release package..."
	@mkdir -p release
	@cp $(EXECUTABLE) release/
	@cp README.md release/
	@cp LICENSE release/
	@echo "Release package created in release/"

# Show help
help:
	@echo "Available targets:"
	@echo "  build     - Build the gpuinfo executable"
	@echo "  install   - Build and install to /usr/local/bin"
	@echo "  uninstall - Remove from /usr/local/bin"
	@echo "  clean     - Remove build artifacts"
	@echo "  version   - Show version"
	@echo "  release   - Create release package"
	@echo "  help      - Show this help message"