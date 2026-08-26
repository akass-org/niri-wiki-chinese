#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# 配置
SYNC_BRANCH="sync-upstream"
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
DOCS_PREFIX="docs"
UPSTREAM_DOCS_BRANCH="upstream-docs"
UPSTREAM_URL="https://github.com/niri-wm/niri.git"

show_help() {
    cat << 'EOF'
用法: ./sync-upstream.sh [选项]

选项:
  -h, --help      显示帮助
  -n, --dry-run   预览变更，不实际执行
  -p, --push      同步后自动推送到 origin

这是 niri-wiki-chinese 的上游同步脚本。
自动从 niri-wm/niri 仓库提取 docs 目录，合并到 wiki/en/。
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

# ===== 前置检查 =====

# 1. wiki 相关文件必须干净（忽略脚本本身的修改）
if ! git diff --quiet -- wiki/ mkdocs.yaml || ! git diff --cached --quiet -- wiki/ mkdocs.yaml; then
    echo "❌ wiki/ 或 mkdocs.yaml 有未提交的更改，请先提交或暂存"
    exit 1
fi

# 检查是否有进行中的合并/rebase
if git rev-parse --verify MERGE_HEAD &>/dev/null 2>&1; then
    echo "❌ 检测到进行中的合并，请先完成或中止 (git merge --abort)"
    exit 1
fi

# 2. 自动添加 upstream remote
if ! git remote get-url "$UPSTREAM_REMOTE" &>/dev/null; then
    echo "🔧 未找到 upstream remote，正在自动添加..."
    run git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
    echo "  已添加: $UPSTREAM_REMOTE -> $UPSTREAM_URL"
fi

# 保存当前分支，结束后切回来
ORIGINAL_BRANCH=$(git branch --show-current)

cleanup() {
    # 如果还在合并中，先中止
    if git rev-parse --verify MERGE_HEAD &>/dev/null 2>&1; then
        echo ""
        echo "⚠️ 检测到未完成的合并，正在中止..."
        git merge --abort || true
    fi
    # 切回原分支
    if [[ -n "${ORIGINAL_BRANCH:-}" && "$ORIGINAL_BRANCH" != "$(git branch --show-current 2>/dev/null || true)" ]]; then
        echo ""
        echo "↩️ 切回原来的分支: $ORIGINAL_BRANCH"
        git switch "$ORIGINAL_BRANCH" || true
    fi
}
trap cleanup EXIT

echo "=== 同步上游文档 ==="
echo "Upstream: $UPSTREAM_REMOTE/$UPSTREAM_BRANCH"
echo ""

# ===== Step 1: 抓取上游 =====
echo "[1/6] 抓取 $UPSTREAM_REMOTE/$UPSTREAM_BRANCH..."

run git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"
run git lfs fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH" 2>/dev/null || true

# sync-upstream 只是记录"上次同步到上游哪里"的书签，用 branch -f 更新即可，
# 无需 checkout（checkout 会要求整个工作区干净，比如本脚本自己不能有改动）。
if [[ "$(git branch --show-current)" == "$SYNC_BRANCH" ]]; then
    run git switch main
fi
run git branch -f "$SYNC_BRANCH" "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"

# ===== Step 2: subtree split =====
echo ""
echo "[2/6] 提取 docs 目录到 $UPSTREAM_DOCS_BRANCH..."
# 直接对 upstream/main 做 split，不切换分支；
# 不用 --rejoin：rejoin 会在当前分支上留下合并提交，污染历史且没有任何收益。
run git subtree split --prefix="$DOCS_PREFIX" -b "$UPSTREAM_DOCS_BRANCH" "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"

# ===== Step 3: 合并到 main =====
echo ""
echo "[3/6] 合并 $UPSTREAM_DOCS_BRANCH 到 main..."
run git switch main

PRE_MERGE_HEAD=$(git rev-parse HEAD)

# 判断是否为首次合并（两个分支是否有共同祖先）
if git merge-base "$UPSTREAM_DOCS_BRANCH" HEAD >/dev/null 2>&1; then
    IS_FIRST_MERGE=false
    MERGE_MSG="chore: sync upstream docs"
else
    IS_FIRST_MERGE=true
    MERGE_MSG="chore: init upstream docs sync"
fi

# 执行合并，允许失败（冲突）
MERGE_OK=true
if $IS_FIRST_MERGE; then
    echo "  首次合并 upstream-docs，使用 --allow-unrelated-histories"
    run git merge --allow-unrelated-histories --no-ff "$UPSTREAM_DOCS_BRANCH" \
        -m "$MERGE_MSG" || MERGE_OK=false
else
    run git merge --no-ff "$UPSTREAM_DOCS_BRANCH" \
        -m "$MERGE_MSG" || MERGE_OK=false
fi

# 处理合并冲突
if ! $MERGE_OK; then
    mapfile -t CONFLICTED < <(git diff --name-only --diff-filter=U 2>/dev/null || true)

    if [ ${#CONFLICTED[@]} -eq 0 ]; then
        echo "❌ 合并失败但未检测到冲突文件，请手动检查"
        exit 1
    fi

    echo ""
    echo "🔧 检测到合并冲突，正在自动解决..."

    for f in "${CONFLICTED[@]}"; do
        if [ "$f" = "mkdocs.yaml" ]; then
            echo "  解决: $f -> 保留本地版本（含 zh/en 导航结构）"
            git checkout --ours "$f"
            git add "$f"
        elif [[ "$f" == wiki/img/*.png ]]; then
            # Shared documentation images are owned by upstream; their branch is canonical.
            echo "  解决: $f -> 采用上游版本"
            git checkout --theirs "$f"
            git add "$f"
        elif [[ "$f" == wiki/en/*.md && ! -f "$f" ]]; then
            # rename/delete 冲突：上游删除了该页面，本地此前把它移到了 wiki/en/，跟随上游删除
            echo "  解决: $f -> 上游已删除该页面，跟随删除"
            git rm -q -f "$f"
        else
            echo "❌ 无法自动解决冲突: $f"
            echo "  请手动处理后运行: git add $f && git commit"
            echo "  或中止: git merge --abort"
            exit 1
        fi
    done

    # 完成合并提交
    git commit --no-edit
    echo "  冲突已自动解决，合并完成 ✅"
fi

POST_MERGE_HEAD=$(git rev-parse HEAD)

# ===== Step 4: 分析变更 =====
echo ""
echo "[4/6] 分析上游变更..."

# 注意：合并时 git 的重命名检测会自动把上游对 wiki/X.md 的修改/删除
# 应用到本地的 wiki/en/X.md（因为之前已移动过）。所以变更既可能落在
# wiki/en/（已就位，无需移动），也可能落在 wiki/ 根目录（上游全新页面，
# 本地无对应文件，需要手动移入 wiki/en/）。
mapfile -t CHANGES < <(git diff --name-status "$PRE_MERGE_HEAD" "$POST_MERGE_HEAD" -- "wiki/*.md" 2>/dev/null | grep -P '^[AMD]\twiki/(en/)?[^/]+\.md$' || true)

if [ ${#CHANGES[@]} -eq 0 ]; then
    if git diff --quiet "$PRE_MERGE_HEAD" "$POST_MERGE_HEAD" 2>/dev/null; then
        echo "  ℹ️ 上游没有新变更，无需同步"
        exit 0
    fi
    echo "  ℹ️ 没有 wiki 页面变更（可能有图片/配置等其他变更），继续后续检查"
fi

if [ ${#CHANGES[@]} -gt 0 ]; then
    echo "  检测到 ${#CHANGES[@]} 个文件变更:"
    for line in "${CHANGES[@]}"; do
        echo "    $line"
    done
fi

ADDED=()
MODIFIED=()
DELETED=()

for line in "${CHANGES[@]}"; do
    status=${line:0:1}
    file=${line:2}

    case "$status" in
        A)
            ADDED+=("$file")
            ;;
        M)
            MODIFIED+=("$file")
            ;;
        D)
            DELETED+=("$file")
            ;;
        *)
            echo "  ⚠️ 未知状态: $line"
            ;;
    esac
done

# 显示分类摘要
echo ""
echo "  📊 上游变更摘要:"
echo "     ┌──────────┬──────┐"
printf "     │ 新增      │ %4d │\n" ${#ADDED[@]}
printf "     │ 修改      │ %4d │\n" ${#MODIFIED[@]}
printf "     │ 删除      │ %4d │\n" ${#DELETED[@]}
echo "     └──────────┴──────┘"

if [ ${#ADDED[@]} -gt 0 ]; then
    echo ""
    echo "  ✚ 新增文件:"
    for f in "${ADDED[@]}"; do
        echo "    - $(basename "$f")"
    done
fi
if [ ${#MODIFIED[@]} -gt 0 ]; then
    echo ""
    echo "  ✎ 修改文件:"
    for f in "${MODIFIED[@]}"; do
        echo "    - $(basename "$f")"
    done
fi
if [ ${#DELETED[@]} -gt 0 ]; then
    echo ""
    echo "  ✕ 上游删除:"
    for f in "${DELETED[@]}"; do
        echo "    - $(basename "$f")"
    done
fi

# 合并 新增+修改 用于后续移动
ADDED_MODIFIED=("${ADDED[@]}" "${MODIFIED[@]}")

# ===== Step 5: 移动文件到 wiki/en/ =====
echo ""
echo "[5/6] 移动文件到 wiki/en/..."

mkdir -p wiki/en

moved=0
skipped=0
warnings=0

for file in "${ADDED_MODIFIED[@]}"; do
    base=$(basename "$file")
    target="wiki/en/$base"

    # 合并的重命名检测已把变更直接落到 wiki/en/，无需移动
    if [[ "$file" == wiki/en/* ]]; then
        echo "  已同步: $file"
        moved=$((moved + 1))
        continue
    fi

    # 安全检查 1: 文件是否存在
    if [ ! -f "$file" ]; then
        echo "  ⚠️ 跳过 (文件不存在): $file"
        skipped=$((skipped + 1))
        continue
    fi

    # 安全检查 2: 检测中文文件（防止误移）
    CN_CHARS=$(grep -oP '[\x{4e00}-\x{9fff}]' "$file" 2>/dev/null | wc -l | tr -d '[:space:]') || true
    CN_CHARS=${CN_CHARS:-0}

    if [ "$CN_CHARS" -gt 50 ]; then
        echo "  ⚠️ 警告: $file 包含 $CN_CHARS 个中文字符，可能是中文翻译！"
        echo "     已跳过，请手动确认。"
        warnings=$((warnings + 1))
        skipped=$((skipped + 1))
        continue
    fi

    # 安全检查 3: 对比提示
    if [ -f "$target" ]; then
        DIFF_LINES=$(git diff --no-index --stat "$target" "$file" 2>/dev/null | tail -1 | grep -oP '\d+' | head -1 || echo "?")
        echo "  覆盖: $file -> $target (差异约 $DIFF_LINES 行)"
    else
        echo "  新增: $file -> $target"
    fi

    if ! $DRY_RUN; then
        mv "$file" "$target"
    fi
    moved=$((moved + 1))
done

# 处理上游删除
if [ ${#DELETED[@]} -gt 0 ]; then
    echo ""
    echo "  上游删除了以下文件，请检查 wiki/en/ 是否需要同步删除:"
    for file in "${DELETED[@]}"; do
        base=$(basename "$file")
        if [ -f "wiki/en/$base" ]; then
            echo "    - wiki/en/$base (上游已删除，本地仍保留)"
        fi
    done
fi

# 检查 wiki/ 根目录残留
for file in wiki/*.md; do
    [ -e "$file" ] || continue
    base=$(basename "$file")
    echo ""
    echo "  ⚠️ 残留文件: $file 未被变更列表覆盖，但仍存在于 wiki/ 根目录"
    echo "     请手动处理。"
    warnings=$((warnings + 1))
done

# 处理 Git LFS 图片（上游用 LFS 存储图片，subtree 同步过来的是指针文件）
echo ""
echo "  检查 Git LFS 图片..."
lfs_fixed=0
for img in wiki/img/*.png; do
    [ -e "$img" ] || continue
    # 检测是否为 LFS 指针文件
    if head -c 10 "$img" 2>/dev/null | grep -q 'version'; then
        OID=$(grep 'oid' "$img" 2>/dev/null | cut -d: -f2 | tr -d ' ')
        OID_PATH=$(echo "$OID" | sed 's/^sha256://')
        OBJ=".git/lfs/objects/${OID_PATH:0:2}/${OID_PATH:2:2}/$OID_PATH"

        if [ -f "$OBJ" ]; then
            if ! $DRY_RUN; then
                cp "$OBJ" "$img"
            fi
            lfs_fixed=$((lfs_fixed + 1))
        else
            # 尝试从 upstream 拉取 LFS 对象
            echo "  拉取 LFS 对象: $OID (from upstream)"
            if ! $DRY_RUN; then
                git lfs fetch "$UPSTREAM_REMOTE" --all 2>/dev/null || true
                if [ -f "$OBJ" ]; then
                    cp "$OBJ" "$img"
                    lfs_fixed=$((lfs_fixed + 1))
                else
                    echo "  ⚠️ 无法获取 LFS 对象: $(basename "$img")"
                fi
            fi
        fi
    fi
done
if [ "$lfs_fixed" -gt 0 ]; then
    echo "  已还原 $lfs_fixed 个 LFS 图片文件"
fi

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
echo "  📊 上游变更摘要:"
echo "     ┌──────────────────┬──────┐"
printf "     │ 新增文件          │ %4d │\n" ${#ADDED[@]}
printf "     │ 修改文件          │ %4d │\n" ${#MODIFIED[@]}
printf "     │ 删除文件          │ %4d │\n" ${#DELETED[@]}
echo "     ├──────────────────┼──────┤"
printf "     │ 已同步到 wiki/en/ │ %4d │\n" $moved
printf "     │ 跳过              │ %4d │\n" $skipped
echo "     └──────────────────┴──────┘"
echo "  wiki/zh/:  完全未动"
if [ "$warnings" -gt 0 ]; then
    echo ""
    echo "  ⚠️ 警告: $warnings 个（详见上方日志）"
fi

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
