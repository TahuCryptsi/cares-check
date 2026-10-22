#!/bin/bash
# cares-check — c-ares version auditor (Oct-2026 advisory batch)
# Usage: ./cares-check.sh <path-to-libcares.so.x> | (runs on current container/host default paths)
# Exit: 0 = patched (>=1.34.9), 1 = vulnerable (<=1.34.8), 2 = not found/inconclusive

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  TARGET=$(find /lib /usr/lib -name 'libcares.so*' 2>/dev/null | head -1)
fi
[ -z "$TARGET" ] && { echo "no libcares found"; exit 2; }

VER=$(grep -aoE '"?1\.[0-9]+\.[0-9]+"?' "$TARGET" 2>/dev/null | grep -oE '1\.[0-9]+\.[0-9]+' | sort -uV | tail -1)
# fallback: try ARES version macro artifact
[ -z "$VER" ] && VER=$(grep -aoE 'ARES_VERSION[^0-9]*1\.[0-9.]+' "$TARGET" | grep -oE '1\.[0-9]+\.[0-9]+' | tail -1)

if [ -z "$VER" ]; then echo "libcares: $TARGET | version: UNKNOWN"; exit 2; fi

MAJ=$(echo "$VER" | cut -d. -f1); MIN=$(echo "$VER" | cut -d. -f2); PAT=$(echo "$VER" | cut -d. -f3)
VULN=0
if [ "$MAJ" -lt 1 ] 2>/dev/null; then VULN=1; fi
if [ "$MAJ" -eq 1 ]; then
  if [ "$MIN" -lt 34 ]; then VULN=1; fi
  if [ "$MIN" -eq 34 ] && [ "$PAT" -lt 9 ]; then VULN=1; fi
fi

echo "libcares: $TARGET"
echo "version : $VER"
# expose the 20 Oct 2026 advisory count for context
if [ "$VULN" = "1" ]; then
  echo "VERDICT : VULNERABLE — <=1.34.8 exposed to 12 advisories (2026-10-20 release)"
  echo "          UAF-family x8 | DNS wrong-server acceptance | uninit memory | buffer write (ares_dup)"
  echo "          + older: CVE-2026-33630 (UAF, 7.x), CVE-2025-62408, CVE-2025-31498"
  exit 1
else
  echo "VERDICT : >= 1.34.9 — Oct-2026 batch patched"
  exit 0
fi
