# Secrets 运维手册

> [English](secrets.md) · 中文

本 repo 中的敏感信息都用 age 加密后静态存放，`chezmoi apply` 时透明解密。这份文档是操作员手册 —— 新 Mac bootstrap、新增一条 secret、编辑已有 secret、轮换密钥。

## 原理

| 组件 | 位置 | 是否入库？ |
|---|---|---|
| age **私钥**（identity） | `~/.config/chezmoi/key.txt`，chmod `600` | **不入库** —— 被 `.gitignore` + `gitleaks` 拦截 |
| age **公钥**（recipient） | `.chezmoi.toml.tmpl` → `[age].recipient` | 入库 —— 公钥本来就可以公开 |
| 加密后的 secret 文件 | `<source>/encrypted_private_<name>.age` | 入库 —— 只有密文 |
| 解密后的目标文件 | `~/.config/.../<name>`（如 `~/.config/zsh/secrets.zsh`） | 被 `.gitignore` 拦截（`**/secrets.zsh`） |

## 新 Mac bootstrap（在 `chezmoi init --apply` 之前）

加密文件只能在拥有私钥的机器上解密。通过带外渠道拷贝：

```bash
mkdir -p ~/.config/chezmoi && chmod 700 ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt && chmod 600 ~/.config/chezmoi/key.txt
```

可用渠道：iCloud Drive、AirDrop、U 盘。**永远不要**走邮件、Slack 或任何会被索引的通道。

## 新增一条加密 secret

简易路径 —— 明文已经在目标位置的情况：

```bash
chezmoi add --encrypt ~/.config/zsh/secrets.zsh
```

从零创作的路径 —— 想从头写内容、又不想让明文在硬盘上停留：

```bash
# 1. 在临时文件里写明文
vim /tmp/secrets_plain.zsh

# 2. 直接加密到 source 树（注意文件名前缀 —— 见 Gotchas）
#    `age-keygen -y <identity>` 会从私钥文件反推公钥字符串，
#    这是获取 recipient 的最可移植方式。
age -r "$(age-keygen -y ~/.config/chezmoi/key.txt)" \
    -o ~/.dotfiles/dot_config/zsh/encrypted_private_secrets.zsh.age \
    /tmp/secrets_plain.zsh

# 3. 擦明文。`rm -P` 是 BSD 版的 `shred -u`；在 APFS 上多遍覆写
#    其实是空操作（写时复制），但 macOS 的 /tmp 本就是 volatile，
#    所以这是"多一道防线"而不是严格保证。
rm -P /tmp/secrets_plain.zsh 2>/dev/null || rm -f /tmp/secrets_plain.zsh

# 4. 验证 chezmoi 能正确解析
chezmoi --source=$HOME/.dotfiles managed | grep secrets.zsh
chezmoi --source=$HOME/.dotfiles cat ~/.config/zsh/secrets.zsh
```

## 编辑已有 secret

在解密后的内容上打开 `$EDITOR`，保存时重新加密：

```bash
chezmoi edit ~/.config/zsh/secrets.zsh
chezmoi apply                 # 或：chezmoi apply ~/.config/zsh/secrets.zsh
```

## 轮换 age 密钥

1. `age-keygen -o ~/.config/chezmoi/key-new.txt && chmod 600 ~/.config/chezmoi/key-new.txt` —— 生成新密钥对
2. 对 source 里每个 `encrypted_*.age` 文件：用旧私钥解密、再用新公钥加密。**永远不要在管道里写回同一个文件** —— shell 重定向会在 `age -d` 读取之前截断 `<file>`，密文会被永久丢失。走一个临时文件：
   ```bash
   age -d -i ~/.config/chezmoi/key.txt <file> \
     | age -r <new-pub> -o <file>.tmp \
     && mv <file>.tmp <file>
   ```
3. 更新 `.chezmoi.toml.tmpl` 里的 `[age].recipient`，然后重新执行 `chezmoi --source=$HOME/.dotfiles init` 让模板重新渲染出 `~/.config/chezmoi/chezmoi.toml`。**不要手改渲染后的 config** —— `promptStringOnce` 的回答（`git_email`、`is_work`）已经存在它的 `[data]` 段里，init 不会再次追问
4. 切换：`mv key-new.txt key.txt` —— **把新私钥分发到每一台需要用的 Mac**
5. 把重新加密的文件 + recipient 变更作为一个 atomic PR 提交

## Gotchas（踩过的坑）

**文件名前缀的顺序有讲究。** chezmoi 从左往右解析 source attribute，但某些组合会短路。确认可用的顺序是 `encrypted_private_<name>.age`。反过来（`private_encrypted_<name>.age`）会让 `encrypted_` 留在目标文件名里，`chezmoi cat` 会把路径报成 "not managed"。

**`encryption = "age"` 必须是 `chezmoi.toml` 的顶层 key。** 把它放在 `[data]` 之后，TOML 会把它解析成 `data.encryption`，chezmoi 会静默 fallback 并发出警告（`'encryption' not set, using age configuration. Check if 'encryption' is correctly set as the top-level key.`）。要放在所有 `[section]` 标题之前。

**`chezmoi init --promptString key=value` 不会为 `promptStringOnce` 预填值。** "once" 变体在首次运行时总会尝试从 TTY 读。实际用起来，这只会咬非交互式 init（CI、脚本）—— 真实 Mac bootstrap 会正常交互，没问题。非交互场景下，手写 `~/.config/chezmoi/chezmoi.toml`（模板渲染出来的本来就是这个文件）。

**`.gitignore` 保险绳。** `**/secrets.zsh` 拦截任何误入 source 树的明文。如果重命名目标文件或新增不同名字的 secret，要把新明文的模式也加到 `.gitignore` —— 别只靠 gitleaks。
