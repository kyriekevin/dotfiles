<h1 align="center">dotfiles</h1>

<p align="center">
  <em>个人 macOS 配置，使用 <a href="https://www.chezmoi.io">chezmoi</a> + <a href="https://github.com/FiloSottile/age">age</a> 管理。</em>
</p>

<p align="center">
  <a href="README.md">English</a> · 中文
</p>

<p align="center">
  <a href="LICENSE"><img alt="license" src="https://img.shields.io/github/license/kyriekevin/dotfiles?style=flat-square"></a>
  <a href="https://www.chezmoi.io"><img alt="managed by chezmoi" src="https://img.shields.io/badge/managed%20by-chezmoi-5fafd7?style=flat-square&logo=homeassistantcommunitystore&logoColor=white"></a>
  <a href="https://www.conventionalcommits.org"><img alt="conventional commits" src="https://img.shields.io/badge/commits-conventional-fe5196?style=flat-square&logo=conventionalcommits&logoColor=white"></a>
  <a href="https://github.com/pre-commit/pre-commit"><img alt="pre-commit" src="https://img.shields.io/badge/pre--commit-enabled-brightgreen?style=flat-square&logo=pre-commit&logoColor=white"></a>
</p>

---

## ✨ 快速开始

全新 Mac 上：

```bash
# 1. 安装 Homebrew                   https://brew.sh

# 2. 放入 age 私钥                   （从已有 Mac 拷出）
mkdir -p ~/.config/chezmoi && chmod 700 ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt && chmod 600 ~/.config/chezmoi/key.txt

# 3. Bootstrap
sh -c "$(curl -fsSL https://raw.githubusercontent.com/kyriekevin/dotfiles/main/bootstrap.sh)"
```

首次运行时，`chezmoi init` 会询问：

| 变量        | 用途                                             |
| ----------- | ------------------------------------------------ |
| `git_email` | 本机 `~/.gitconfig` 的主邮箱                     |
| `is_work`   | 工作机为 `true`，个人机为 `false`                |

## 🧰 工具栈

repo 依赖的核心工具。

| 工具 | 作用 | 安装 |
| --- | --- | --- |
| [Homebrew](https://brew.sh) | macOS 包管理器 | `bootstrap.sh`（非交互式） |
| [chezmoi](https://www.chezmoi.io) | dotfiles 管理工具 | bootstrap → `brew install chezmoi` |
| [age](https://github.com/FiloSottile/age) | 密文加密 | bootstrap → `brew install age` |
| [gh](https://cli.github.com) | GitHub CLI（PR / review 流程必备） | bootstrap → `brew install gh` |
| [Claude Code](https://claude.com/claude-code) | AI coding CLI | bootstrap → `curl -fsSL https://claude.ai/install.sh \| bash` |
| [Node.js](https://nodejs.org) | Claude Code 插件 `.mjs` hook 与 `npx` 守卫的运行时 | Brewfile → `brew install node` |
| [uv](https://github.com/astral-sh/uv) | Python 工具运行器 | Brewfile → `brew install uv` |
| [pre-commit](https://pre-commit.com) | Git hooks（空白符/密钥/conventional-commits） | `uv tool install pre-commit` —— 流程见 [CONTRIBUTING.zh.md](CONTRIBUTING.zh.md) |

完整包清单（shell / git / editor 工具 + GUI cask）见 [`Brewfile`](Brewfile)。每次 Brewfile 变更，`chezmoi apply` 都会自动重跑 `brew bundle`。

## 🗂 目录结构

```text
~/.dotfiles/
├── dot_*                         → ~/.*            （真正的 dotfiles）
├── encrypted_private_*.age       → chmod 0600，apply 时 age 解密
├── *.tmpl                        → 用 chezmoi data 做 Go 模板渲染
├── .chezmoiscripts/              → apply 时触发的 hook（run_once_before_*, run_onchange_after_*）
├── Brewfile                      → brew bundle（由 hook 触发）
├── bootstrap.sh                  → 新 Mac 的入口脚本
├── docs/                         → 运维手册（secrets 等）
├── .github/                      → issue + PR 模板
├── .chezmoi.toml.tmpl            → init 交互提示 + age recipient
├── .chezmoiignore                → chezmoi 不管理的路径
├── .pre-commit-config.yaml       → 空白符 / gitleaks / conv-commits
├── CONTRIBUTING.zh.md            → 分支 / commit 规范
└── README.zh.md                  → 就是你正在看的
```

> [!NOTE]
> 本 repo 位于 `~/.dotfiles`（不是 chezmoi 默认的 `~/.local/share/chezmoi`）。每个 `chezmoi` 命令都需要带 `--source=$HOME/.dotfiles`，或者在 `~/.config/chezmoi/chezmoi.toml` 设置 `sourceDir = "~/.dotfiles"`。

## ⚙️ 脚本

`chezmoi apply` 会执行 [`.chezmoiscripts/`](.chezmoiscripts) 下所有 `run_*` 文件。文件名本身是一份执行契约 —— 每一段都控制一个维度的行为：

```text
run_onchange_after_20-brew-bundle.sh.tmpl
└─┬┘ └───┬──┘ └─┬─┘ └┬┘ └────┬────┘ └─┬┘ └─┬─┘
  │     │      │    │       │       │    └─ .tmpl = 用 chezmoi data 渲染的 Go 模板
  │     │      │    │       │       └──── .sh    = 解释器
  │     │      │    │       └──────────── 可读名字
  │     │      │    └──────────────────── 排序前缀（数字，升序）
  │     │      └───────────────────────── before / after 相对 apply 写 dotfile
  │     └──────────────────────────────── once（成功一次）/ onchange / always
  └────────────────────────────────────── run_ 前缀 = 脚本，非 dotfile
```

`onchange` 脚本如果依赖**外部文件**（例如 `Brewfile`），要把外部文件的 hash 内嵌在脚本注释里 —— 外部一变，脚本自身内容 hash 跟着变，chezmoi 据此决定是否重跑。

完整属性列表见 [chezmoi source-state attributes](https://www.chezmoi.io/reference/source-state-attributes/)。

## 🔐 Secrets

敏感信息以 [age](https://github.com/FiloSottile/age) **加密后**提交到 repo。带 `encrypted_` 前缀的文件在 `chezmoi apply` 时透明解密，使用 `~/.config/chezmoi/key.txt` 作为 age 身份（chmod 600，永不入库——由 `.gitignore` + `gitleaks` 双重强制）。

无需手工步骤即可编辑加密密钥：

```bash
chezmoi edit ~/.config/zsh/secrets.zsh
```

完整手册——新机 bootstrap、新增、轮换、陷阱——见 [docs/secrets.zh.md](docs/secrets.zh.md)。

## 🧪 贡献

commit / 分支规范与 pre-commit 安装见 [CONTRIBUTING.zh.md](CONTRIBUTING.zh.md)。

## 🔗 相关

- [nousresearch/hermes-agent](https://github.com/nousresearch/hermes-agent) —— 开源 agent 框架
- _（未来）_ 自研的 Claude Code agents / skills —— 拆出到独立 repo

## 📄 License

MIT —— 见 [LICENSE](LICENSE)。
