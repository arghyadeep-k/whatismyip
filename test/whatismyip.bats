#!/usr/bin/env bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../bin/whatismyip"
  MOCK_DIR="$(mktemp -d)"
  PATH="$MOCK_DIR:$PATH"
}

teardown() {
  rm -rf "$MOCK_DIR"
}

mock_curl() {
  # $1 = stdout to print, $2 = exit code (default 0)
  cat > "$MOCK_DIR/curl" <<EOF
#!/usr/bin/env bash
echo -n "$1"
exit ${2:-0}
EOF
  chmod +x "$MOCK_DIR/curl"
}

mock_ip() {
  cat > "$MOCK_DIR/ip" <<'EOF'
#!/usr/bin/env bash
echo "2: eth0    inet 10.0.0.5/24 scope global eth0"
EOF
  chmod +x "$MOCK_DIR/ip"
}

@test "no args prints public IPv4" {
  mock_curl "1.2.3.4"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "1.2.3.4" ]
}

@test "-6 prints public IPv6" {
  mock_curl "::1"
  run "$SCRIPT" -6
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "::1" ]
}

@test "-l prints local IPv4 via ip" {
  mock_ip
  run "$SCRIPT" -l
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "10.0.0.5" ]
}

@test "--local prints local IPv4 via ip" {
  mock_ip
  run "$SCRIPT" --local
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "10.0.0.5" ]
}

@test "-a prints public and local IPs" {
  mock_curl "1.2.3.4"
  mock_ip
  run "$SCRIPT" -a
  [ "$status" -eq 0 ]
  [[ "$output" == *"Public: 1.2.3.4"* ]]
  [[ "$output" == *"10.0.0.5"* ]]
}

@test "--all prints public and local IPs" {
  mock_curl "1.2.3.4"
  mock_ip
  run "$SCRIPT" --all
  [ "$status" -eq 0 ]
  [[ "$output" == *"Public: 1.2.3.4"* ]]
  [[ "$output" == *"10.0.0.5"* ]]
}

@test "-h prints usage" {
  run "$SCRIPT" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: whatismyip"* ]]
}

@test "--help prints usage" {
  run "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: whatismyip"* ]]
}

@test "unknown option exits 1 with usage" {
  run "$SCRIPT" --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --bogus"* ]]
}

@test "falls back to second curl endpoint when first fails" {
  cat > "$MOCK_DIR/curl" <<'EOF'
#!/usr/bin/env bash
COUNT_FILE="${BATS_TEST_TMPDIR}/curl_call_count"
n=0
[ -f "$COUNT_FILE" ] && n=$(cat "$COUNT_FILE")
n=$((n + 1))
echo "$n" > "$COUNT_FILE"
if [ "$n" -eq 1 ]; then
  exit 1
fi
echo -n "5.6.7.8"
EOF
  chmod +x "$MOCK_DIR/curl"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "5.6.7.8" ]
}
