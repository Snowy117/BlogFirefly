# 同步上游模板指南

该仓库基于 [CuteLeaf/Firefly](https://github.com/CuteLeaf/Firefly) 模板进行二次开发。为了在继续撰写博文的同时及时获取模板的最新特性，可以借助 `pnpm sync:template` 指令实现半自动同步。

## 运行前准备

1. **添加上游远程仓库（只需执行一次）**
   ```bash
   git remote add upstream https://github.com/CuteLeaf/Firefly.git
   ```
   查看是否生效：
   ```bash
   git remote -v
   ```
   应能看到 `origin`（你自己的仓库）和 `upstream`（官方模板）。

2. **保持工作区整洁**
   在同步之前，优先提交或暂存你正在撰写的文章、配置修改：
   ```bash
   git status
   git add .
   git commit -m "Write new post"
   ```

## 使用脚本同步

```bash
pnpm install      # 首次克隆仓库后需要
pnpm sync:template
```

脚本将依次执行以下动作：

1. 检查是否位于 Git 仓库且工作区干净。
2. `git fetch upstream --tags --prune` 获取模板更新。
3. 检测上游默认分支（通常是 `master`）。
4. 强制更新本地 `upstream-sync` 分支以跟随 `upstream/<default-branch>`。
5. 将 `upstream-sync` 合并进当前分支（一般是 `master`）。

完成后，你可以 `git log --oneline` 或 `git status` 复查，再 `git push origin master` 将结果推送到自己的仓库。

## 遇到合并冲突怎么办？

当脚本提示存在冲突时：

1. 根据 Git 输出逐一编辑冲突文件，保留期望内容。
2. 标记为已解决：
   ```bash
   git add <file>
   ```
3. 继续合并：
   ```bash
   git merge --continue
   ```
4. 确认无误后，推送到自己的远程仓库。

如果暂时不想处理，可执行 `git merge --abort` 回到脚本执行前的状态。

## 建议的日常工作流

1. **写作**：在 `src/content/posts` 中创建或编辑文章，可继续使用 `pnpm new-post` 脚本。
2. **提交**：每篇文章或配置修改建议独立提交，方便回滚。
3. **同步模板**：定期运行 `pnpm sync:template`，解决潜在冲突。
4. **上线**：`pnpm build` / `pnpm preview` 验证后推送并部署。

通过该流程可以长期保持与模板同步，同时不会影响你自己的内容创作。