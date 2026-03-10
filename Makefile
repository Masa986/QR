# ============================================================
#  Makefile  —  出退室管理システム 操作コマンド集
#
#  使い方（ターミナルで実行）:
#    make          # = make push（デフォルト）
#    make push     # コミット＆プッシュ
#    make msg="メッセージ" push   # メッセージ指定でプッシュ
#    make status   # git の状態を確認
#    make log      # 直近10件のコミット履歴を表示
#    make open     # GitHub Pages をブラウザで開く
#    make setup    # 初回セットアップ
# ============================================================

# ===== ★ 設定（ここだけ変更してください） =====
REPO_DIR  := /Users/masashiina/CodingDirectory/QR
BRANCH    := main
msg       ?= 更新: $(shell date '+%Y-%m-%d %H:%M:%S')
# ================================================

.DEFAULT_GOAL := push
.PHONY: push status log open setup help

## デフォルト: コミット＆プッシュ
push:
	@cd "$(REPO_DIR)" && \
	if git diff --quiet && git diff --cached --quiet && [ -z "$$(git status --porcelain)" ]; then \
		echo "ℹ️  変更はありません"; \
	else \
		git add . && \
		git commit -m "$(msg)" && \
		git push origin $(BRANCH) && \
		echo "✅ 同期完了: $(msg)"; \
	fi

## git の状態確認
status:
	@cd "$(REPO_DIR)" && git status

## 直近10件のコミット履歴
log:
	@cd "$(REPO_DIR)" && git log --oneline -10

## GitHub Pages をブラウザで開く
open:
	@REMOTE=$$(cd "$(REPO_DIR)" && git remote get-url origin 2>/dev/null); \
	PAGE=$$(echo "$$REMOTE" | sed 's/.*github\.com[:/]//' | sed 's/\.git$$//' | awk -F'/' '{print "https://"$$1".github.io/"$$2}'); \
	echo "🌐 開く: $$PAGE"; \
	open "$$PAGE" 2>/dev/null || xdg-open "$$PAGE" 2>/dev/null || echo "手動で開いてください: $$PAGE"

## 初回セットアップ（リモート登録）
setup:
	@echo "GitHubリポジトリのURLを入力してください:"
	@echo "例: https://github.com/masashiina/QR.git"
	@read -p "URL: " url; \
	cd "$(REPO_DIR)" && \
	git init && \
	git remote remove origin 2>/dev/null; \
	git remote add origin "$$url" && \
	git add . && \
	git commit -m "初回コミット" && \
	git branch -M $(BRANCH) && \
	git push -u origin $(BRANCH) && \
	echo "✅ セットアップ完了"

## ヘルプ
help:
	@echo ""
	@echo "使用可能なコマンド:"
	@echo "  make              コミット＆プッシュ（デフォルト）"
	@echo "  make msg=\"説明\" push  メッセージ指定でプッシュ"
	@echo "  make status       変更ファイルを確認"
	@echo "  make log          コミット履歴を表示"
	@echo "  make open         GitHub Pages をブラウザで開く"
	@echo "  make setup        初回セットアップ"
	@echo ""
