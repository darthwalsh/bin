#ai-slop

The core question signing answers: **who vouches for this binary?** But "who" means different things depending on the ecosystem.

## Two trust models: distributor-centric vs developer-centric
Most ecosystems use one of two models:

**Distributor-centric (Linux distros, RPM, Flatpak, Snap)**
- The repo/distro is the trust root
- Distro finds upstream source, builds it themselves, signs the output with their key
- Users trust the distro; they don't need to know or trust each upstream author individually
- Example: Red Hat builds ripgrep from source, signs the RPM with Red Hat's GPG key. The fact that BurntSushi wrote ripgrep is not part of the trust chain.

**Developer-centric (Android/APK)**
- The developer's signing key is baked into the app's identity forever
- App identity = `(package name, signing key)` — both must match for an update to be accepted
- No central authority required in theory — any developer can distribute APKs directly
- Trust follows the key, not the distributor

## Linux distros must build from source
The distro-builds-from-source model is not just about signing.
On Linux, a "distro" builds and signs packages so they can:

- Apply patches (security fixes, distro-specific tweaks)
- Compile with their specific toolchain and flags
- Verify reproducibility and supply-chain integrity
- Control the dependency graph (shared libraries, not bundled ones)

## Android is the outlier — one signed APK is broadly distributable

Android inverts this. The developer produces one signed `.apk` (or `.aab`), and that same artifact can be installed on any Android device worldwide without being repackaged by anyone. There's no "distro build" step. This has real advantages:

- No central authority needed for distribution
- Developer controls the full update chain — only the key holder can ship an update
- **Anti-takeover property**: a distributor cannot silently replace your app, because an update with a different signing key fails at the OS level
- App data is isolated by `(package, key)` — different signer = different app, even with the same package name

The downside: this makes alternative distributors like [F-Droid](https://f-droid.org/) architecturally awkward. F-Droid historically signed apps itself (becoming the "developer" in Android's eyes), which breaks compatibility with Play Store versions of the same app. [F-Droid has been shifting](https://f-droid.org/2023/09/03/reproducible-builds-signing-keys-and-binary-repos.html) toward reproducible builds matching upstream APK, then distributing upstream signatures where possible.

## Why F-Droid can't just "be the distro" on Android

If F-Droid signs `com.example.app`, that becomes a permanently different app from the Play Store version:

- Cannot update between them in-place (OS rejects it as a signature mismatch)
- App data from one version doesn't transfer to the other
- Signature-based app cooperation (plugins, companion apps, autofill) breaks across versions
- F-Droid [explicitly refuses](https://f-droid.org/2025/09/29/google-developer-registration-decree.html) to "take over" upstream app identifiers, because it would seize exclusive distribution rights

The practical impact with good apps (export/account sync): switching between Play and F-Droid versions requires an uninstall + reinstall + data migration, but is otherwise manageable. The harder problems are signature-gated integrations and keeping all apps in an ecosystem on the same source.

## Google's developer verification (2026) adds identity on top of signing
In August 2025, [Google announced](https://developer.android.com/developer-verification) that starting September 2026, all apps on certified Android devices must be registered by verified developers. This adds:

> Signing key (cryptographic) + registered developer identity (Google's registry)

This is not a change to Android's signing model — APK signatures still work the same way. It's a policy layer requiring the signer to be a Google-verified identity. The [24-hour "advanced flow"](https://www.theverge.com/tech/897420/android-sideloading-unverified-developers-process) for sideloading from unverified developers is a partial concession after community pushback, but the underlying direction is clear.

F-Droid's objection is principled: the model assumes every app maps to a single verified developer identity, which doesn't fit a distributor-centric repo that builds and redistributes apps from many authors without "taking over" their identities. See [keepandroidopen.org](https://keepandroidopen.org/).

## AAB and Play holding the signing key
[Android App Bundle (AAB)](https://developer.android.com/guide/app-bundle) changed the signing flow: developers upload an AAB to Play, and Google's servers generate optimized APKs split by device configuration. To do this, Google must hold the signing key for the final APKs. This is [Play App Signing](https://developer.android.com/studio/publish/app-signing#app-signing-google-play).

What this means in practice:
- The developer uploads an "upload key"-signed AAB; Google re-signs the delivered APK with a "deployment key" that Google holds
- The developer can provide their own deployment key, or let Google generate one
- **Google becomes the effective signer** for the delivered artifact — closer to the distributor-centric model
- If your app is enrolled in Play App Signing, you cannot distribute the same Google-signed APK outside Play (you'd need to re-sign it with your own key, creating a signature mismatch)

This quietly moves Android toward a hybrid: developer identity for verification purposes, but Play as the actual signer for Play-distributed apps. It makes Play-vs-F-Droid switching even harder for AAB-published apps.

## Gotchas

- "App signing" in Android docs often conflates three distinct things: the upload key (developer → Play), the deployment key (Play → device), and the app identity key (used for update/permission checks). They can all be different.
- Reproducible builds help F-Droid verify correctness, but don't resolve the signing-identity tension — the output APK still needs to be signed by *someone*.
- GrapheneOS supports apps that use standard Android hardware-backed attestation instead of Google Play Integrity; apps that hard-require Play Integrity's "strong" tier may fail on GrapheneOS. See [GrapheneOS attestation compatibility guide](https://grapheneos.org/articles/attestation-compatibility-guide).

## Followups

- [ ] I'm still trying to understand F-Droid's perspective. The problems above seem minimal or "how it should be." and signing is the future.
- [ ] Understanding how Windows fits into this, with signing different [[package.install]] formats and windows runtime (Defender?) blocking potentially malicious apps at runtime. No hobbyists seem to mad about it. (.NET strong name was a kind of signing, but Microsoft Authenticode signing is what matters? And those certs weren't $25, it was like $160 in 2015?)
- [ ] Understanding how AAB changes the ownership model; Google is now the owner of these AAB apps, so F-Droid could just take over ownership? Share the signing private key together with the app owners?
- [ ] For F-Droid or other repos, is it common to do something like "look for git commit signing" as a way to prove the git repo is legit?
