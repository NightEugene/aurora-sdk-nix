{
  config,
  lib,
  pkgs,
  ...
}:

let
  aurora-sdk = pkgs.callPackage ../../pkgs/aurora-sdk { };

  patch-tools = pkgs.writeShellScript "aurora-sdk-patch-tools" ''
    AURORA_SDK_DIR="''${AURORA_SDK_DIR:-$HOME/.local/share/aurora-sdk}"
    PATH_FIX_MARKER="# AURORA_SDK_PATH_FIX"
    PATH_FIX_EXPORT='export PATH="/run/wrappers/bin:/usr/bin:/usr/sbin:/run/current-system/sw/bin:$PATH"'

    for script in \
      "$AURORA_SDK_DIR/sdk/5.2.1.200/tools/apptool" \
      "$AURORA_SDK_DIR/sdk/5.2.1.200/tools/qmake-aarch64" \
      "$AURORA_SDK_DIR/sdk/5.2.1.200/tools/qmake-armv7hl" \
      "$AURORA_SDK_DIR/sdk/5.2.1.200/tools/qmake-x86_64" \
      "$AURORA_SDK_DIR/sdk/5.2.1.200/tools/cmake-aarch64" \
      "$AURORA_SDK_DIR/sdk/5.2.1.200/tools/cmake-armv7hl" \
      "$AURORA_SDK_DIR/sdk/5.2.1.200/tools/cmake-x86_64"
    do
      if [ -f "$script" ] && ! grep -qF "$PATH_FIX_MARKER" "$script" 2>/dev/null; then
        tmp=$(mktemp)
        {
          head -n 1 "$script"
          echo "$PATH_FIX_MARKER"
          echo "$PATH_FIX_EXPORT"
          tail -n +2 "$script"
        } > "$tmp"
        chmod +x "$tmp"
        mv "$tmp" "$script"
      fi
    done
  '';
in
{
  options.programs.aurora-sdk = {
    enable = lib.mkEnableOption "Aurora SDK";
    package = lib.mkPackageOption pkgs "aurora-sdk" { default = aurora-sdk; };
  };

  config = lib.mkIf config.programs.aurora-sdk.enable {
    home.packages = [ config.programs.aurora-sdk.package ];

    # Патчим уже установленные скрипты SDK при активации home-manager.
    home.activation.patchAuroraSdkTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${patch-tools}
    '';
  };
}
