#!/usr/bin/env bash
# const.sh
#
# nix-darwin スクリプト全体で共有する定数定義。
# このファイルは実行せず、他スクリプトから source して利用する。

# CONSTRAINT: SC2034 の抑制を外してはならない。
# REASON: 定数は source 先でのみ参照され、単体では未使用に見えるため。
# shellcheck disable=SC2034

readonly NIX_DARWIN_FLAKE="github:LnL7/nix-darwin"

readonly DARWIN_CONFIG="homelab-server"

readonly FLAKE_REF=".#${DARWIN_CONFIG}"

# CONSTRAINT: apply はビルド済み result のバイナリを使わなくてはならない。
# REASON: sudo 下で Nix 評価を再実行させないため。
readonly DARWIN_REBUILD_BIN="./result/sw/bin/darwin-rebuild"

readonly GC_KEEP_DURATION="30d"
