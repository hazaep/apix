run_endpoint() {
  local name=$1
  shift

  local env="$DEFAULT_ENV"
  local args=()
  # flags
  local FLAG_VERBOSE=false
  local FLAG_SILENT=false
  local FLAG_JSON=false
  local FLAG_STATUS=false
  local FLAG_HEADERS=false
  local FLAG_RAW=false
  local FLAG_PATH=""

  for arg in "$@"; do
    case "$arg" in
      --env=*)
        env="${arg#*=}"
        ;;
      --verbose)
        FLAG_VERBOSE=true
        ;;
      --silent)
        FLAG_SILENT=true
        ;;
      --json)
        FLAG_JSON=true
        ;;
      --status)
        FLAG_STATUS=true
        ;;
      --headers)
        FLAG_HEADERS=true
        ;;
      --raw)
        FLAG_RAW=true
        ;;
      --path=*)
        FLAG_PATH="${arg#*=}"
        ;;
      *)
        args+=("$arg")
        ;;
    esac
  done

  # cargar datos
  local endpoint_json=$(get_endpoint_json "$name")
  local env_json=$(get_env_json "$env")
  local method=$(echo "$endpoint_json" | jq -r '.method')
  local path=$(echo "$endpoint_json" | jq -r '.url')
  local base_url=$(echo "$env_json" | jq -r '.base_url')
  local url="${base_url}${path}"
  # cargar secrets
  load_secrets "$env"

  # HEADERS
  
  local headers=()

  # env headers
  while IFS="=" read -r key value; do
    headers+=("-H" "$key: $value")
  done < <(echo "$env_json" | jq -r '.headers // {} | to_entries[] | "\(.key)=\(.value)"')
  # endpoint headers (override)
  while IFS="=" read -r key value; do
    headers+=("-H" "$key: $value")
  done < <(echo "$endpoint_json" | jq -r '.headers // {} | to_entries[] | "\(.key)=\(.value)"')

  # BODY

  local body=$(echo "$endpoint_json" | jq -c '.body // empty')

  if [[ -n "$body" && "$body" != "null" ]]; then
    body=$(render_json_template "$body" "${args[@]}")
  fi

  # DEBUG (opcional pero útil)
  if [[ "$FLAG_VERBOSE" == true ]]; then
    echo "→ $method $url"
    echo "Headers:"
    for h in "${headers[@]}"; do
      echo "  $h"
    done
    if [[ -n "$body" ]]; then
      echo "Body:"
      echo "$body" | jq .
    fi
  fi

  # CURL

  if [[ -n "$body" ]]; then
    # detectar si ya existe content-type
    has_ct=false
    for ((i=0; i<${#headers[@]}; i+=2)); do
      if [[ "${headers[i+1]}" =~ Content-Type ]]; then
        has_ct=true
        break
      fi
    done
    if [[ "$has_ct" == false ]]; then
      headers+=("-H" "Content-Type: application/json")
    fi
  fi

  # ejecutar curl y capturar código HTTP
  response=$(mktemp)
  if [[ -n "$body" ]]; then
    http_code=$(curl -s -D "$response.headers" -o "$response" -w "%{http_code}" \
      -X "$method" "$url" "${headers[@]}" --data-raw "$body")
  else
    http_code=$(curl -s -D "$response.headers" -o "$response" -w "%{http_code}" \
      -X "$method" "$url" "${headers[@]}")
  fi

  response_body=$(cat "$response")
  response_headers=$(cat "$response.headers")

  local output_done=false

  if [[ "$FLAG_RAW" == true ]]; then
    cat "$response.headers"
    cat "$response"
    output_done=true
  fi

  if [[ "$FLAG_STATUS" == true ]]; then
    echo "$http_code"
    output_done=true
  fi

  if [[ "$FLAG_HEADERS" == true ]]; then
    echo "$response_headers"
    output_done=true
  fi

  if [[ "$FLAG_SILENT" == true ]]; then
    echo "$response_body"
    output_done=true
  fi

  if [[ "$FLAG_JSON" == true && "$output_done" == false ]]; then
    if echo "$response_body" | jq . >/dev/null 2>&1; then
      echo "$response_body" | jq .
    else
      echo "$response_body"
    fi
    output_done=true
  fi

  if [[ -n "$FLAG_PATH" && "$output_done" == false ]]; then
    if echo "$response_body" | jq . >/dev/null 2>&1; then
      echo "$response_body" | jq -r "$FLAG_PATH"
    else
      echo "❌ Body no es JSON válido"
    fi
    output_done=true
  fi

  if [[ "$output_done" == false ]]; then
    echo "HTTP $http_code"
    echo "$response_body"
  fi

  # guardar historial
  save_history "$name" "$method" "$url" "$env" "$body" "$http_code"
  rm "$response"
}
