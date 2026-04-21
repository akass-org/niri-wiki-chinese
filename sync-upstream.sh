#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "=== Syncing upstream docs ==="

# Step 1: 从上游提取 docs 目录（你原来的命令）
echo "[1/4] Running git subtree split..."
git subtree split --prefix=docs --rejoin -b upstream-docs

# Step 2: 合并上游文档到当前分支
echo "[2/4] Merging upstream-docs into current branch..."
git merge upstream-docs -m "sync: merge upstream docs"

# Step 3: 把上游同步过来的 wiki/*.md 移动到 wiki/en/
# upstream-docs 带来的英文 .md 文件在 wiki/ 根目录下
# 我们的中文文件在 wiki/zh/，不受影响
echo "[3/4] Moving upstream .md files to wiki/en/..."
mkdir -p wiki/en

moved_count=0
for file in wiki/*.md; do
    [ -e "$file" ] || continue
    base=$(basename "$file")
    
    # 移动到 wiki/en/
    mv "$file" "wiki/en/$base"
    moved_count=$((moved_count + 1))
    echo "  -> wiki/en/$base"
done

if [ "$moved_count" -eq 0 ]; then
    echo "  (no new .md files to move)"
fi

# Step 4: 提交整理
echo "[4/4] Committing..."
git add -A
git commit -m "chore: move upstream docs to wiki/en/"

echo "=== Done! ==="
echo ""
echo "Summary:"
echo "  - upstream-docs branch updated"
echo "  - Merged into $(git branch --show-current)"
echo "  - $moved_count file(s) moved to wiki/en/"
echo "  - wiki/zh/ was NOT touched"
