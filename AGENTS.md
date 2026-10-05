# My NixOS fleet

This repo describes my (Ivan's) fleet of NixOS powered machines.

## Commit style
Follow repo commits style, note that repo is using conventional commits.

## Secrets Policy
- Don't access secrets, you allowed to get only shape of objects from encrypted files. Attempts of secrets descryption will be flagged and session will be stopped immediately.
- Nonsecrets included repo in flake contains only low value secrets, but u also allowed access only objects shape.

