render_json_template() {
  local json="$1"
  shift

  # args override
  for pair in "$@"; do
    key=${pair%%=*}
    value=${pair#*=}
    json=$(echo "$json" | sed "s/{{$key}}/$value/g")
  done

  # ENV fallback (secrets)
  for var in $(echo "$json" | grep -o '{{[^}]*}}' | tr -d '{}' | sort -u); do
    value="${!var}"
    [[ -n "$value" ]] && json=$(echo "$json" | sed "s/{{$var}}/$value/g")
  done

  echo "$json"
}
