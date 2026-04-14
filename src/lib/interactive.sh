interactive_add_endpoint() {
  read -p "Name: " name
  read -p "Method: " method
  read -p "Path: " path

  headers=()
  body=()

  echo "Agregar headers? (y/n)"
  read yn
  if [[ "$yn" == "y" ]]; then
    while true; do
      read -p "Header (key=value, vacío para salir): " h
      [[ -z "$h" ]] && break
      headers+=("header:$h")
    done
  fi

  echo "Agregar body? (y/n)"
  read yn
  if [[ "$yn" == "y" ]]; then
    while true; do
      read -p "Body (key=value, vacío para salir): " b
      [[ -z "$b" ]] && break
      body+=("body:$b")
    done
  fi

  api-core add "$name" "$method" "$path" "${headers[@]}" "${body[@]}"
}

interactive_add_env() {
  read -p "Env name: " name
  read -p "Base URL: " base_url

  headers=()

  echo "Agregar headers? (y/n)"
  read yn
  if [[ "$yn" == "y" ]]; then
    while true; do
      read -p "Header (key=value, vacío para salir): " h
      [[ -z "$h" ]] && break
      headers+=("header:$h")
    done
  fi

  api-core env add "$name" "$base_url" "${headers[@]}"
}

interactive_add() {
  echo "¿Qué quieres crear?"
  select type in "endpoint" "env"; do
    case $type in
      endpoint)
        interactive_add_endpoint
        break
        ;;
      env)
        interactive_add_env
        break
        ;;
    esac
  done
}