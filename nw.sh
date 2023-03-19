#!/usr/bin/env bash

# TODO:  Check for variables used in functions that are globally defined.  We need to make sure we're passing things as args and using local variables for functions
# Exit immediately if a command exits with a non-zero status
# Treat unset variables as an error when substituting
# TODO:  uncomment and comment out dev
set -e
# For Script Dev:
# + Print shell input lines as they are read
# + Print commands and their arguments as they are executed
#set -evx
# TODO: test this as an option for --dry-run flag?
# Read commands but do not execute them
#set -n

# shellcheck disable=SC2034
VERSION=0.0.1

### Helpers

# In Bash, returning from top level is only allowed if the script is being sourced
(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

# So we can test more easily
function evaluate_this {
  eval "$@"
}

function read_this_silently {
  if ! tty -s; then read -n1 -r -p -s "$@"; echo; fi
}

function escape_with_any_key {
  read_this_silently "Press any key to close..."
  # shellcheck disable=SC2086
  exit $1
}

function continue_with_any_key {
  read_this_silently "Press any key to continue..."
}

function continue_or_bail {
  read_this_silently "$1 Y/n"

  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo
    echo "Goodbye friend!"
    echo
    escape_with_any_key 1
  fi
}

function continue_with_default_or_bail {
  continue_or_bail "[HI] Would you like to continue with the default pack environment?"
}

## Msging

function error {
  echo "[ERROR] $1" >&2
  escape_with_any_key 1
}

function recoverable_error {
  echo "[ERROR] $1" >&2
  continue_with_any_key
  return 1
}

function warn {
  echo "[WARN] $1" >&2
}

function info {
  echo "[INFO] $1"
}

## Downloading

function load_darwin {
  DOWNLOADER="curl"
  DOWNLOADER_ARGS="-q --compressed -s -Lo"
}

function load_linux {
  DOWNLOADER="wget"
  DOWNLOADER_ARGS="--quiet --show-progress --progress=bar:force --force-directories --no-host-directories --compression=auto --trust-server-names"
}

function download {
  URL="$1"
  if [ -z "$1" ]; then error "No url provided to download()"; exit 1; fi

  GITHUB_REGEX="^(https?:\/\/)?(www\.)?github\.com\/releases\/latest\/download\/(.+)$"
  REGEX="^(https?:\/\/)?(www\.)?[^\/]+\/(.+)$"

  if [[ ! $URL =~ $REGEX ]]; then error "Provided url ($URL) might be malformed"; exit 1; fi
  # curl strips paths on -O so this is for wget parity
  if [ "$DOWNLOADER" = "curl" ]; then
    if [[ $URL =~ $GITHUB_REGEX ]]; then
      DOWNLOADER_ARGS="$DOWNLOADER_ARGS ${BASH_REMATCH[3]}"
    # Reload REGEX groups into matcher
    elif [[ $URL =~ $REGEX ]]; then
      DOWNLOADER_ARGS="$DOWNLOADER_ARGS ${BASH_REMATCH[3]}"
    fi
  fi

#  ( evaluate_this "$DOWNLOADER $URL $DOWNLOADER_ARGS" )
  evaluate_this "$DOWNLOADER $URL $DOWNLOADER_ARGS"
}

function unsupported_OS {
  error "Sorry, but your OS ($1) is unsupported at this time"
}

##

function loading_OS_defaults {
  OS="$(uname | tr '[:upper:]' '[:lower:]')"
  case $OS in
    darwin*)  load_darwin;;
    linux*)   load_linux;;
    *)  unsupported_OS "$OS";;
  esac
}

