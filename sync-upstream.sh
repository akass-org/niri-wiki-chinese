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

前置条件：
  - 已配置 upstream remote 指向 https://github.com/niri-wm/niri.git
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
echo ""

# ===== Step 1: 确保 sync-upstream 分支存在并更新 =====
echo "[1/6] 更新 $SYNC_BRANCH 分支..."

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
        echo "建议修复:"
        echo "  git switch $SYNC_BRANCH"
        echo "  git reset --hard $UPSTREAM_REMOTE/$UPSTREAM_BRANCH"
        exit 1
    fi
fi

# ===== Step 2: subtree split =====
echo ""
echo "[2/6] 提取 docs 目录到 $UPSTREAM_DOCS_BRANCH..."
run git subtree split --prefix="$DOCS_PREFIX" --rejoin -b "$UPSTREAM_DOCS_BRANCH"

# ===== Step 3: 合并到 main =====
echo ""
echo "[3/6] 合并 $UPSTREAM_DOCS_BRANCH 到 main..."
run git switch main

# 记录合并前的 HEAD，用于后续 diff
PRE_MERGE_HEAD=$(git rev-parse HEAD)

if git merge-base --is-ancestor "$UPSTREAM_DOCS_BRANCH" HEAD 2>/dev/null; then
    run git merge --no-ff "$UPSTREAM_DOCS_BRANCH" -m "chore: sync upstream docs"
else
    echo "  首次合并 upstream-docs，使用 --allow-unrelated-histories"
    run git merge --allow-unrelated-histories --no-ff "$UPSTREAM_DOCS_BRANCH" -m "chore: init upstream docs sync"
fi

POST_MERGE_HEAD=$(git rev-parse HEAD)

# ===== Step 4: 分析合并带来的变更 =====
echo ""
echo "[4/6] 分析上游变更..."

# 获取 wiki/*.md 的变更列表
mapfile -t CHANGES < <(git diff --name-status "$PRE_MERGE_HEAD" "$POST_MERGE_HEAD" -- "wiki/*.md" 2>/dev/null || true)

if [ ${#CHANGES[@]} -eq 0 ]; then
    echo "  没有检测到 wiki/*.md 的变更"
else
    echo "  检测到 ${#CHANGES[@]} 个文件变更:"
    for line in "${CHANGES[@]}"; do
        echo "    $line"
    done
fi

# 分类处理
ADDED_MODIFIED=()
DELETED=()

for line in "${CHANGES[@]}"; do
    status=${line:0:1}
    file=${line:2}
    
    case "$status" in
        A|M)
            ADDED_MODIFIED+=("$file")
            ;;
        D)
            DELETED+=("$file")
            ;;
        *)
            echo "  未知状态: $line"
            ;;
    esac
done

# ===== Step 5: 安全检查并移动文件 =====
echo ""
echo "[5/6] 安全检查并移动文件到 wiki/en/..."

mkdir -p wiki/en

moved=0
skipped=0
warnings=0

for file in "${ADDED_MODIFIED[@]}"; do
    base=$(basename "$file")
    target="wiki/en/$base"
    
    # 安全检查 1: 文件是否存在
    if [ ! -f "$file" ]; then
        echo "  ⚠️ 跳过 (文件不存在): $file"
        skipped=$((skipped + 1))
        continue
    fi
    
    # 安全检查 2: 检测是否包含大量中文（防止误移中文文件）
    # 统计中文字符数量
    CN_CHARS=$(grep -oP '[\x{4e00}-\x{9fff}]' "$file" 2>/dev/null | wc -l || echo 0)
    TOTAL_CHARS=$(wc -m < "$file" | tr -d ' ')
    
    if [ "$CN_CHARS" -gt 50 ]; then
        echo "  ⚠️ 警告: $file 包含 $CN_CHARS 个中文字符，可能是中文文件！"
        echo "     已跳过，请手动确认。"
        warnings=$((warnings + 1))
        skipped=$((skipped + 1))
        continue
    fi
    
    # 安全检查 3: 对比提示（如果目标已存在）
    if [ -f "$target" ]; then
        # 计算差异行数
        DIFF_LINES=$(git diff --stat "$target" "$file" 2>/dev/null | tail -1 | grep -oP '\d+' | tail -1 || echo "?")
        echo "  覆盖: $file -> $target (差异约 $DIFF_LINES 行)"
    else
        echo "  新增: $file -> $target"
    fi
    
    if ! $DRY_RUN; then
        mv "$file" "$target"
    fi
    moved=$((moved + 1))
done

# 处理上游删除的文件：提醒用户检查 wiki/en/ 中的残留
if [ ${#DELETED[@]} -gt 0 ]; then
    echo ""
    echo "  上游删除了以下文件，请检查 wiki/en/ 中是否需要同步删除:"
    for file in "${DELETED[@]}"; do
        base=$(basename "$file")
        if [ -f "wiki/en/$base" ]; then
            echo "    - wiki/en/$base (上游已删除，但本地仍保留)"
        fi
    done
fi

# 额外检查：合并后是否有残留的 wiki/*.md 未被处理（异常情况）
for file in wiki/*.md; do
    [ -e "$file" ] || continue
    base=$(basename "$file")
    echo ""
    echo "  ⚠️ 异常: $file 未被变更列表捕获，但仍存在于 wiki/ 根目录"
    echo "     这可能是一个意外文件，请手动检查。"
    warnings=$((warnings + 1))
done

# ===== Step 6: 提交 =====
echo ""
echo "[6/6] 提交整理..."

if $DRY_RUN; then
    echo "  [DRY-RUN] git add -A && git commit -m 'chore: move upstream docs to wiki/en/'"
else
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
echo "  移动/覆盖: $moved 个文件"
echo "  跳过:     $skipped 个文件"
if [ "$warnings" -gt 0 ]; then
    echo "  ⚠️ 警告:   $warnings 个"
fi
if [ ${#DELETED[@]} -gt 0 ]; then
    echo "  上游删除: ${#DELETED[@]} 个文件（请检查 wiki/en/ 残留）"
fi
echo "  wiki/zh/:  完全未动"
echo ""

if $DRY_RUN; then
    echo "这是 --dry-run 模式，没有实际执行任何操作。"
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
