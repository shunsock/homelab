{ ... }:

{
  # CONSTRAINT: メジャー OS 更新の自動適用は無効でなくてはならない。
  # REASON: 無人再起動が常時稼働のサーバー運用を妨げるため。
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

  # CONSTRAINT: セキュリティ更新は CustomSystemPreferences で書かなくてはならない。
  # REASON: nix-darwin にこれらのキーのネイティブオプションが無いため。
  system.defaults.CustomSystemPreferences."/Library/Preferences/com.apple.SoftwareUpdate" = {
    AutomaticCheckEnabled = true;
    AutomaticDownload = true;
    CriticalUpdateInstall = true;
    ConfigDataInstall = true;
  };
}
