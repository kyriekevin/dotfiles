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

