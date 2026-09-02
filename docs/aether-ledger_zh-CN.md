# Aether Ledger

> [English](aether-ledger.md) · 中文

dotfiles 只负责 Aether Ledger 的机器依赖和私有输入。采集逻辑、生成的 launchd agent、独立 writer
worktree、日志和数据均由 Aether Ledger 仓库负责。守住这条边界后，`chezmoi apply` 不会拿一份过期的
调度器覆盖当前安装。

## 纳管的输入

| Source | Target | 归属 |
|---|---|---|
| `Brewfile` | Homebrew packages | dotfiles 安装 `uv`、`ccusage` 和 `zstd` |
| `dot_config/token-activity/node_name.tmpl` | `~/.config/token-activity/node_name` | dotfiles 根据 `is_work` 渲染 `work` 或 `personal` |
| 加密的 Multica source | `~/.config/token-activity/multica.json` | dotfiles 在工作机解密私有启动参数 |
| 加密的 runtime-role source | `~/.config/token-activity/multica_runtime_roles.json` | dotfiles 在工作机解密私有 runtime 别名 |

两份加密文件在个人机器上会被忽略。里面包含 profile、workspace 和 runtime 名称，不应明文进入公开仓库。

## 运行时状态不进 dotfiles

Chezmoi 不管理：

- `~/.config/token-activity/multica_dsh_profile`：采集器创建的持久来源绑定；
- `~/Library/LaunchAgents/com.kyriekevin.aether-ledger.plist`：installer 生成的文件；
- `~/.cache/aether-ledger/writer`、日志、DSH sessions 和累计数据。

不要把这些路径加入 dotfiles。私有配置里的 `dshProfile` 只负责为新机器提供首次绑定值；绑定创建后由
采集器负责，不能静默换源。

## 复现一台机器

先应用 dotfiles 输入，再从 Aether Ledger checkout 安装：

```bash
chezmoi --source="$HOME/.dotfiles" apply --parent-dirs ~/.config/token-activity

cd "$HOME/github/Aether_Ledger"
make install
make health
```

`make install` 是 launchd plist 的唯一写入者。以后更新调度或私有环境时重新运行它，不要手改生成文件。

## 健康检查

```bash
make health PACKAGE=aether-ledger
```

dotfiles 侧只检查依赖声明，并把真实安装校验交给 Aether Ledger 自己的 `make health`，不复制它的配置合同。

手工确认：

- [ ] Aether Ledger checkout 中的 `make health` 通过。
- [ ] 下一轮定时任务会更新当天 `usage/YYYY-MM-DD` 分支。
- [ ] Git diff 中没有私有 profile、workspace、runtime 或绝对路径。
