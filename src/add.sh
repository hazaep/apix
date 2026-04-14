
cmd_add() { 
  name=$1
  method=$2
  path=$3
  shift 3

  if [[ "$1" == "--interactive" ]]; then
    interactive_add
    exit 0
  fi

  headers_json="{}"
  body_json="{}"

  for arg in "$@"; do
    case "$arg" in
      header:*)
        kv=${arg#header:}
        key=${kv%%=*}
        value=${kv#*=}
        headers_json=$(echo "$headers_json" | jq --arg k "$key" --arg v "$value" '. + {($k): $v}')
        ;;
      body:*)
        kv=${arg#body:}
        key=${kv%%=*}
        value=${kv#*=}
        body_json=$(echo "$body_json" | jq --arg k "$key" --arg v "$value" '. + {($k): $v}')
        ;;
      --raw-body=*)
        raw=${arg#--raw-body=}
        echo "$raw" | jq empty || { echo "❌ Raw body inválido"; exit 1; }
        body_json="$raw"
        ;;
    esac
  done

  # validar archivos
  jq empty "$ENDPOINTS_FILE" 2>/dev/null || {
    echo "❌ endpoints.json corrupto"
    exit 1
  }
  echo "$headers_json" | jq empty || {
    echo "❌ Headers JSON inválido"
    exit 1
  }

  echo "$body_json" | jq empty || {
    echo "❌ Body JSON inválido"
    exit 1
  }

  exists=$(jq -r "has(\"$name\")" "$ENDPOINTS_FILE")

  if [[ "$exists" == "true" ]]; then
    echo "❌ Endpoint ya existe"
    exit 1
  fi

  tmp=$(mktemp)

  jq --arg name "$name" \
     --arg method "$method" \
     --arg url "$path" \
     --arg headers "$headers_json" \
     --arg body "$body_json" \
  '
    . + {
      ($name): {
        method: $method,
        url: $url,
        headers: ($headers | fromjson? // empty),
        body: ($body | fromjson? // empty)
      }
    }
  ' "$ENDPOINTS_FILE" > "$tmp"

  if [[ -s "$tmp" ]]; then
    mv "$tmp" "$ENDPOINTS_FILE"
    echo "✅ Endpoint '$name' creado"
  else
    echo "❌ jq generó archivo vacío, abortando"
    rm "$tmp"
    exit 1
  fi
}