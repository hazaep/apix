API_ROOT="$HOME/.hbs-source/api-tool"
DATA_DIR="$API_ROOT/data"
LIB_DIR="$API_ROOT/src/lib"
CMD_DIR="$API_ROOT/src"

ENDPOINTS_FILE="$DATA_DIR/endpoints.json"
ENVS_FILE="$DATA_DIR/envs.json"

DEFAULT_ENV="default"

source "$CMD_DIR/add.sh"
source "$CMD_DIR/envs.sh"
source "$CMD_DIR/executor.sh"
source "$LIB_DIR/renderer.sh"
source "$LIB_DIR/db.sh"
source "$LIB_DIR/interactive.sh"
source "$LIB_DIR/parser.sh"
source "$LIB_DIR/secrets.sh"
