# Player Finder — LeviLauncher

Fresh arm64-v8a native-mod bootstrap for LeviLaunchroid / LeviLauncher.

## Current stage

This build is deliberately a **safe bootstrap**. It verifies that the native `.levipack`, `PL_REGISTER_MOD` lifecycle, and LeviLauncher packaging work before any Minecraft entity hooks or offsets are added.

It does **not** yet implement ESP/player enumeration. Bedrock client internals are version-dependent, so those hooks should be added only after the bootstrap loads cleanly on the exact Minecraft build.

## GitHub Actions

Push to `main`, open a pull request, or use **Actions → Build Player Finder → Run workflow**.

The workflow installs Android NDK `28.2.13676358`, builds the `arm64-v8a` target, and uploads:

`PlayerFinder-levipack-arm64`

The artifact contains:

`player_finder-0.1.0-arm64-v8a.levipack`

For a GitHub Release, create a tag such as `v0.1.0`; the workflow also attaches the `.levipack` to that release.

## Install

Download the workflow artifact, extract the ZIP produced by GitHub Actions, then import the `.levipack` into LeviLauncher.

## References

Based on the current LeviLaunchroid native-mod template and full C++ lifecycle example.
