#!/bin/bash
# ============================================================
#  sync.sh  —  出退室管理システム GitHub 同期スクリプト
#
#  使い方:
#    ./sync.sh              # 変更をコミット＆プッシュ
#    ./sync.sh "メッセージ"  # コミットメッセージを指定
#
#  初回セットアップ:
#    1. このファイルに実行権限を付与
#       chmod +x sync.sh
#    2. REPO_DIR を自分の作業ディレクトリに変更
#    3. ./sync.sh を実行
# ============================================================

# ===== ★ 設定（ここだけ変更してください） =====
REPO_DIR="/Users/masashiina/CodingDirectory/QR"   # リポジトリのパス
BRANCH="main"                                       # ブランチ名
# ================================================

# --- 色定義 ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${CYAN}${BOLD}==============================${RESET}"
echo -e "${CYAN}${BOLD}  GitHub 同期スクリプト${RESET}"
echo -e "${CYAN}${BOLD}==============================${RESET}"

# --- ディレクトリ移動 ---
cd "$REPO_DIR" || { echo -e "${RED}❌ ディレクトリが見つかりません: $REPO_DIR${RESET}"; exit 1; }
echo -e "${GREEN}📁 作業ディレクトリ: $(pwd)${RESET}"

# --- git リポジトリ確認 ---
if [ ! -d ".git" ]; then
  echo -e "${YELLOW}⚠️  Gitリポジトリが見つかりません。初期化しますか？ [y/N]${RESET}"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    git init
    echo -e "${GREEN}✅ git init 完了${RESET}"
  else
    echo -e "${RED}❌ 中止しました${RESET}"; exit 1
  fi
fi

# --- 変更確認 ---
if git diff --quiet && git diff --cached --quiet && [ -z "$(git status --porcelain)" ]; then
  echo -e "${YELLOW}ℹ️  変更はありません。プッシュをスキップします。${RESET}"
  exit 0
fi

# --- 変更ファイルを表示 ---
echo -e "\n${BOLD}変更ファイル:${RESET}"
git status --short

# --- git add ---
git add .
echo -e "\n${GREEN}✅ git add .${RESET}"

# --- コミットメッセージ ---
if [ -n "$1" ]; then
  MSG="$1"
else
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  MSG="更新: ${TIMESTAMP}"
fi

# --- git commit ---
git commit -m "$MSG"
echo -e "${GREEN}✅ git commit: \"${MSG}\"${RESET}"

# --- git push ---
echo -e "\n${CYAN}🚀 プッシュ中... (branch: ${BRANCH})${RESET}"
if git push origin "$BRANCH"; then
  echo -e "\n${GREEN}${BOLD}✅ 同期完了！${RESET}"
  echo -e "${GREEN}🌐 GitHub Pages: https://$(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/\.git$//' | awk -F'/' '{print $1".github.io/"$2}')${RESET}"
else
  echo -e "\n${RED}❌ プッシュに失敗しました。${RESET}"
  echo -e "${YELLOW}以下を確認してください:${RESET}"
  echo -e "  - インターネット接続"
  echo -e "  - GitHub の認証情報（Personal Access Token）"
  echo -e "  - リモートリポジトリが存在するか: git remote -v"
  exit 1
fi
