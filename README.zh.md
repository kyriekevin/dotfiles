<h1 align="center">dotfiles</h1>

<p align="center">
  一套可复现的 macOS 终端与开发环境，由
  <a href="https://www.chezmoi.io">chezmoi</a>、Homebrew 和 age 管理。
</p>

<p align="center">
  <a href="README.md">English</a> · 中文
</p>

<p align="center">
  <a href="https://github.com/kyriekevin/dotfiles/actions/workflows/verify.yml"><img alt="Verify" src="https://github.com/kyriekevin/dotfiles/actions/workflows/verify.yml/badge.svg"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/kyriekevin/dotfiles?style=flat-square"></a>
  <a href="https://www.chezmoi.io"><img alt="Managed by chezmoi" src="https://img.shields.io/badge/managed%20by-chezmoi-5fafd7?style=flat-square"></a>
</p>

> [!IMPORTANT]
> 这是个人配置，不是开箱即用的通用模板。新机安装需要匹配的 age identity；如果 fork，必须先
> 替换 age recipient 并重新加密密文，再运行 bootstrap。

## 管理什么

- 用一份 [`Brewfile`](Brewfile) 还原 CLI、字体和 GUI app。
- 按机器渲染 Git 身份，敏感信息只以 age 密文进入 Git。
- 统一管理 shell、终端、编辑器、文件导航、键位和 coding agent 配置。
- 本地与 GitHub Actions 共用同一个确定性门禁：`make verify`。

| 领域 | 主要组件 | 文档 |
|---|---|---|
| Shell 与提示符 | Zsh、zinit、Starship、Fastfetch | [Zsh](docs/zsh.zh.md) · [Starship](docs/starship.zh.md) · [Fastfetch](docs/fastfetch.zh.md) |
| 终端工作流 | Ghostty、Herdr、Yazi | [Ghostty](docs/ghostty.zh.md) · [Agent 工作流](docs/agent-workflows.zh.md) · [Yazi](docs/yazi.zh.md) |
| 编辑器与 Git | Neovim、Git、Lazygit、GitHub CLI | [Neovim](docs/nvim.zh.md) · [Git](docs/git.zh.md) |
| 自动化 | Karabiner-Elements、Homebrew hooks | [Karabiner](docs/karabiner.zh.md) · [维护流程](docs/maintenance.zh.md) |
| Coding agents | Claude Code 设置、plugins、MCP 边界 | [Claude Code](docs/claude.zh.md) · [扩展机制](docs/claude-plugins.zh.md) |

## 配置一台新 Mac

先把已有 age identity 放到新 Mac，再运行 bootstrap：

```bash
mkdir -p ~/.config/chezmoi
chmod 700 ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt

sh -c "$(curl -fsSL https://raw.githubusercontent.com/kyriekevin/dotfiles/main/bootstrap.sh)"
```

Bootstrap 会在缺失时安装 Homebrew 和核心工具，把仓库 clone 到 `~/.dotfiles`，然后执行
`chezmoi init --apply`。首次运行只询问两个值：

| 值 | 含义 |
|---|---|
| `git_email` | 这台 Mac 使用的 Git 身份 |
| `is_work` | 选择工作机或个人机配置 |

密钥传输、轮换或 fork 的具体步骤见 [Secrets 手册](docs/secrets.zh.md)。

## 更新已有 Mac

```bash
cd ~/.dotfiles
git pull --ff-only
chezmoi --source="$PWD" diff
chezmoi --source="$PWD" apply
```

Apply 前先看 diff。`Brewfile` 变化会自动触发 `brew bundle`；其他 `run_once_*` 和
`run_onchange_*` hooks 会收敛各工具的附加状态。

## 工作原理

```text
Git source (~/.dotfiles)
├── chezmoi 渲染 / 解密 ─────→ HOME 中的目标文件
├── Brewfile 变化 ───────────→ brew bundle
└── apply-time hooks ────────→ plugins 和附加状态
```

仓库刻意使用 `~/.dotfiles`，而不是 chezmoi 默认 source 目录。Config template 会为新安装固定该
路径；上面的更新命令仍显式传入 source，以兼容修复前已经 init 的旧机器。

## 从哪里开始

| 我想要…… | 入口 |
|---|---|
| 安全修改配置 | [维护与修改流程](docs/maintenance.zh.md) |
| 建分支或开 PR | [贡献指南](CONTRIBUTING.zh.md) |
| 新增、编辑或轮换 secret | [Secrets 手册](docs/secrets.zh.md) |
| 排查某个工具 | 上方组件表里的对应文档 |
| 检查 apply 后的真实环境 | `make health PACKAGE=zsh` 与 [live health 说明](tests/README.md) |

仓库改动的最短交付闭环是：

```bash
make verify
chezmoi --source="$PWD" diff
make health PACKAGE=zsh   # 把 zsh 换成受影响的 package
```

## License

MIT，见 [LICENSE](LICENSE)。
