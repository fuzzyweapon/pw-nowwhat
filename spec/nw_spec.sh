#!/usr/bin/env bash
#shellcheck shell=bash

eval "$(shellspec - -c) exit 1"

% PROJECT_DIR:"$SHELLSPEC_PROJECT_ROOT"
Describe 'nw.sh'
  Include 'nw.sh'
  Mock java
    echo "$@"
  End

  Describe ''
    setup() {
      cp -f "$PROJECT_DIR/getoptions.sh" "$PWD"
    }
    cleanUp() { if [[ -f "$PWD/getoptions.sh" ]]; then rm "$PWD/getoptions.sh"; fi; }

    BeforeAll 'setup'
    AfterAll 'cleanUp'

    It 'shows usage when running w/o args'
      When run script nw.sh
      The status should be a success
      The output should start with Usage:
    End

    It 'shows when asking for help'
      When run script nw.sh --help
      The status should be a success
      The output should start with Usage:
    End

    It 'shows on running w/too many args'
      When run script nw.sh foo town
      The status should be a failure
      The output should start with Usage:
    End

    It 'shows version'
      When run script nw.sh --version
      The status should be a success
      The output should match pattern 0.[0-9].[0-9]
    End
  End

  Describe '[messaging funcs]'
    It 'error() displays formatted error message and exits'
      When run error "foo happens"
      The status should be a failure
      The stderr should equal "[ERROR] foo happens"
    End
    It 'recoverable_error() displays a formatted error message and exits'
      When call recoverable_error "foo happens"
      The status should be a failure
      The stderr should equal "[ERROR] foo happens"
    End
    It 'warn() displays formatted warning message'
      When call warn "foo"
      The status should be a success
      The stderr should equal "[WARN] foo"
    End

    It 'info() displays formatted info message'
      When call info "foo"
      The status should be a success
      The output should equal "[INFO] foo"
    End
  End

  Describe '[compatibility]'
    Mock uname
      echo "fooOS"
    End
    It 'sends an error for unsupported operating systems'
      When run loading_OS_defaults
      The status should be a failure
      The stderr should start with "[ERROR] "
      The stderr should include "unsupported"
    End

    It 'sets the correct downloader for macOS'
      When call load_darwin
      The status should be a success
      The variable DOWNLOADER should equal "curl"
    End

    Describe 'Darwin/OSX/macOS,'
      Mock uname
        echo "Darwin"
      End
      It 'identifies OS and calls the correct loader'
        When call loading_OS_defaults
        The status should be a success
        The variable DOWNLOADER should equal "curl"
      End
    End

    It 'sets the correct downloader for linux (e.g. Ubuntu)'
      When call load_linux
      The status should be a success
      The variable DOWNLOADER should equal "wget"
    End

    Describe 'Linux/Ubuntu,'
      Mock uname
        echo "Linux"
      End
      It 'identifies OS and calls the correct loader'
        When call loading_OS_defaults
        The status should be a success
        The variable DOWNLOADER should equal "wget"
      End
    End
  End

  Describe 'evaluate_this()'
    It 'evaluates arguments without changing them'
      When call evaluate_this echo "foo dancing"
      The status should be a success
      The output should equal "foo dancing"
    End
  End

  Describe 'escape_with_any_key()'
    It 'does not trip up non-interactive sessions'
      When run escape_with_any_key
      The status should be a success
    End

    It 'passes along failure status'
      When run escape_with_any_key 1
      The status should be a failure
    End

    It 'passes along success status'
      When run escape_with_any_key 0
      The status should be a success
    End
  End

  Describe 'continue_with_any_key()'
    It 'does not trip up non-interactive sessions'
      When call continue_with_any_key
      The status should be a success
    End
  End

  Describe 'continue_or_bail()'
    It 'does not trip up non-interactive sessions'
      When call continue_or_bail
      The status should be a success
      The output should be blank
    End

    Describe ''
      Mock escape_with_any_key
        echo "We escaped!"
      End

      Describe 'with a Negative reply,'
        Before 'REPLY=N'

        It 'calls escape_with_any_key'
          When call continue_or_bail
          The output should include "We escaped!"
        End
      End

      Describe 'with a negative reply,'
        Before 'REPLY=n'

        It 'calls escape_with_any_key'
          When call continue_or_bail
          The output should include "We escaped!"
        End
      End
    End

    Describe ''
      Describe 'with a Positive reply,'
        Before 'REPLY=Y'

        It 'continues'
          When call continue_or_bail
          The status should be a success
          The output should be blank
        End
      End

      Describe 'with a positive reply,'
        Before 'REPLY=y'

        It 'continues'
          When call continue_or_bail
          The status should be a success
          The output should be blank
        End
      End
    End
  End

  Describe 'continue_with_default_or_bail()'
    continue_or_bail() {
      echo "$@"
    }

    It 'calls continue_or_bail with the default pack environment'
      When call continue_with_default_or_bail
      The output should include 'default pack environment'
      The output should include 'continue'
    End
  End

  Describe 'download()'
    error() {
      echo "$@" >&2
      return 1
    }

    evaluate_this() {
      echo "$@"
    }

    BeforeAll 'DOWNLOADER=curl'

    fIt 'sends an error without anything to download'
      When run download
      The status should be a failure
      # Todo: Should make this a custom Assertion that it is not_empty()
      The stderr should not equal ""
    End

    # Todo: Parametrize 'sends an error when sent an invalid url'
    fIt 'sends an error when sent an invalid url'
      When run download "foo"
      The status should be a failure
      The stderr should include 'url'
    End

    It 'passes the url correctly to eval'
      When call download "host:1234/foo.sh"
      The second word should equal "host:1234/foo.sh"
    End

    It 'supports subpaths on the host when using curl (call: download "host:1234/path/to/foo.sh")'
      When call download "host:1234/path/to/foo.sh"
      The output should end with "path/to/foo.sh"
    End

    It 'supports subpaths on the host when using curl (call: download "https://host:1234/path/to/foo.sh")'
      When call download "https://host:1234/path/to/foo.sh"
      The output should end with "path/to/foo.sh"
    End
  End

  Describe 'parse_target_arg()'
    It 'does nothing when it is sent nothing'
      When call parse_target_arg
      The status should be a success
      The output should equal ""
      The stderr should equal ""
    End

    It 'sets env target (cmd: nw.sh env)'
      When call parse_target_arg "env"
      The status should be a success
      The variable ENV_TARGET should equal "env"
      The variable PACK_HOST should equal ""
      The variable SIDE should equal "client"
      The output should equal ""
      The stderr should equal ""
    End

    It 'sets the pack host (cmd: nw.sh @host)'
      When call parse_target_arg "@host"
      The status should be a success
      The variable ENV_TARGET should be undefined
      The variable PACK_HOST should equal "host"
      The variable SIDE should equal "client"
      The output should equal ""
      The stderr should equal ""
    End

    It 'sets the pack host (cmd: nw.sh @host:1234)'
      When call parse_target_arg "@host:1234"
      The status should be a success
      The variable ENV_TARGET should be undefined
      The variable PACK_HOST should equal "host:1234"
      The variable SIDE should equal "client"
      The output should equal ""
      The stderr should equal ""
    End

    It 'sets the env target and pack host (cmd: nw.sh env@host)'
      When call parse_target_arg "env@host"
      The status should be a success
      The variable ENV_TARGET should equal "env"
      The variable PACK_HOST should equal "host"
      The variable SIDE should equal "client"
      The output should equal ""
      The stderr should equal ""
    End

    It 'sets the server pack flag (cmd: nw.sh env.server@host)'
      When call parse_target_arg "env.server@host"
      The status should be a success
      The variable ENV_TARGET should equal "env"
      The variable PACK_HOST should equal "host"
      The variable SIDE should equal "server"
      The output should equal ""
      The stderr should equal ""
    End
  End

  Describe 'resolve_getoptions()'
    download() {
      # shellcheck disable=SC2016
      SUBPATH="$(echo "$1" | sed -r 's#[^/]+/(.*)#\1#')"
      cp -f "$PROJECT_DIR/$SUBPATH" "$PWD"
    }
    error() {
      echo "$@" >&2
      exit 1
    }

    cleanUp() { if [[ -f "$PWD/getoptions.sh" ]]; then rm "$PWD/getoptions.sh"; fi; }

    AfterEach cleanUp
    Path getoptions="$PWD/getoptions.sh"

    It 'download()s getoptions.sh from the pack host when missing'
      When call resolve_getoptions "host"
      The status should be a success
      The path getoptions should be exist
      The file getoptions should not be executable
    End


    It 'sends an error when there is no local getoptions.sh and a host was not passed'
      When run resolve_getoptions
      The status should be a failure
      The file getoptions should not be exist
      The stderr should not equal ""
    End

    Describe ''
      download() { return 1; }

      It 'sends an error when something goes wrong with downloading getoptions.sh'
        When run resolve_getoptions "host"
        The status should be a failure
        The file getoptions should not be exist
        The stderr should not equal ""
      End
    End

    Describe ''
      download() { echo "Just try and source me!" > "$PWD/getoptions.sh"; }

      It 'sends an error when getoptions.sh cannot be sourced'
        When run resolve_getoptions "host"
        The status should be a failure
        The file getoptions should be exist
        The stderr should not equal ""
      End
    End
  End

  Describe 'resolve_env()'
    Describe ''
    # Todo: We use this at three different Describes on the same level D:
      error() {
        echo "[ERROR] $*" >&2
        exit 1
      }
    # Todo: We use this at two different Describes on the same level D:
      download() {
        # shellcheck disable=SC2016
        SUBPATH="$(echo "$1" | sed -r 's#[^/]+/(.*)#\1#')"
        if ! cp -f "$PROJECT_DIR/$SUBPATH" "$PWD"; then
          exit 1
        fi
      }

      It 'sends error when a matching .env cannot be found (cmd: resolve_env no_exist_env no_exist_host)'
        When run resolve_env "no_exist_env" "no_exist_host:1234"
        The status should be a failure
        The stderr should not equal ""
      End

      It 'sends error when a matching .env cannot be found (cmd: resolve_env no_exist_env)'
        When run resolve_env "no_exist_env"
        The status should be a failure
        The stderr should not equal ""
      End

      It 'sends error when a matching .env cannot be found (cmd: resolve_env no_exist_env host)'
        When run resolve_env "no_exist_env" "host"
        The status should be a failure
        The stderr should not equal ""
      End

      It 'sends error when it is passed a pack host but no env (cmd: resolve_env "" host)'
        When run resolve_env 0 "host"
        The status should be a failure
        The stderr should not equal ""
      End
    End

    Describe 'with a local_env present,'
      LOCAL_ENV="$PWD/envs/local_env@host.env"
      REMOTE_ENV="envs/remote_env@host.env"
      download() {
        # shellcheck disable=SC2016
        SUBPATH="$(echo "$1" | sed -r 's#[^/]+/(.*)#\1#')"
        if [ "$SUBPATH" == "$REMOTE_ENV" ]; then
          if [ ! -d "$(dirname "$REMOTE_ENV")" ]; then mkdir "$(dirname "$REMOTE_ENV")"; fi
          touch "$PWD/$REMOTE_ENV"
        fi
      }
      setup() { mkdir -p "$(dirname "$LOCAL_ENV")" && touch "$LOCAL_ENV"; }
      cleanUp() { rm -rf "$(dirname "$LOCAL_ENV")"; }
      BeforeAll setup
      AfterAll cleanUp

      It 'checks local envs/ directory for matching environments (cmd: resolve_env local_env)'
        When call resolve_env "local_env"
        The status should be a success
        The stderr should equal ""
        The variable ENV_CFG_FOUND should equal "true"
        The output should end with ".env"
      End

      fIt 'checks local envs/ directory for matching environments (cmd: resolve_env local_env host)'
        When call resolve_env "local_env" "host"
        The status should be a success
        The stderr should equal ""
        The variable ENV_CFG_FOUND should equal "true"
        The output should end with ".env"
      End

      It 'checks remote host for matching environments when none exist locally (cmd: resolve_env remote_env host)'
        When call resolve_env "remote_env" "host"
        The status should be a success
        The stderr should equal ""
        The variable ENV_CFG_FOUND should equal "true"
        The output should end with ".env"
      End
    End

    Describe ''
      LOCAL_ENV="$PWD/envs/env@host.env"
      LOCAL_ENV2="$PWD/envs/env@localhost.env"
      setup() { mkdir -p "$(dirname "$LOCAL_ENV")" && touch "$LOCAL_ENV" "$LOCAL_ENV2"; }
      cleanUp() { rm -rf "$(dirname "$LOCAL_ENV")"; }
      BeforeAll setup
      AfterAll cleanUp

      It 'sends an error when it gets multiple local environment matches'
        When run resolve_env "env"
        The status should be a failure
        The stderr should include "multiple"
      End
    End
  End

  Describe 'import_local_env()'
    preserve() { %preserve FOO; }
    setup() { echo "FOO=hi!" > foo.env; }
    cleanUp() { if [[ -f foo.env ]]; then rm foo.env; fi; preserve; }
    Mock source
      return
    End
    BeforeRun setup
    AfterRun cleanUp

    It 'imports local .env variables into the current session'
      When run import_local_env "foo.env"
      The status should be a success
      The stderr should equal ""
      The variable FOO should equal "hi!"
    End
  End

  Describe 'resolve_pw_installer_bootstrap()'
    PW_BOOTSTRAP_JAR="packwiz-installer-bootstrap.jar"
    File pw-installer-bootstrap-jar="$PWD/$PW_BOOTSTRAP_JAR"

    Describe "w/$PW_BOOTSTRAP_JAR present,"
      setup() { touch "$PW_BOOTSTRAP_JAR"; }
      cleanUp() { if [[ -f "$PW_BOOTSTRAP_JAR" ]]; then rm "$PW_BOOTSTRAP_JAR"; fi; }

      BeforeAll setup
      AfterAll cleanUp

      It 'continues without output'
        When call resolve_pw_installer_bootstrap
        The status should be a success
        The stderr should equal ""
        The output should equal ""
        The file pw-installer-bootstrap-jar should be exist
      End
    End

    Describe "w/$PW_BOOTSTRAP_JAR missing,"
      cleanUp() { if [[ -f "$PW_BOOTSTRAP_JAR" ]]; then rm "$PW_BOOTSTRAP_JAR"; fi; }
      download() { touch "$PWD/$PW_BOOTSTRAP_JAR"; }

      AfterAll cleanUp

      It "downloads the latest $PW_BOOTSTRAP_JAR"
        When call resolve_pw_installer_bootstrap
        The status should be a success
        The stderr should start with "[WARN]"
        The output should include "[INFO] "
        The output should include "successful"
        The file pw-installer-bootstrap-jar should be exist
      End
    End

    Describe "w/$PW_BOOTSTRAP_JAR missing"
      download() {
        echo "Foo error" >&2
        return 1;
      }

      It "sends an error and exits when the $PW_BOOTSTRAP_JAR download fails"
        When run resolve_pw_installer_bootstrap
        The status should be a failure
        The stderr should start with "[WARN]"
        The stderr should include "[ERROR]"
        The file pw-installer-bootstrap-jar should not be exist
      End
    End
  End
End
