render_json_template() {
  local json="$1"
  shift

  for pair in "$@"; do
    key=${pair%%=*}
    value=${pair#*=}

    json=$(echo "$json" | sed "s/{{$key}}/$value/g")
  done

  echo "$json"
}
