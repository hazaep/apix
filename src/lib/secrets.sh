SECRETS_DIR="$DATA_DIR/secrets"

load_env_file() {
  local file="$1"

  [[ -f "$file" ]] || return

  while IFS='=' read -r key value; do
    [[ -z "$key" ]] && continue
    [[ "$key" =~ ^# ]] && continue

    export "$key=$value"
  done < "$file"
}

load_secrets() {
  local env="$1"

  # orden de carga
  load_env_file "$SECRETS_DIR/global.env"
  load_env_file "$SECRETS_DIR/default.env"
  load_env_file "$SECRETS_DIR/$env.env"
}