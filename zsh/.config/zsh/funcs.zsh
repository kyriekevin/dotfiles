fcd() {
  local dir

  local z_dirs=$(z -l 2>&1 | sed 's/^[0-9,.]* *//')

  local all_dirs=$(fd . --type d --max-depth 3 ~/)

  dir=$(echo "$z_dirs"$'\n'"$all_dirs" | sort -u | fzf)

  if [[ ! -z "$dir" ]]; then
    cd "$dir"
  fi
}

fnvim() {
  local file

  local z_dirs=$(z -l 2>&1 | sed 's/^[0-9,.]* *//')

  local all_files=$(fd . --type f --max-depth 3 ~/)

  file=$(echo "$z_dirs"$'\n'"$all_files" | sort -u | fzf)

  if [[ ! -z "$file" ]]; then
    nvim "$file"
  fi
}

# useage: create_and_cd [dir/path]
function create_and_cd() {
  local dir=$1
  if [[ -d $dir ]]; then
    cd $dir
    return
  fi
  mkdir -p $dir && cd $dir
}

function get_ip_local(){
  ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
}

# usage: get_ip [count]
function get_ip() {
  local services=(
    "https://api.ipify.org" # https://www.ipify.org/
    "https://api64.ipify.org"
    "https://ipinfo.io/ip" # https://ipinfo.io/
    "https://ifconfig.me/ip" # https://ifconfig.me/
  )

  local count=${1:-${#services[@]}}

  # split [0, count)
  local services=(${services[@]:0:$count})

  for service in ${services[@]}; do
    local ip=$(curl -s $service)
    if [[ -z $ip ]]; then
      echo -e "${RED}$service${RESET}: ${RED}failed${RESET}"
    else
      echo -e "${GREEN}$service${RESET}: $ip"
    fi
  done
}

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
        # export http_proxy="http://proxy.sensetime.com:3128/"
        # export https_proxy="http://proxy.sensetime.com:3128/"
        # export HTTP_PROXY="http://proxy.sensetime.com:3128/"
        # export HTTPS_PROXY="http://proxy.sensetime.com:3128/"
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

HIST_STAMPS="%d/%m/%y %T"
