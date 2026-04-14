get_endpoint_json() {
  local name=$1
  jq -c ".$name" "$ENDPOINTS_FILE"
}

get_env_json() {
  local env=$1
  jq -c ".$env" "$ENVS_FILE"
}