{ ... }:

{
  # CONSTRAINT: SSH は services.openssh で有効化しなくてはならない。
  # REASON: systemsetup -setremotelogin は Full Disk Access を要求するため。
  services.openssh.enable = true;

  # CONSTRAINT: sshd は ClientAlive による keepalive を送信しなくてはならない。
  # REASON: 無通信時に経路上の NAT マッピングが失効し broken pipe になるため。
  services.openssh.extraConfig = ''
    ClientAliveInterval 30
    ClientAliveCountMax 4
  '';

  # HACK: 画面共有には nix-darwin のネイティブオプションが無い。
  # openssh モジュールと同じ launchctl パターンを activationScript 化する。
  system.activationScripts.screenSharing.text = ''
    echo "configuring screen sharing..." >&2
    launchctl enable system/com.apple.screensharing
    launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
  '';
}
