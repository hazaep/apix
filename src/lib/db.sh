DB_FILE="$DATA_DIR/history.db"

init_db() {
  sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  endpoint TEXT,
  method TEXT,
  url TEXT,
  env TEXT,
  request_body TEXT,
  response_code INTEGER
);
EOF
}

save_history() {
  local endpoint="$1"
  local method="$2"
  local url="$3"
  local env="$4"
  local body="$5"
  local code="$6"

  sqlite3 "$DB_FILE" <<EOF
INSERT INTO history (endpoint, method, url, env, request_body, response_code)
VALUES (
  '$endpoint',
  '$method',
  '$url',
  '$env',
  '$(echo "$body" | sed "s/'/''/g")',
  '$code'
);
EOF
}