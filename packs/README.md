# Pack format

Each pack is stored in its own immutable versioned folder, for example:

```text
packs/pack-2-v1/
  pack.json
  levels/level_17.json
  levels/level_18.json
  assets/
```

`pack.json` will declare the pack identifier, player prerequisite, display
name, download size, file hashes, and supported game content version. A pack
must use only platform, goal, trap, and asset types supported by the installed
app. New mechanics require a normal Google Play app update first.
