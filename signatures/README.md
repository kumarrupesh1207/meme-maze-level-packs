# Signing policy

Only public signatures and public-key identifiers belong in this folder.

The Ed25519 private signing key is generated and retained offline by the
publisher. It must never be committed, uploaded, emailed, or placed in a
GitHub secret that can be exposed to an automated workflow.

The installed game will embed the matching public key and reject any manifest
whose signature is missing or invalid.
