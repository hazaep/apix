SECRETS_DIR="$DATA_DIR/secrets"
APIX_CONFIG_DIR="$HOME/.config/apix"
AGE_KEY_FILE="$APIX_CONFIG_DIR/age.key"

ensure_config() {
  mkdir -p "$APIX_CONFIG_DIR"
}

# =========================
# INIT
# =========================

secrets_init() {
  ensure_config

  if [[ -f "$AGE_KEY_FILE" ]]; then
    echo "⚠️ Key ya existe en $AGE_KEY_FILE"
    return
  fi

  age-keygen -o "$AGE_KEY_FILE"

  echo "✅ Key generada en: $AGE_KEY_FILE"
  echo "⚠️ Guarda este archivo, es tu private key"
  grep "public key:" "$AGE_KEY_FILE"
}

# =========================
# ENCRYPT
# =========================

get_public_key() {
  grep "public key:" "$AGE_KEY_FILE" | awk '{print $3}'
}

secrets_encrypt_file() {
  local input="$1"
  local output="${input}.age"

  local pubkey=$(get_public_key)

  age -r "$pubkey" -o "$output" "$input"

  echo "🔐 Encrypted: $output"
}

# =========================
# DECRYPT (memoria)
# =========================

decrypt_file() {
  local file="$1"

  age -d -i "$AGE_KEY_FILE" "$file"
}

# =========================
# LOAD ENV (core)
# =========================

load_env_from_string() {
  while IFS='=' read -r key value; do
    [[ -z "$key" ]] && continue
    [[ "$key" =~ ^# ]] && continue
    export "$key=$value"
  done
}

load_env_file() {
  local file="$1"

  [[ -f "$file" ]] || return

  if [[ "$file" == *.age ]]; then
    decrypted=$(decrypt_file "$file")
    load_env_from_string <<< "$decrypted"
  else
    load_env_from_string < "$file"
  fi
}

load_secrets() {
  local env="$1"

  load_env_file "$SECRETS_DIR/global.env.age"
  load_env_file "$SECRETS_DIR/default.env.age"
  load_env_file "$SECRETS_DIR/$env.env.age"
}

secrets_add() {
  local env="$1"
  local key="$2"
  local value="$3"

  local tmp=$(mktemp)
  local file="$SECRETS_DIR/$env.env.age"

  # descifrar si existe
  if [[ -f "$file" ]]; then
    decrypt_file "$file" > "$tmp"
  fi

  echo "$key=$value" >> "$tmp"

  # re-encriptar
  secrets_encrypt_file "$tmp"

  mv "$tmp.age" "$file"
  rm "$tmp"

  echo "✅ Secret agregado a $env"
}