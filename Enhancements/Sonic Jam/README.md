# Sonic Jam extracted assets for the AS Sonic 1 disassembly

This package splits the uploaded Sonic Jam `.SN1` files into an `Enhancements/Sonic Jam` folder.

Layout:

- `Common/` uses the same relative folder and file names as the AS repo for assets that are not mode-specific.
- `Original/objpos/`, `Normal/objpos/`, and `Easy/objpos/` split the three object-placement tables:
  - `ACTTBL(1).SN1` -> `Original`
  - `ACTTBL_N(1).SN1` -> `Normal`
  - `ACTTBL_E(1).SN1` -> `Easy`
- `_source_sn1/` keeps the uploaded source containers for traceability.
- `_manifests/manifest.csv` lists every extracted file, source container, offset, size, SHA-1, and match note.

The folder structure under each mode mirrors the existing repo, e.g. `objpos/ghz1.bin`, `objpos/platforms/lz1pf1.bin`, etc.

Special note: `TBL.SN1` contains `sslayout/5 (REV01).eni` and `sslayout/6 (REV01).eni` at the expected slots but with a trailing-byte difference from the supplied AS baseline, so those are included as Sonic Jam payloads.
