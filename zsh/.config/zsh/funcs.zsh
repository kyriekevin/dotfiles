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

function rm() {
  # https://iboysoft.com/questions/why-is-there-no-put-back-button-in-mac-trash.html
  echo -e '\033[31mUse "rmm", or the full path i.e. "/bin/rm"\033[0m'
  if ! command -v trash &> /dev/null; then
    echo -e '\033[31mtrash command not found. Please install trash first.\033[0m'
    return
  fi
  trash "$@"
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
