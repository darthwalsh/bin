Laws are arriving faster than the privacy-preserving infrastructure to implement them. The result: platforms default to "upload your ID" because it's immediately available, even though better solutions exist.

## Attestation vs verification: CA AB 1043 calls itself "verification"

California's [AB 1043](https://legiscan.com/CA/text/AB1043/id/3269704) (Digital Age Assurance Act, effective Jan 1, 2027) is actually an **attestation** system — a parent enters a child's birthdate at device setup, no identity check occurs. Yet nearly all press coverage calls it "age verification." This terminological slippage matters: once the public calls self-declaration "verification," we lose the vocabulary to recognize when a genuinely strict law arrives.

- **Attestation**: user/parent self-declares age; platform records it
- **Verification**: platform independently confirms age via a third party or ID check

## The missing Linux primitive: OS-level age bracket signal

Linux has had decades to build a standardized parental/child-profile signal, and hasn't. The AB 1043 anxiety in the Linux community is partly deserved: if the ecosystem had shipped something like a standardized age-bracket API years ago, lawmakers would have had less reason to mandate it.

A minimal design embodying "everything is a file":
- API is a file that works across Flatpak/Snap/native package sandboxing
- Expose only derived age brackets: `<13`, `13–15`, `16–17`, `18+` — matching AB 1043's buckets
- Allow child birthday or age to be settable by the machine admin, while adult birthday is anonymized to e.g. `1970-01-01`

Hardening a linux machine to allow circumvention through creating a new account / installing a 2025 app / VM / live USB boot is left as an exercise to the reader.
## Zero-knowledge age proofs solve most of the problem too late

Zero-knowledge proofs let you prove a *statement* about a credential without revealing the credential itself. The classic age use case at a bar:

> "Prove you are over 21 without revealing your date of birth."

The system has three roles:
- **Issuer**: trusted authority that signs a credential attesting to your age (e.g. DMV, passport office, etc. gov agency)
- **Holder/Wallet**: software you control that stores the credential and generates proofs
- **Verifier**: the "digital bartender" that receives only the proof — a boolean result

The verifier learns "this person is over 21" and nothing else. The issuer doesn't learn where or why you used the proof (in offline-verification designs).

**Production-ready options in 2026:**
- [mDL/mdoc (ISO/IEC 18013-5)](https://www.iso.org/standard/69084.html): mobile driver's license standard. Supports `age_over_18`, `age_over_21` boolean attributes. Not full ZK in the [SNARK](https://www.cryptologie.net/posts/the-missing-explanation-of-zk-snarks-part-1/) sense, but privacy-minimizing selective disclosure. Most mature government-aligned path.
- [AnonCreds](https://www.lfdecentralizedtrust.org/projects/anoncreds): true ZK predicate proofs ("prove DOB implies age ≥ 18") with non-correlation goals. Built on Hyperledger. Closest to the "digital bouncer" mental model.
- [OpenID4VP](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html) + SD-JWT VC: web protocol plumbing for credential presentation. Good for selective disclosure; not inherently ZK unless the credential itself is structured for predicate proofs.

**Why ZK age proofs aren't everywhere yet** — the blockers are non-cryptographic:
- Issuer rollout is slow: the proof is only useful if a DMV/government actually issues the credential in the first place
- Biometric binding (the "older brother's phone" problem): a ZK proof proves a statement about a credential, not that the presenter is the rightful holder — real systems need enrollment controls and device binding. Do you have to demonstrate a fingerprint unlock of your own phone to the bartender?
- Regulators often demand "highly effective" verification, and ID/selfie vendors can claim compliance today while ZK ecosystems are still building out

Good explainers: [Brave on ZK age verification limits](https://brave.com/blog/zkp-age-verification-limits/), [EFF on ZK proofs and digital ID](https://www.eff.org/deeplinks/2025/07/zero-knowledge-proofs-alone-are-not-digital-id-solution-protecting-user-privacy).

## EU Digital Identity Wallet and GrapheneOS

The [EU Digital Identity Wallet](https://digital-strategy.ec.europa.eu/en/policies/eudi-wallet-implementation) (deadline: end of 2026) is a framework, not a single app — each member state ships its own wallet that complies with the [Architecture and Reference Framework (ARF)](https://github.com/eu-digital-identity-wallet/eudi-doc-architecture-and-reference-framework). 

GrapheneOS compatibility depends entirely on whether a given national wallet hard-requires [Google Play Integrity](https://discuss.grapheneos.org/d/29036-play-integrity-api) (which often blocks alternate Android OSes) vs. standard Android hardware-backed attestation (which GrapheneOS supports per its [attestation compatibility guide](https://grapheneos.org/articles/attestation-compatibility-guide)).

- Germany's published guidance explicitly references Play Integrity as an integrity mechanism.
- Sweden, Croatia, and Estonia have not published clear statements on OS-certification requirements. 

In practice, non-smartphone users (Ubuntu Touch, old flip phones) are likely to find mobile-app-first wallet flows inaccessible, though EU implementing regulations technically contemplate external secure devices (smartcards) as alternatives.
