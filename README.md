
# 使用大语言模型自动进行CodeReview

## 功能简介

本工具通过 Git Hook 自动调用智谱大语言模型进行代码评审，并将评审结果保存为 Markdown 格式的文件。脚本支持在代码提交时自动运行，并为开发团队提供即时反馈。

## 功能特点

- **自动化代码评审**：在代码提交时，脚本自动调用智谱大预言模型，进行全面的代码评审。
- **保存评审结果**：评审结果以 Markdown 格式保存到指定目录中。
- **易于集成**：脚本可轻松集成到 Git 的预提交（pre-commit）钩子中，实现无缝代码检查。

## 前提条件

- 已安装 Git。
- 拥有智谱大预言模型的 API 密钥。
- 需要在脚本中使用 `jq` 工具来处理 JSON 数据。

## 安装 `jq` 工具

### 在 macOS 上安装 `jq`

打开终端，使用 Homebrew 包管理器安装 `jq`，运行以下命令：

```sh
brew install jq
```

## 脚本使用步骤

1. **保存脚本**：将脚本内容复制并保存为 Git 项目中的 `.git/hooks/pre-commit` 文件。
2. **赋予脚本权限**（仅适用于 macOS 和 Linux）：

   ```sh
   chmod +x .git/hooks/pre-commit
   ```

3. **配置 API 密钥**：在脚本中，将 `apiKeySecret` 替换为您的智谱大预言 API 密钥。
4. **提交代码**：当您执行 `git commit` 时，脚本将自动运行，并调用智谱大预言进行代码评审。评审结果将保存在 `codeReviewLog` 目录下的 Markdown 文件中。

## 脚本说明

- **原始响应文件**：保存智谱大预言模型的原始 JSON 响应，文件名为 `originalFilename_时间戳.json`。
- **评审结果文件**：格式化后的评审结果将保存为 Markdown 格式的文件，文件名为 `codeReviewResult_时间戳.md`。
- **日志目录**：所有生成的日志文件都会保存在 `codeReviewLog` 目录中。

## 注意事项

- 确保您的 API 密钥安全，不要泄露给他人。
- 在使用脚本前，请确认您的项目中已正确配置 Git，并确保 pre-commit 脚本在 `.git/hooks/` 目录下且具有执行权限。

## 常见问题

**Q:** 为什么在提交时没有看到代码评审结果？
**A:** 请检查 pre-commit 脚本是否正确放置在 `.git/hooks` 目录下，并且具有执行权限。

**Q:** 如何处理脚本执行失败的情况？
**A:** 检查脚本输出的错误信息，确保您的网络环境可以访问智谱大预言模型的 API，并且 `jq` 工具已正确安装。

**Q:** 如何更新 API 密钥？
**A:** 直接在脚本中修改 `apiKeySecret` 变量的值即可。

## 联系我们

有任何问题欢迎提交 issue。