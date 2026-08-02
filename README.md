# Meme Maze level packs

This public repository is the data-only delivery source for future Meme Maze
level packs. It is intentionally separate from the game application and from
other projects.

## Live content

- Pack 2: Rising Panic — Levels 17–24. It is a data-only JSON pack delivered
  over HTTPS. The installed game verifies its SHA-256 before making levels
  available, then keeps it playable offline.

## What belongs here

- signed level-pack manifests;
- JSON level definitions that use mechanics already present in the installed
  app;
- original game assets required by a level pack; and
- documentation and checksums for those files.

## What must never belong here

- Dart, Java, Kotlin, JavaScript, native libraries, APKs, AABs, or any other
  executable code;
- private signing keys, secrets, credentials, or API keys; and
- unlicensed third-party art, audio, trademarks, or memes.

The game must fetch this content only over HTTPS, after a player confirms the
pack and sees its download size. It must validate the manifest signature,
checksums, schema, and allowed component types before caching content locally.
If any validation fails, the app keeps using its bundled offline levels.

## Publishing a pack

1. Create a versioned folder under `packs/`.
2. Add its level JSON and only approved original assets.
3. Run the game project's level validation and manual playthrough.
4. Generate checksums and sign the manifest using the offline private key.
5. Commit the resulting *public* manifest and content files.
6. Test download, offline cache, corrupted-file rejection, and unlock flow in
   the app before announcing the pack.

The bootstrap `manifest.json` is deliberately unsigned and contains no pack.
The app must reject it until the secure remote-pack feature is implemented and
the first real manifest is signed.
