# cares-check

![status](https://img.shields.io/badge/status-working-brightgreen)
![scope](https://img.shields.io/badge/scope-local%20audit-blue)
![advisory-batch](https://img.shields.io/badge/advisories-12%20(2026--10--20)-orange)
![lang](https://img.shields.io/badge/lang-bash-lightgrey)

Audits a `libcares.so` (c-ares DNS resolver) against the **2026-10-20 advisory batch** —
12 advisories fixed in **1.34.9**, all affecting every `<= 1.34.8` build. That batch
includes 8 use-after-free-family issues, a DNS wrong-server acceptance flaw, an
uninitialized-memory return and a buffer-write in `ares_dup()`/`ares_save_options()`.

Single bash file, no dependencies. Reads the embedded version string from the library.

## Usage

```bash
./cares-check.sh /usr/lib/libcares.so.2
# or agentically inside containers:
docker cp cares-check.sh mycontainer:/tmp/cc.sh
docker exec mycontainer sh /tmp/cc.sh
```

Exit codes: `0` = patched (≥ 1.34.9) · `1` = vulnerable (≤ 1.34.8) · `2` = not found.

## Advisory batch covered (2026-10-20, all fixed in 1.34.9)

| GHSA | Class |
|---|---|
| GHSA-wpr3-8q3r-4q8c | memory corruption on cancel-after-connection-failure |
| GHSA-fqh5-3x7m-wp44 | DNS reply accepted from wrong server |
| GHSA-ph6c-3cvx-mq6v | buffer write in ares_dup()/ares_save_options() |
| GHSA-rf6g-ww74-97qh / GHSA-97vq-4mxv-7vhm / GHSA-mw23-pfg6-2x9r / GHSA-pj7p-v3cw-hq66 / GHSA-v33j-65h4-4ch8 | use-after-free family (cancels/callback/shutdown) |
| GHSA-grv7-fq5q-9vfc | cached answer freed while in use |
| GHSA-cfcv-8v2j-qj6r | uninitialized memory returned for numeric IPv6 +prefix |
| GHSA-wrgc-prmw-27xh | query cache mixes answers obtained with different EDNS options |

Older (also flagged by the version check): CVE-2026-33630, CVE-2025-62408, CVE-2025-31498, CVE-2026-69184/69186/89269.

## Verified

| Container | c-ares | Exit |
|---|---|---|
| flowiseai/flowise:3.1.4 (alpine 3.23) | 1.34.8 | 1 — vulnerable |
| n8nio/n8n:latest | 1.34.9 | 0 — patched |

Keep in mind: many images vendor c-ares **statically** (bundled in the main binary) — then
`find libcares*` finds nothing even though the code is there. For those, audit the container's
package DB (`/lib/apk/db/installed`, dpkg, rpm) instead.

## Related tools

- [php2shell-check](https://github.com/TahuCryptsi/php2shell-check) — PHP session.upload_progress CVE-2026-109618/109619
- [node-brotli-check](https://github.com/TahuCryptsi/node-brotli-check) — Node Brotli decoder CVE-2026-111497

## License

MIT.
