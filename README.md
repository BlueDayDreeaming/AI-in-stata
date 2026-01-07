# ai - Stata AI 交互命令

[English](#english) | [中文](#中文)

---

<a name="中文"></a>
## 中文文档

在 Stata 内部直接与 AI 进行对话交互。

### 功能特点

- 🤖 在 Stata 命令行直接与 AI 对话
- 💬 支持多轮对话，保持上下文
- ⚙️ 支持 OpenAI 及兼容 API（DeepSeek、通义千问等）
- 📦 配置持久化存储

### 安装

1. 下载以下文件：
   - `ai.ado`
   - `AI_api.py`
   - `AI.sthlp`

2. 将文件放入 Stata 的 ado 目录：
   ```stata
   * 查看 ado 目录位置
   adopath
   
   * 通常放入 personal 目录，例如：
   * Windows: C:\ado\personal\
   * Mac: ~/ado/personal/
   ```

### 系统要求

- Stata 16.0 或更高版本
- Python 3.6+（已集成到 Stata）

### 配置 API 密钥（重要）

使用本命令前，您需要获取 AI 服务的 API 密钥。以下是详细步骤：

#### 方式一：使用硅基流动（推荐国内用户）

1. **注册账号**：访问 https://siliconflow.cn 注册账号
2. **获取密钥**：登录后进入「API密钥」页面，点击「创建密钥」
3. **复制密钥**：密钥格式类似 `sk-xxxxxxxxxxxxxxxx`
4. **在 Stata 中配置**：
   ```stata
   * 设置 API 密钥
   ai, config(apikey "sk-你的密钥")
   
   * 设置 API 地址
   ai, config(baseurl "https://api.siliconflow.cn/v1")
   
   * 设置模型（硅基流动提供免费额度）
   ai, config(model "deepseek-ai/DeepSeek-V2.5")
   ```

#### 方式二：使用 OpenAI

1. **注册账号**：访问 https://platform.openai.com 注册
2. **获取密钥**：进入 API Keys 页面创建密钥
3. **在 Stata 中配置**：
   ```stata
   ai, config(apikey "sk-你的OpenAI密钥")
   ai, config(baseurl "https://api.openai.com/v1")
   ai, config(model "gpt-4o-mini")
   ```

#### 方式三：使用通义千问

1. **注册账号**：访问 https://dashscope.console.aliyun.com 注册
2. **获取密钥**：在控制台创建 API Key
3. **在 Stata 中配置**：
   ```stata
   ai, config(apikey "sk-你的通义密钥")
   ai, config(baseurl "https://dashscope.aliyuncs.com/compatible-mode/v1")
   ai, config(model "qwen-turbo")
   ```

#### 验证配置

```stata
* 查看当前配置
ai, config(show)

* 测试对话
ai 你好
```

### 使用方法

#### 基本对话

```stata
ai "你的问题"
```

#### 配置选项

| 命令 | 说明 |
|------|------|
| `ai, config(apikey "密钥")` | 设置 API 密钥 |
| `ai, config(baseurl "URL")` | 设置 API 地址 |
| `ai, config(model "模型")` | 设置模型名称 |
| `ai, config(timeout "秒数")` | 设置超时时间（默认120秒） |
| `ai, config(show)` | 显示当前配置 |

#### 其他选项

| 命令 | 说明 |
|------|------|
| `ai, clear` | 清除对话历史 |
| `ai, help` | 显示帮助信息 |
| `ai "问题", system("提示词")` | 使用自定义系统提示词 |
| `ai "问题", nohistory` | 单次对话，不使用历史 |

### 示例

```stata
* 统计分析问题
ai 如何进行面板数据的固定效应回归？

* 代码调试
ai 这段代码有什么问题：reg y x1 x2, robust cluster

* 多轮对话
ai 什么是工具变量？
ai 能给我一个 Stata 的例子吗？
ai 如何检验工具变量的有效性？

* 清除历史开始新话题
ai, clear
ai 如何绘制生存曲线？
```

### 常见问题

**Q: 提示"未设置API密钥"怎么办？**

A: 请按照上方「配置 API 密钥」部分设置您的密钥。

**Q: 请求超时怎么办？**

A: 可以增加超时时间：`ai, config(timeout "300")`

**Q: 如何切换不同的 AI 模型？**

A: 使用 `ai, config(model "模型名称")` 切换模型。

### 配置文件位置

配置存储在：`c(sysdir_personal)/stata_ai/ai_config.dta`

---

<a name="english"></a>
## English Documentation

Interact with AI directly within Stata.

### Features

- 🤖 Chat with AI directly from Stata command line
- 💬 Multi-turn conversations with context
- ⚙️ Support OpenAI and compatible APIs (DeepSeek, Qwen, etc.)
- 📦 Persistent configuration storage

### Installation

1. Download the following files:
   - `ai.ado`
   - `AI_api.py`
   - `AI.sthlp`

2. Place files in Stata's ado directory:
   ```stata
   * Check ado path
   adopath
   
   * Usually place in personal directory:
   * Windows: C:\ado\personal\
   * Mac: ~/ado/personal/
   ```

### Requirements

- Stata 16.0 or later
- Python 3.6+ (integrated with Stata)

### API Key Configuration (Important)

Before using this command, you need to obtain an API key from an AI service.

#### Option 1: OpenAI

1. **Register**: Visit https://platform.openai.com
2. **Get API Key**: Go to API Keys page and create a new key
3. **Configure in Stata**:
   ```stata
   ai, config(apikey "sk-your-openai-key")
   ai, config(baseurl "https://api.openai.com/v1")
   ai, config(model "gpt-4o-mini")
   ```

#### Option 2: SiliconFlow (Recommended for China)

1. **Register**: Visit https://siliconflow.cn
2. **Get API Key**: Create key in the dashboard
3. **Configure in Stata**:
   ```stata
   ai, config(apikey "sk-your-key")
   ai, config(baseurl "https://api.siliconflow.cn/v1")
   ai, config(model "deepseek-ai/DeepSeek-V2.5")
   ```

#### Option 3: Alibaba Qwen

1. **Register**: Visit https://dashscope.console.aliyun.com
2. **Get API Key**: Create key in console
3. **Configure in Stata**:
   ```stata
   ai, config(apikey "sk-your-qwen-key")
   ai, config(baseurl "https://dashscope.aliyuncs.com/compatible-mode/v1")
   ai, config(model "qwen-turbo")
   ```

#### Verify Configuration

```stata
* Show current configuration
ai, config(show)

* Test conversation
ai Hello
```

### Usage

#### Basic Conversation

```stata
ai "your question"
```

#### Configuration Options

| Command | Description |
|---------|-------------|
| `ai, config(apikey "key")` | Set API key |
| `ai, config(baseurl "URL")` | Set API base URL |
| `ai, config(model "name")` | Set model name |
| `ai, config(timeout "sec")` | Set timeout (default 120s) |
| `ai, config(show)` | Show current configuration |

#### Other Options

| Command | Description |
|---------|-------------|
| `ai, clear` | Clear conversation history |
| `ai, help` | Show help message |
| `ai "q", system("prompt")` | Use custom system prompt |
| `ai "q", nohistory` | Single query without history |

### Examples

```stata
* Statistical analysis
ai How to run fixed effects regression with panel data?

* Code debugging
ai What's wrong with this code: reg y x1 x2, robust cluster

* Multi-turn conversation
ai What is instrumental variable?
ai Can you give me a Stata example?
ai How to test the validity of instruments?

* Clear history and start new topic
ai, clear
ai How to plot survival curves?
```

### FAQ

**Q: "API key not set" error?**

A: Follow the "API Key Configuration" section above.

**Q: Request timeout?**

A: Increase timeout: `ai, config(timeout "300")`

**Q: How to switch AI models?**

A: Use `ai, config(model "model-name")`.

### Configuration File Location

Config stored at: `c(sysdir_personal)/stata_ai/ai_config.dta`

---

## License

MIT License

## Author

GitHub Copilot

## Contributing

Issues and Pull Requests are welcome!





