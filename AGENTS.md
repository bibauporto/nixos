# AGENTS.md - NixOS Configuration Guidelines

This document provides instructions for AI agents operating on this NixOS configuration repository.

## 1. Project Overview

This repository contains the NixOS system configuration for the host `lea`.
It uses **Nix Flakes** for reproducibility and dependency management.

- **Flake Entry Point**: `flake.nix`
- **Host Configuration**: `nixosConfigurations.lea-pc`
- **Main Configuration File**: `configuration.nix`
- **Modules Directory**: `module/`

## 2. Build and Deployment Commands

Use the following commands to build, test, and deploy the system configuration.
Always run these commands from the repository root.

### Build & Switch (Apply Changes)
To apply the configuration to the running system:
```bash
sudo nixos-rebuild switch --flake .#lea-pc
```

### Build Only (Dry Run)
To build the configuration without switching (useful for verifying syntax and package availability):
```bash
nixos-rebuild build --flake .#lea-pc
```

### Virtual Machine Test
To build and run a QEMU VM of the configuration (safest way to test significant changes):
```bash
nixos-rebuild build-vm --flake .#lea-pc
./result/bin/run-nixos-vm
```

### Update Flake Inputs
To update dependencies (e.g., `nixpkgs`):
```bash
nix flake update
```

### Format Code
Since no formatter is installed globally, use `nix run`:
```bash
nix run nixpkgs#nixfmt -- .
# OR
nix run nixpkgs#alejandra .
```

## 3. Code Style Guidelines

### Nix Language
- **Indentation**: 2 spaces. No tabs.
- **Line Length**: Soft limit of 100 characters.
- **Comments**:
    - Use `#` for single-line comments.
    - Document complex logic or non-obvious configurations.
- **Naming**:
    - Files: `kebab-case.nix` (e.g., `hardware-configuration.nix`, `module/boot.nix`).
    - Variables/Attributes: `camelCase` (standard Nix convention).

### Shell Scripts (`.sh`)
- **Shebang**: Always use `#!/bin/bash` or `#!/usr/bin/env bash`.
- **Safety**: Always start scripts with `set -euo pipefail` to catch errors early.
- ** formatting**: 2 spaces indentation.

## 4. Architecture & Module Structure

The configuration is modularized to keep `configuration.nix` clean.

### `configuration.nix`
This is the orchestrator. It should:
1.  Import modules from `./module/`.
2.  Set global/system-wide settings (e.g., `system.stateVersion`, `nix.settings`).
3.  Define the primary user (`LEA`).

### `module/` Directory
New features should be added as separate files in the `module/` directory.
- **Example**: To add gaming support, create `module/gaming.nix`.
- **Structure**:
  ```nix
  { config, pkgs, lib, ... }:

  {
    environment.systemPackages = with pkgs; [
      # ... packages ...
    ];

    # ... options ...
  }
  ```
- **Activation**: After creating a module, explicitly import it in `configuration.nix`.

## 5. Development Workflow for Agents

1.  **Understand the Goal**: Read the user request and identify if it requires a new module or modifying an existing one.
2.  **Check Existing Config**: Use `grep` or `read` to check if a program or service is already configured to avoid duplicates.
3.  **Search Packages**: If adding packages, assume `nixpkgs` is the source. You can search for package names using:
    ```bash
    nix search nixpkgs <package_name>
    ```
4.  **Implement**:
    - Prefer editing existing modules if the change fits there (e.g., adding a font to `module/fonts.nix`).
    - Create a new module for distinct functionality.
5.  **Verify**:
    - Run `nixos-rebuild build --flake .#lea-pc` to verify syntax and package resolution.
    - If the change is risky (e.g., bootloader, network), strictly recommend or perform a VM test first.

## 6. Error Handling & debugging

- **Build Failures**: Nix error messages can be verbose. Look for the "error:" lines at the bottom.
- **Option Errors**: "The option `...` does not exist" usually means a typo or the option was renamed/moved in newer NixOS versions. Check `search.nixos.org` for current options.
- **Infinite Recursion**: Usually caused by circular imports or self-referencing definitions without `rec`.

## 7. Specific Rules

- **Do NOT** modify `hardware-configuration.nix` unless explicitly instructed. It is auto-generated.
- **Do NOT** change `system.stateVersion` unless performing a major system upgrade and knowing the implications.
- **Flake Inputs**: Do not add new flake inputs unless the requested software is not available in standard `nixpkgs`.

