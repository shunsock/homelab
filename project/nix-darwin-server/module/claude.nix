{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.file.".claude/CLAUDE.md".source = ../config/claude/CLAUDE.md;
  home.file.".claude/agents" = {
    source = ../config/claude/agents;
    recursive = true;
  };
  home.file.".claude/skills" = {
    source = ../config/claude/skills;
    recursive = true;
  };
  home.file.".claude/rules" = {
    source = ../config/claude/rules;
    recursive = true;
  };
  home.file.".claude/cli" = {
    source = ../config/claude/cli;
    recursive = true;
  };
  # CONSTRAINT: settings.json は Claude Code が実行時に書き込むため symlink 不可
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm644 ${../config/claude/settings.json} $HOME/.claude/settings.json
  '';

  # CONSTRAINT: keybindings.json は /keybindings コマンドが実行時に書き込むため symlink 不可
  home.activation.claudeKeybindings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm644 ${../config/claude/keybindings.json} $HOME/.claude/keybindings.json
  '';

  home.activation.claudeStatusline = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm755 ${../config/claude/statusline.sh} $HOME/.claude/statusline.sh
  '';

  home.activation.claudeHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.claude/hooks
    run install -Dm644 ${../config/claude/hooks/validate_bash.cs} $HOME/.claude/hooks/validate_bash.cs
    run install -Dm644 ${../config/claude/hooks/pr_submission_via_skill.cs} $HOME/.claude/hooks/pr_submission_via_skill.cs
    run install -Dm644 ${../config/claude/hooks/trigger_ci_fix.cs} $HOME/.claude/hooks/trigger_ci_fix.cs
    run install -Dm644 ${../config/claude/hooks/require_tasks.cs} $HOME/.claude/hooks/require_tasks.cs
    run install -Dm644 ${../config/claude/hooks/block_stop_on_open_tasks.cs} $HOME/.claude/hooks/block_stop_on_open_tasks.cs
    run install -Dm644 ${../config/claude/hooks/write_structured_comment.cs} $HOME/.claude/hooks/write_structured_comment.cs
    run install -Dm644 ${../config/claude/hooks/clean_comment_out.cs} $HOME/.claude/hooks/clean_comment_out.cs
    run install -Dm644 ${../config/claude/hooks/validate_comment_format.cs} $HOME/.claude/hooks/validate_comment_format.cs
    run install -Dm644 ${../config/claude/hooks/validate_japanese_stop_word.cs} $HOME/.claude/hooks/validate_japanese_stop_word.cs
  '';
}