# target => <env>[.server]@<pack_host>
function parse_target_arg {
  # BUG:  Not supporting .server at all
  # PRIOR TO @ || ALL OF IT

  if [[ $1 =~ ^[^@]+@?.*$ ]]; then
    ENV_SEGMENT=${1/@*}
    ENV_TARGET=${ENV_SEGMENT/.*}
  fi

  if [ "${ENV_SEGMENT#*.}" = "server" ]; then
    SIDE=server
  else
    SIDE=client
  fi

  # AFTER @ || NONE OF IT
  if  [[ $1 =~ ^[^@]*@[^@]+$ ]]; then
    PACK_HOST=${1#*@}
  else
    PACK_HOST=""
  fi
}

# Pass PACK_HOST
function resolve_getoptions {
  GETOPTIONS="getoptions.sh"
  LOCAL_GETOPTIONS="$PWD/$GETOPTIONS"

  # Download getoptions lib from PACK_HOST if necessary
  if [ ! -f "$LOCAL_GETOPTIONS" ]; then
    [[ -z "${1:-}" ]] && error "You have no local copy of getoptions and didn't pass a pack host"
    if ! download "$1/$GETOPTIONS"; then
      error "Something went wrong with the download of getoptions from $1"
    fi
  fi

  if [ -f "$LOCAL_GETOPTIONS" ]; then
    # shellcheck disable=SC1090
    if ! source "$LOCAL_GETOPTIONS"; then
      error "Couldn't source $LOCAL_GETOPTIONS"
    fi
  fi
}

function parser_definition {
  setup   REST plus:true help:usage abbr:true -- \
        "Usage: ${2##*/} [options...] [arguments...]" ''
  msg -- 'The NowWhat script wraps packwiz to make things even simpler.' ''
  msg -- 'Options:'
  disp    :usage  -h  --help
  disp    VERSION     --version
}

ENV_CFG_DEFAULT="envs/nw.env"
DEFAULT_ENV_MISSING="false"

#function check_for_local_env_cfg_default {
#  if [ ! -f "$ENV_CFG_DEFAULT" ]; then
#    DEFAULT_ENV_MISSING="true"
#    echo "[WARN] The default .env file is missing => $ENV_CFG_DEFAULT"
#  fi
#}

function import_local_env {
  # shellcheck disable=SC1090
  set -o allexport && source "$1" && set +o allexport
}

function resolve_env {
  # Magic numbery, but allowing to pass 0 for "" allows us to support dual optional args in a sense
  # shellcheck disable=SC2086
  if [ "$1" == "0" ]; then ENV_TARGET=""; else ENV_TARGET="$1"; fi
  PACK_HOST=$2
  ENV_CFG_FOUND="false"
  if [[ $ENV_TARGET ]] && [[ $PACK_HOST ]]; then
    # Check local envs/ directory for the full .env file
    PROSPECTIVE_ENV="envs/$ENV_TARGET@$PACK_HOST.env"
    if [ -f "$PWD/$PROSPECTIVE_ENV" ]; then
      ENV_CFG_FOUND="true"
      echo "$PWD/$PROSPECTIVE_ENV"
    elif download "$PACK_HOST/$PROSPECTIVE_ENV"; then
      ENV_CFG_FOUND="true"
      echo "$PWD/$PROSPECTIVE_ENV"
    fi
  elif [[ $ENV_TARGET ]] && [[ ! $PACK_HOST ]]; then
    # Check local envs/ directory for the .env file that matches the $ENV_TARGET@*
    RESOLVE="$(find "$PWD/envs/" -iname "${ENV_TARGET}@*.env")"
    # shellcheck disable=SC2046
    if [ $(echo "$RESOLVE" | wc -w) -eq 0 ]; then
      # No matches; would you like to use one of these other environments?
      # TODO:  List environments local and remote @PACK_HOST with a number to select from or bail
      error "You have no local copy of the $ENV_TARGET env and didn't pass a pack host"
    elif [ $(echo "$RESOLVE" | wc -w) -eq 1 ]; then
      ENV_CFG_FOUND="true"
      echo "$RESOLVE"
    # -gt 1 match...
    else
      # Multiple matches; which environment would you like of the matches?
      # TODO:  List local matches as 'dev@localhost' instead of 'env/dev@localhost.env'
      error "You got multiple matches locally, so you'll need to be more specific:\n$RESOLVE"
    fi
  elif [[ ! $ENV_TARGET ]] && [[ $PACK_HOST ]]; then
    # Here are the environments available at that pack host
    # TODO:  List the environments available for download at the PACK_HOST
    error "You passed a host, but no environment to find!"
  fi
}

function resolve_pw_installer_bootstrap {
  PW_INSTALLER_BOOTSTRAP="packwiz-installer-bootstrap.jar"

  if [ ! -f "$PW_INSTALLER_BOOTSTRAP" ]; then
    warn "OH NO!  You need the packwiz-installer-bootstrap to keep the pack up to date automatically..."
    continue_or_bail "May I download it (or would you like to bail)?"

    LATEST_PW_INST_BOOTSTRAP="https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest/download/$PW_INSTALLER_BOOTSTRAP"
    download "$LATEST_PW_INST_BOOTSTRAP" && info "Download of the latest $PW_INSTALLER_BOOTSTRAP was successful!"

    if [[ $? -eq 1 ]]; then error "Something went wrong with the $PW_INSTALLER_BOOTSTRAP download."; fi
  fi
}

if [ $SOURCED -eq 1 ]; then
  return;
fi

if [ $# -eq 1 ]; then
  loading_OS_defaults
  ## Parsing
  # We need PACK_HOST from $1
  parse_target_arg "$1"
  # QUESTION: What is this
  : "${LANG:=C}"
  resolve_getoptions "$PACK_HOST"
else
  resolve_getoptions
fi

eval "$(getoptions parser_definition - "$0") exit 1"

[ $# -eq 0 ] && usage && exit
[ $# -gt 1 ] && usage && exit 1

ENV_CFG="$(resolve_env "$ENV_TARGET" "$PACK_HOST")"

# Check for/get the latest packwiz installer bootstrap
resolve_pw_installer_bootstrap

info "Printing Java version, if the Java version doesn't show below, your Java path is incorrect"
$JAVAPATH -version && echo

PW_INSTALLER="https:/github.com/packwiz/packwiz-installer/releases/latest/download/packwiz-installer.jar"
LAUNCH_ARGS="--bootstrap-update-url $PW_INSTALLER -s $SIDE $PACK_HOST/$PACK_FILE"
info "Launching $PW_INSTALLER_BOOTSTRAP with '$MEMORY' max memory, jvm args '$JVMARGS' and arguments '$LAUNCH_ARGS'"

# shellcheck disable=SC2086
"$JAVAPATH" -Xmx$MEMORY $JVMARGS -jar "$PW_INSTALLER_BOOTSTRAP" $LAUNCH_ARGS
