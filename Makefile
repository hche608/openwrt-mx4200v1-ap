# OpenWrt ImageBuilder Makefile for MX4200 V1 AP mode
# Usage: make <target>

# Configuration
OPENWRT_VERSION := 24.10.5
TARGET := qualcommax
SUBTARGET := ipq807x
PROFILE := linksys_mx4200v1
EXPECTED_SHA256 := 38fce4fbcd9ca26ff33bb6dbf9e9a22dceb05d2fb6bae3b9f8c2c0cde73f24c0

# Derived variables
IMAGEBUILDER_ARCHIVE := openwrt-imagebuilder-$(OPENWRT_VERSION)-$(TARGET)-$(SUBTARGET).Linux-x86_64.tar.zst
IMAGEBUILDER_DIR := openwrt-imagebuilder-$(OPENWRT_VERSION)-$(TARGET)-$(SUBTARGET).Linux-x86_64
IMAGEBUILDER_URL := https://downloads.openwrt.org/releases/$(OPENWRT_VERSION)/targets/$(TARGET)/$(SUBTARGET)/$(IMAGEBUILDER_ARCHIVE)
PACKAGES := $(shell cat packages/package-list.txt | grep -v '^\#' | grep -v '^$$' | tr '\n' ' ')

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

.PHONY: help download verify extract build clean distclean status all

# Default target
all: download verify extract build

help:
	@echo "$(GREEN)OpenWrt ImageBuilder for MX4200 V1 AP mode$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo "  $(YELLOW)download$(NC)    - Download ImageBuilder archive"
	@echo "  $(YELLOW)verify$(NC)      - Verify SHA256 checksum"
	@echo "  $(YELLOW)extract$(NC)     - Extract ImageBuilder archive"
	@echo "  $(YELLOW)build$(NC)       - Build firmware image"
	@echo "  $(YELLOW)clean$(NC)       - Remove build artifacts"
	@echo "  $(YELLOW)distclean$(NC)   - Remove everything (archive + extracted)"
	@echo "  $(YELLOW)status$(NC)      - Show current status"
	@echo "  $(YELLOW)all$(NC)         - Run download, verify, extract, build"
	@echo ""
	@echo "Configuration:"
	@echo "  Version: $(OPENWRT_VERSION)"
	@echo "  Target:  $(TARGET)/$(SUBTARGET)"
	@echo "  Profile: $(PROFILE)"

download:
	@if [ -f "$(IMAGEBUILDER_ARCHIVE)" ]; then \
		echo "$(GREEN)✓ Archive already exists: $(IMAGEBUILDER_ARCHIVE)$(NC)"; \
	else \
		echo "$(YELLOW)Downloading ImageBuilder...$(NC)"; \
		if command -v wget >/dev/null 2>&1; then \
			wget -O "$(IMAGEBUILDER_ARCHIVE)" "$(IMAGEBUILDER_URL)"; \
		elif command -v curl >/dev/null 2>&1; then \
			curl -L -o "$(IMAGEBUILDER_ARCHIVE)" "$(IMAGEBUILDER_URL)"; \
		else \
			echo "$(RED)✗ Neither wget nor curl found. Please install one of them.$(NC)"; \
			exit 1; \
		fi; \
		echo "$(GREEN)✓ Download completed$(NC)"; \
	fi

verify:
	@if [ ! -f "$(IMAGEBUILDER_ARCHIVE)" ]; then \
		echo "$(RED)✗ Archive not found. Run 'make download' first.$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Verifying SHA256 checksum...$(NC)"
	@ACTUAL=$$(shasum -a 256 "$(IMAGEBUILDER_ARCHIVE)" | cut -d' ' -f1); \
	if [ "$$ACTUAL" = "$(EXPECTED_SHA256)" ]; then \
		echo "$(GREEN)✓ Checksum verified successfully$(NC)"; \
	else \
		echo "$(RED)✗ Checksum verification failed!$(NC)"; \
		echo "$(RED)Expected: $(EXPECTED_SHA256)$(NC)"; \
		echo "$(RED)Actual:   $$ACTUAL$(NC)"; \
		echo "$(YELLOW)Removing corrupted file...$(NC)"; \
		rm -f "$(IMAGEBUILDER_ARCHIVE)"; \
		exit 1; \
	fi

