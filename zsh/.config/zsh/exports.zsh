export PATH=$HOME/bin:/usr/local/bin:$PATH

export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles

export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

export EDITOR=nvim

# vpn
CPU_INFO=$(sysctl machdep.cpu.brand_string)

if [[ $CPU_INFO == "machdep.cpu.brand_string: Apple M2" ]]; then
  CURRENT_VPN="home"
else
  CURRENT_VPN="company"
fi

function sv() {
    if [[ $CURRENT_VPN == "company" ]]; then
        export http_proxy="http://127.0.0.1:7890"
        export https_proxy="http://127.0.0.1:7890"
        export all_proxy="socks5://127.0.0.1:7890"
        unset HTTP_PROXY
        unset HTTPS_PROXY
        CURRENT_VPN="home"
        echo "Switched to home VPN settings"
    else
        export http_proxy="http://proxy.sensetime.com:3128/"
        export https_proxy="http://proxy.sensetime.com:3128/"
        export HTTP_PROXY="http://proxy.sensetime.com:3128/"
        export HTTPS_PROXY="http://proxy.sensetime.com:3128/"
        unset all_proxy
        CURRENT_VPN="company"
        echo "Switched to company VPN settings"
    fi
}

function vpn() {
    if [[ $CURRENT_VPN == "company" ]]; then
        echo "You are currently using company VPN settings."
    else
        echo "You are currently using home VPN settings."
    fi
}
