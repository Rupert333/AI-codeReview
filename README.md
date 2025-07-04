# 使用大语言模型自动进行CodeReview

## 功能简介

本工具通过 Git Hook 自动调用大语言模型进行代码评审，并将评审结果保存为 Markdown 格式的文件。脚本支持在代码提交时自动运行，并为开发团队提供即时反馈。

## 功能特点

- **自动化代码评审**：在代码提交时，脚本自动调用大语言模型，进行全面的代码评审。
- **多模型支持**：默认使用智谱GLM模型，可通过配置文件灵活切换。
- **保存评审结果**：评审结果以 Markdown 格式保存到指定目录中。
- **易于集成**：脚本可轻松集成到 Git 的预提交（pre-commit）钩子中，实现无缝代码检查。
- **健壮的错误处理**：增强的错误处理和日志记录，提高系统可靠性。

## 前提条件

- 已安装 Git。
- 拥有智谱GLM API 密钥。
- 需要在脚本中使用 `jq` 工具来处理 JSON 数据。

## 安装 `jq` 工具

### 在 macOS 上安装 `jq`

打开终端，使用 Homebrew 包管理器安装 `jq`，运行以下命令：

```sh
brew install jq
```

### 在 Windows 上安装 `jq`

1、将 jq.exe 放置到一个您希望的目录，例如 C:\Program Files\jq。

2、将 jq.exe 添加到系统 PATH 环境变量：

•右键点击“此电脑”或“我的电脑”，选择“属性”。

•点击“高级系统设置”。

•在“系统属性”窗口中，点击“环境变量”按钮。

•在“系统变量”部分，找到名为 Path 的变量，选中后点击“编辑”。

•点击“新建”，然后添加 jq.exe 所在的目录路径（例如 C:\Program Files\jq）。

•点击“确定”保存所有更改。

3、验证安装： 打开一个新的命令提示符或 PowerShell 窗口（旧窗口可能不会立即识别新的 PATH 变量），运行以下命令：

```shell
jq --version
```

![show.png](file/img/show.png)

## 文件结构

本工具由以下三个主要文件组成：

1. **pre-commit**：Git钩子主脚本，负责获取代码变更并调用评审脚本。
2. **config.sh**：配置文件，包含API密钥、模型选择、提示词模板等设置。
3. **glm_zhipu.sh**：智谱GLM模型的评审实现脚本（如使用OpenAI，则为glm_openai.sh）。

## 安装步骤

1. **创建必要文件**：

   ```sh
   # 创建hooks目录（如果不存在）
   mkdir -p .git/hooks
   
   # 创建评审日志目录
   mkdir -p codeReviewLog
   ```

2. **保存脚本文件**：

   将以下三个文件保存到对应位置：

   - `pre-commit` → `.git/hooks/pre-commit`
   - `config.sh` → `.git/hooks/config.sh`
   - `glm_zhipu.sh` → `.git/hooks/glm_zhipu.sh`

3. **赋予脚本权限**（仅适用于 macOS 和 Linux）：

   ```sh
   chmod +x .git/hooks/pre-commit
   chmod +x .git/hooks/glm_zhipu.sh
   ```

4. **配置 API 密钥**：

   在 `config.sh` 文件中，将 `zhipu_api_key_secret` 替换为您的智谱API密钥。

## 配置说明

`config.sh` 文件包含以下主要配置项：

```sh
# API密钥
zhipu_api_key_secret="your-zhipu-api-key-here"
openai_api_key="your-openai-api-key-here"

# 评审结果保存目录
directory="codeReviewLog"

# 提示词模板
read -r -d '' prompt << 'ENDPROMPT'
你是一位资深的编程架构师，精通架构设计、最佳实践、以及各种编程语言。
请根据以下git diff记录，对代码进行全面评审...
ENDPROMPT

# 选择要使用的模型 ('zhipu' 或 'openai')
selected_model="zhipu"

```

## 使用方法

1. **正常使用**：

   完成安装和配置后，当您执行 `git commit` 时，脚本将自动运行，并调用大语言模型进行代码评审。评审结果将保存在 `codeReviewLog` 目录下的 Markdown 文件中。


   ```sh
   debug_mode=true
   ```

## 脚本说明

- **原始响应文件**：保存大语言模型的原始 JSON 响应，文件名为 `originalFilename_时间戳.json`。
- **评审结果文件**：格式化后的评审结果将保存为 Markdown 格式的文件，文件名为 `codeReviewResult_时间戳.md`。
- **日志目录**：所有生成的日志文件都会保存在 `codeReviewLog` 目录中。

## 技术实现细节

1. **代码变更处理**：
   - 使用 `git diff --cached` 获取待提交的代码变更
   - 通过 `jq` 工具安全处理特殊字符和JSON格式

2. **API请求构造**：
   - 将提示词和代码变更作为独立消息发送
   - 使用临时文件存储JSON请求体，避免命令行参数长度限制

3. **错误处理**：
   - 增强的HTTP错误处理
   - 详细的错误日志和调试信息

## 注意事项

- 确保您的 API 密钥安全，不要泄露给他人。
- 在使用脚本前，请确认您的项目中已正确配置 Git，并确保脚本文件在 `.git/hooks/` 目录下且具有执行权限。
- 如果您的代码变更非常大，可能会遇到API限制，请适当调整提交大小。

## FQA

**Q:** 为什么在提交时没有看到代码评审结果？  
**A:** 请检查 pre-commit 脚本是否正确放置在 `.git/hooks` 目录下，并且具有执行权限。

**Q:** 如何处理脚本执行失败的情况？  
**A:** 检查脚本输出的错误信息，确保您的网络环境可以访问API，并且 `jq` 工具已正确安装。启用调试模式可以获取更详细的错误信息。

**Q:** 如何更新 API 密钥？  
**A:** 直接在 `config.sh` 文件中修改相应的API密钥变量值即可。

**Q:** 收到HTTP 400错误怎么办？  
**A:** 这通常是由于JSON请求体格式不正确或API密钥问题导致的。启用调试模式查看详细错误信息，并确认API密钥是否有效。

**Q:** 如何切换使用的模型？  
**A:** 在 `config.sh` 文件中修改 `selected_model` 变量的值为 "zhipu" 或 "openai"。