extract: verify
	@if [ -d "$(IMAGEBUILDER_DIR)" ]; then \
		echo "$(GREEN)✓ ImageBuilder already extracted: $(IMAGEBUILDER_DIR)$(NC)"; \
	else \
		echo "$(YELLOW)Extracting ImageBuilder...$(NC)"; \
		tar -xf "$(IMAGEBUILDER_ARCHIVE)"; \
		echo "$(GREEN)✓ Extraction completed$(NC)"; \
	fi

build: extract
	@echo "$(YELLOW)Copying custom files...$(NC)"
	@cp -r files/* "$(IMAGEBUILDER_DIR)/files/" 2>/dev/null || true
	@echo "$(YELLOW)Building firmware image...$(NC)"
	@cd "$(IMAGEBUILDER_DIR)" && \
		make image PROFILE="$(PROFILE)" PACKAGES="$(PACKAGES)" FILES="../files"
	@if [ $$? -eq 0 ]; then \
		echo "$(GREEN)✓ Build completed successfully!$(NC)"; \
		echo "$(GREEN)Firmware images are in: $(IMAGEBUILDER_DIR)/bin/targets/$(TARGET)/$(SUBTARGET)/$(NC)"; \
		ls -la "$(IMAGEBUILDER_DIR)/bin/targets/$(TARGET)/$(SUBTARGET)/"*mx4200* 2>/dev/null || \
		ls -la "$(IMAGEBUILDER_DIR)/bin/targets/$(TARGET)/$(SUBTARGET)/"*linksys* 2>/dev/null || \
		ls -la "$(IMAGEBUILDER_DIR)/bin/targets/$(TARGET)/$(SUBTARGET)/"; \
	else \
		echo "$(RED)✗ Build failed!$(NC)"; \
		exit 1; \
	fi

clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@if [ -d "$(IMAGEBUILDER_DIR)" ]; then \
		cd "$(IMAGEBUILDER_DIR)" && make clean 2>/dev/null || true; \
		rm -rf "$(IMAGEBUILDER_DIR)/bin" "$(IMAGEBUILDER_DIR)/build_dir" "$(IMAGEBUILDER_DIR)/staging_dir" "$(IMAGEBUILDER_DIR)/tmp"; \
		echo "$(GREEN)✓ Build artifacts cleaned$(NC)"; \
	else \
		echo "$(YELLOW)No build artifacts to clean$(NC)"; \
	fi

distclean:
	@echo "$(YELLOW)Removing all files...$(NC)"
	@rm -rf "$(IMAGEBUILDER_DIR)" "$(IMAGEBUILDER_ARCHIVE)"
	@echo "$(GREEN)✓ All files removed$(NC)"

status:
	@echo "$(GREEN)OpenWrt ImageBuilder Status$(NC)"
	@echo "=========================="
	@echo "Version: $(OPENWRT_VERSION)"
	@echo "Target:  $(TARGET)/$(SUBTARGET)"
	@echo "Profile: $(PROFILE)"
	@echo ""
	@if [ -f "$(IMAGEBUILDER_ARCHIVE)" ]; then \
		echo "$(GREEN)✓ Archive: $(IMAGEBUILDER_ARCHIVE)$(NC)"; \
		ACTUAL=$$(shasum -a 256 "$(IMAGEBUILDER_ARCHIVE)" | cut -d' ' -f1); \
		if [ "$$ACTUAL" = "$(EXPECTED_SHA256)" ]; then \
			echo "$(GREEN)✓ Checksum: Valid$(NC)"; \
		else \
			echo "$(RED)✗ Checksum: Invalid$(NC)"; \
		fi; \
	else \
		echo "$(RED)✗ Archive: Not found$(NC)"; \
	fi
	@if [ -d "$(IMAGEBUILDER_DIR)" ]; then \
		echo "$(GREEN)✓ Extracted: $(IMAGEBUILDER_DIR)$(NC)"; \
		if [ -d "$(IMAGEBUILDER_DIR)/bin" ]; then \
			echo "$(GREEN)✓ Built: Yes$(NC)"; \
			echo "$(YELLOW)Images:$(NC)"; \
			ls -la "$(IMAGEBUILDER_DIR)/bin/targets/$(TARGET)/$(SUBTARGET)/"*mx4200* 2>/dev/null || \
			ls -la "$(IMAGEBUILDER_DIR)/bin/targets/$(TARGET)/$(SUBTARGET)/"*linksys* 2>/dev/null || \
			echo "  No firmware images found"; \
		else \
			echo "$(YELLOW)Built: No$(NC)"; \
		fi; \
	else \
		echo "$(RED)✗ Extracted: No$(NC)"; \
	fi