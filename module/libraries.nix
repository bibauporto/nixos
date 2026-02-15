{ pkgs, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # --- Core System & Hardware ---
    openssl
    zlib
    glibc
    icu
    udev # Hardware access (webcam/keyboard)
    libusb1
    libuuid
    libdrm
    mesa # Essential for 3D/Webgl
    libgbm

    # --- Video & Audio Acceleration ---
    libGL
    libglvnd
    libva # Hardware video decoding (saves CPU)
    pipewire # Modern audio/screen sharing
    libpulseaudio
    alsa-lib

    # --- UI & Graphics Stack ---
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups # Required by many Electron apps to launch
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libnotify
    pango

    # --- Browser/Electron Security & WebEngine ---
    nspr
    nss
    libappindicator-gtk3

    # --- X11 & Wayland Libraries (Corrected Names) ---
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libxkbfile
    libxshmfence
    libxcb
    libxkbcommon
  ];
}
