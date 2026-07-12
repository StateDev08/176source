# glinkd license bypass wrapper

This directory contains a small `LD_PRELOAD` shim (`init_patch.c`) and a shell
wrapper (`glinkd-wrapper.sh`) that allows the real, functional `glinkd` binary
from the `pwserver` package to start without a license server.

The source `glinkd` in `cnet/glinkd` is only a generated `rpcgen` stub and cannot
route game data. The `pwserver` package provides a real `glinkd` ELF, but it
contains a license backdoor that kills the process unless a valid license
response is present.

`init_patch.so` patches the in-memory license check at runtime:

* It finds the `glinkd` PIE base via `/proc/self/maps`.
* It allocates a zeroed `0x220`-byte `LicenseDataBase` and stores it in the
  `LIC` global pointer.
* It sets `SUCCESS` to `0` and the `Init` flag.
* It patches `LicenseInterfaces::Init` to return `1` immediately.

With `SUCCESS` and `LIC` zeroed, `LicenseInterfaces::Value` and `Check` return
values that satisfy `main` and `glinkd` starts its `GLinkServer` and
`GProviderServer` sockets.

## How it is built and installed

`build.sh` now builds `share/glinkd-wrapper` instead of the `cnet/glinkd` stub.
The install step copies the wrapper to `/home/glinkd/glinkd` and
`/home/glinkd/glinkd_init_patch.so`.

If `/home/glinkd/glinkd` is an ELF binary, the install step preserves it as
`/home/glinkd/glinkd.real` and then installs the wrapper as `/home/glinkd/glinkd`.

`pwserver.sh` starts `./glinkd gamesys.conf 1`, which now runs the wrapper.
The wrapper sets `LD_PRELOAD` and `exec`s the real `glinkd.real` binary.

## Manual setup

If you already have a real `glinkd` binary at `/home/glinkd/glinkd`:

```bash
mv /home/glinkd/glinkd /home/glinkd/glinkd.real
cp glinkd /home/glinkd/glinkd
cp glinkd_init_patch.so /home/glinkd/glinkd_init_patch.so
```

Then `pwserver.sh start` will run `glinkd` with the license check bypassed.

## Notes

The hardcoded offsets in `init_patch.c` (`0x16ff40`, `0x946268`, `0x946270`,
`0x946220`, `0x946274`) were extracted from the real `glinkd` binary with
`objdump` and are specific to that build. If you replace `glinkd.real` with a
different binary, these offsets may need to be updated.
