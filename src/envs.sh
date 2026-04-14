cmd_env() {
  subcmd=$1
  shift

  case "$subcmd" in
    list)
      jq -r 'keys[]' "$ENVS_FILE"
      ;;
    add)
      env_name=$1
      base_url=$2
      shift 2

      headers_json="{}"

      for arg in "$@"; do
        case "$arg" in
          header:*)
            kv=${arg#header:}
            key=${kv%%=*}
            value=${kv#*=}
            headers_json=$(echo "$headers_json" | jq --arg k "$key" --arg v "$value" '. + {($k): $v}')
            ;;
        esac
      done

      # validar archivo
      jq empty "$ENVS_FILE" 2>/dev/null || {
        echo "❌ envs.json corrupto"
        exit 1
      }

      echo "$headers_json" | jq empty || {
        echo "❌ Headers JSON inválido"
        exit 1
      }

      exists=$(jq -r "has(\"$env_name\")" "$ENVS_FILE")

      if [[ "$exists" == "true" ]]; then
        echo "❌ Env ya existe"
        exit 1
      fi

      tmp=$(mktemp)

      jq --arg name "$env_name" \
         --arg base_url "$base_url" \
         --arg headers "$headers_json" \
      '
        . + {
          ($name): {
            base_url: $base_url,
            headers: ($headers | fromjson? // empty)
          }
        }
      ' "$ENVS_FILE" > "$tmp"

      if [[ -s "$tmp" ]]; then
        mv "$tmp" "$ENVS_FILE"
        echo "✅ Env '$env_name' creado"
      else
        echo "❌ jq generó archivo vacío, abortando"
        rm "$tmp"
        exit 1
      fi
      ;;
    *)
      echo "Usage: api-core env [list|add]"
      ;;
  esac
}