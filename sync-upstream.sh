#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# 配置
SYNC_BRANCH="sync-upstream"
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
DOCS_PREFIX="docs"
UPSTREAM_DOCS_BRANCH="upstream-docs"

show_help() {
    cat << 'EOF'
用法: ./sync-upstream.sh [选项]

选项:
  -h, --help      显示帮助
  -n, --dry-run   预览变更，不实际执行
  -p, --push      同步后自动推送到 origin

这是 niri-wiki-chinese 的上游同步脚本。
它会：
  1. 更新 sync-upstream 分支到 upstream/main
  2. git subtree split 提取 docs 目录
  3. 合并到 main
  4. 把上游的 wiki/*.md 移动到 wiki/en/
  5. 自动提交整理

前置条件：
  - 已配置 upstream remote 指向 https://github.com/niri-wm/niri.git
  - 当前在 main 或 sync-upstream 分支
EOF
}

DRY_RUN=false
AUTO_PUSH=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        -p|--push) AUTO_PUSH=true; shift ;;
        *) echo "未知选项: $1"; show_help; exit 1 ;;
    esac
done

run() {
    if $DRY_RUN; then
        echo "[DRY-RUN] $*"
    else
        echo "[EXEC] $*"
        "$@"
    fi
}

# 检查 upstream remote
if ! git remote get-url "$UPSTREAM_REMOTE" &>/dev/null; then
    echo "错误: 未找到 upstream remote"
    echo "请添加: git remote add upstream https://github.com/niri-wm/niri.git"
    exit 1
fi

# 保存当前分支，结束后切回来
ORIGINAL_BRANCH=$(git branch --show-current)

cleanup() {
    if [[ -n "${ORIGINAL_BRANCH:-}" && "$ORIGINAL_BRANCH" != "$(git branch --show-current)" ]]; then
        echo ""
        echo "切回原来的分支: $ORIGINAL_BRANCH"
        git switch "$ORIGINAL_BRANCH" || true
    fi
}
trap cleanup EXIT

echo "=== 同步上游文档 ==="
echo "Upstream: $UPSTREAM_REMOTE/$UPSTREAM_BRANCH"
echo "Docs prefix: $DOCS_PREFIX"
echo ""

# ===== Step 1: 确保 sync-upstream 分支存在并更新 =====
echo "[1/5] 更新 $SYNC_BRANCH 分支..."

if ! git show-ref --verify --quiet "refs/heads/$SYNC_BRANCH"; then
    echo "  首次运行: 创建 $SYNC_BRANCH 分支跟踪 upstream/main"
    run git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"
    run git switch -C "$SYNC_BRANCH" "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"
else
    run git switch "$SYNC_BRANCH"
    run git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"
    if ! run git merge --ff-only "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"; then
        echo ""
        echo "警告: $SYNC_BRANCH 无法快进合并。"
        echo "可能的原因:"
        echo "  - 你在 $SYNC_BRANCH 上做了额外提交"
        echo "  - upstream 历史被重写"
        echo ""
        echo "建议修复:"
        echo "  git switch $SYNC_BRANCH"
        echo "  git reset --hard $UPSTREAM_REMOTE/$UPSTREAM_BRANCH"
        exit 1
    fi
fi

# ===== Step 2: subtree split =====
echo ""
echo "[2/5] 提取 docs 目录到 $UPSTREAM_DOCS_BRANCH..."
run git subtree split --prefix="$DOCS_PREFIX" --rejoin -b "$UPSTREAM_DOCS_BRANCH"

# ===== Step 3: 合并到 main =====
echo ""
echo "[3/5] 合并 $UPSTREAM_DOCS_BRANCH 到 main..."
run git switch main

# 检查 main 和 upstream-docs 是否有共同历史
if git merge-base --is-ancestor "$UPSTREAM_DOCS_BRANCH" HEAD 2>/dev/null; then
    # 有共同历史，正常合并
    run git merge --no-ff "$UPSTREAM_DOCS_BRANCH" -m "chore: sync upstream docs"
else
    # 首次合并，允许无关历史
    echo "  首次合并 upstream-docs，使用 --allow-unrelated-histories"
    run git merge --allow-unrelated-histories --no-ff "$UPSTREAM_DOCS_BRANCH" -m "chore: init upstream docs sync"
fi

# ===== Step 4: 整理文件到 wiki/en/ =====
echo ""
echo "[4/5] 整理文件: 把 wiki/*.md 移动到 wiki/en/..."

mkdir -p wiki/en

moved=0
for file in wiki/*.md; do
    # 如果没有匹配到文件，bash 会保留字面量 wiki/*.md
    [ -e "$file" ] || continue

    base=$(basename "$file")
    target="wiki/en/$base"

    if $DRY_RUN; then
        echo "  [DRY-RUN] mv $file -> $target"
    else
        mv "$file" "$target"
        echo "  -> $target"
    fi
    moved=$((moved + 1))
done

if [ "$moved" -eq 0 ]; then
    echo "  (没有需要移动的 .md 文件)"
fi

# 检测上游可能删除的旧文件
# 找出 wiki/en/ 中有但上游不再提供的文件
echo ""
echo "  检查残留文件..."
orphan_count=0
for file in wiki/en/*.md; do
    [ -e "$file" ] || continue
    base=$(basename "$file")
    if [ ! -f "wiki/$base" ] && [ ! -f "wiki/zh/$base" ]; then
        # 这个文件在上游已不存在，且中文也没有
        # 但可能中文从未翻译过，所以只提醒
        : # 暂不处理
    fi
done

# ===== Step 5: 提交 =====
echo ""
echo "[5/5] 提交整理..."

if $DRY_RUN; then
    echo "  [DRY-RUN] git add -A && git commit -m 'chore: move upstream docs to wiki/en/'"
else
    # 检查是否有变更需要提交
    if git diff --cached --quiet && git diff --quiet; then
        echo "  没有变更需要提交"
    else
        git add -A
        git commit -m "chore: move upstream docs to wiki/en/" || echo "  提交失败或无需提交"
    fi
fi

# ===== 完成 =====
echo ""
echo "=== 同步完成 ==="
echo ""
echo "统计:"
echo "  移动了 $moved 个文件到 wiki/en/"
echo "  wiki/zh/ 完全未动"
echo ""

if $DRY_RUN; then
    echo "这是 --dry-run 模式，没有实际执行任何操作。"
    echo "去掉 -n 参数来真正执行。"
else
    echo "接下来可以:"
    echo "  1. 预览变更:  git diff HEAD~2 --stat"
    echo "  2. 构建测试:  uv run mkdocs build"
    echo "  3. 推送:       git push origin main"

    if $AUTO_PUSH; then
        echo ""
        echo "[--push] 自动推送到 origin/main..."
        git push origin main
    fi
fi
