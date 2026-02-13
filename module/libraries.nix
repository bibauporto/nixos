{ config, pkgs, ... }:

{
  # 1. envfs: Fixes scripts using #!/usr/bin/env or #!/bin/bash
  services.envfs.enable = true;

  # 2. nix-ld: The bridge for unpatched binaries (LSPs, Mason, etc.)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # --- The Essentials ---
    stdenv.cc.cc.lib    # Standard C++ library
    zlib                # Compression
    fuse3               # Filesystems (AppImages)
    icu                 # Internationalization
    nss                 # Security
    openssl             # Cryptography
    curl                # Networking
    expat               # XML parsing

    # --- Development & Languages ---
    glib                # Core utility
    util-linux          # libuuid
    libxml2             # XML
    libxcrypt           # Password hashing
    libxcrypt-legacy
    libunwind           # Stack unwinding
    libuuid             # UUIDs

    # --- GUI / Graphic Tools (Corrected top-level names) ---
    libglvnd            # OpenGL
    libx11              
    libxcursor          
    libxext             
    libxrender          
    libxrandr          
    libxi               
    libxinerama         
    libxft             
    at-spi2-atk         # Accessibility
    at-spi2-core
    atk
    cairo               # 2D graphics
    pango               # Text layout
    gdk-pixbuf          # Image loading
    gtk3                # Modern GUI apps
    libsecret           # VS Code / GitHub Auth storage
    libcap              # Capabilities
  ];
}
