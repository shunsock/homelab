{ ... }:

{
  # CONSTRAINT: bash 側でも starship を有効化しなくてはならない。
  # REASON: nix develop のシェルが bash であるため。
  programs.bash = {
    enable = true;
    initExtra = ''
      shopt -s autocd
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      aws.disabled = true;
      gcloud.disabled = true;
    };
  };
}
