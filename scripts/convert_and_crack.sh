#!/usr/bin/env bash
set -euo pipefail

# convert_and_crack.sh
# Usage: ./convert_and_crack.sh <capture.cap> <wordlist.txt> [--mode auto|22000|2500] [--hash outname]
# Example: ./convert_and_crack.sh hackme.cap wordlist.txt
# تحذير: لا تستخدم هذا السكربت على شبكات بدون إذن صريح.

CAP="$1"
WORDLIST="$2"
MODE="auto"
OUTPREFIX=""
shift 2 || true
while (( "${#}" )); do
  case "$1" in
    --mode)
      MODE="$2"; shift 2;;
    --hash)
      OUTPREFIX="$2"; shift 2;;
    *)
      echo "Unknown option: $1"; exit 2;;
  esac
done

if [[ ! -f "$CAP" ]]; then
  echo "Error: capture file not found: $CAP" >&2
  exit 1
fi
if [[ ! -f "$WORDLIST" ]]; then
  echo "Error: wordlist not found: $WORDLIST" >&2
  exit 1
fi

# Helpers to find tools
command -v hashcat >/dev/null 2>&1 || { echo "hashcat not found in PATH. Install it first."; exit 1; }
HCXPCAPNGTOOL="$(command -v hcxpcapngtool || true)"
CAP2HCCAPX="$(command -v cap2hccapx || true)"
AIRCRACKNG="$(command -v aircrack-ng || true)"

BASEDIR="$(dirname "$CAP")"
BASENAME="$(basename "$CAP" .cap)"
OUTPREFIX="${OUTPREFIX:-${BASEDIR}/${BASENAME}}"

echo "Using capture: $CAP"
echo "Wordlist: $WORDLIST"
echo "Output prefix: $OUTPREFIX"
echo "Preferred mode: $MODE"

# Convert capture
HCCAPX_PATH="${OUTPREFIX}.hccapx"
HCCAP22000_PATH="${OUTPREFIX}.22000"

if [[ "$MODE" == "22000" || "$MODE" == "auto" ]]; then
  if [[ -n "$HCXPCAPNGTOOL" ]]; then
    echo "Converting to 22000 using hcxpcapngtool..."
    hcxpcapngtool -o "$HCCAP22000_PATH" "$CAP" || true
    if [[ -s "$HCCAP22000_PATH" ]]; then
      echo "Created: $HCCAP22000_PATH"
      SELECTED_MODE=22000
    else
      echo "hcxpcapngtool did not produce a valid 22000 file."
      rm -f "$HCCAP22000_PATH" || true
    fi
  else
    echo "hcxpcapngtool not found."
  fi
fi

if [[ -z "${SELECTED_MODE:-}" && ( "$MODE" == "2500" || "$MODE" == "auto" ) ]]; then
  if [[ -n "$CAP2HCCAPX" ]]; then
    echo "Converting to hccapx using cap2hccapx..."
    # cap2hccapx usage may be: cap2hccapx infile capout
    cap2hccapx "$CAP" "$HCCAPX_PATH" || true
    if [[ -s "$HCCAPX_PATH" ]]; then
      echo "Created: $HCCAPX_PATH"
      SELECTED_MODE=2500
    else
      echo "cap2hccapx did not produce a valid hccapx file."
      rm -f "$HCCAPX_PATH" || true
    fi
  elif [[ -n "$AIRCRACKNG" ]]; then
    echo "aircrack-ng found — attempting converting via aircrack-ng utilities (may require building cap2hccapx)."
    # attempt aircrack-ng direct (aircrack-ng outputs info; but not direct hccapx)
    # fallback: use aircrack-ng to check handshake presence
  fi
fi

if [[ -z "${SELECTED_MODE:-}" ]]; then
  echo "Failed to create an input hash file (no supported converter found or conversion failed)." >&2
  echo "Install hcxtools (hcxpcapngtool) or cap2hccapx (from aircrack-ng) and retry." >&2
  exit 2
fi

# Run hashcat
if [[ "$SELECTED_MODE" == "22000" ]]; then
  echo "Running hashcat mode 22000..."
  hashcat -m 22000 "$HCCAP22000_PATH" "$WORDLIST" --status --status-timer=10
  echo "When finished, show cracked: hashcat --show -m 22000 $HCCAP22000_PATH $WORDLIST"
elif [[ "$SELECTED_MODE" == "2500" ]]; then
  echo "Running hashcat mode 2500 (hccapx)..."
  hashcat -m 2500 "$HCCAPX_PATH" "$WORDLIST" --status --status-timer=10
  echo "When finished, show cracked: hashcat --show -m 2500 $HCCAPX_PATH $WORDLIST"
fi

echo "Done."
