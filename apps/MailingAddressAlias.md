#ai-slop
## Problem to solve with physical addresses

I’m trying to make **sending physical letters to a moving person** work more like email: the sender uses a **stable identifier** for the recipient, and the underlying system resolves that identifier to the recipient’s **current deliverable physical location**.

Stated differently: I want a way for someone to mail me a letter **without needing to learn (or keep updated) my real mailing address**, even if I move. I want to be able to move without my contacts having to update their address book.

## Requirements and Constraints

This needs to work in the “physical mail” world.
- **Physical letters only**: the system must result in a deliverable real-world postal item, routed through ordinary postal logistics.

The sender experience must not require special knowledge.
- **No “teach every sender a new workflow”**: the sender should be able to address an envelope in a familiar way.
- **Looks like a real mailing address**: the alias should be syntactically compatible with typical address-entry and validation systems (i.e. a format analogous to a P.O. Box).

The recipient identity needs to stay stable across moves.
- **Person-level stability**: the identifier is meant to “track me as a person,” not permanently bind to a single physical location.
- **Contacts shouldn’t need to update**: a sender can keep using the same alias even after I relocate.

There must be some “resolution” step somewhere.
- **Some party must map alias → current deliverable address** at the time of delivery (conceptually like DNS resolution for email routing).
- **I must be able to update my mapping** when I move (a mechanism for the individual to inform the system/mail carrier of the new destination).

I care a lot about ergonomics and automation APIs.
- **Works with “autofill” flows**: I want address-entry UX similar to email-alias generators, where a tool can generate a fresh alias at checkout/address entry time.
- **Password-manager-friendly**: a password manager should be able to autofill an address while also triggering creation/registration of the alias.
- **Programmatic management interface**: I anticipate a need for an API surface (e.g., an OAuth-style delegated authorization model) so third-party tools can create/manage aliases on my behalf.

## Non-goals / explicit exclusions from your statements
- **Not interested in a conventional mail-forwarding/virtual mailbox service** as the primary answer--this requires trusting a private third party, and costs money to deliver an inefficient service.
- **Not an address-key for a place**: I’m not looking for persistent identifiers that merely label a fixed physical address; I want identity-level persistence across moves.
	- **India's DIGIPIN:** geocoordinate-derived identifier for locations. [Wikipedia](https://en.wikipedia.org/wiki/National_Level_Addressing_Grid)
	- **Google's Plus Codes:** encodes a location into a short text code. [Wikipedia](https://en.wikipedia.org/wiki/Open_Location_Code)
	- **Geohash** encodes lat/long into a short string with hierarchical precision. [Wikipedia](https://en.wikipedia.org/wiki/Geohash)

## RFC sketch: Postal Alias Addressing (PAA)
This is a high-level, “shape of the protocol” sketch for a carrier-integrated aliasing system that preserves normal-looking postal addresses while letting me rotate/revoke aliases and update delivery destinations when I move. It assumes USPS is willing to implement the carrier-side logic.

### Abstract
Postal Alias Addressing (PAA) defines a mechanism for generating and using **alias mailing addresses** that look like ordinary postal addresses (e.g., P.O. Box-like syntax), but are resolved by participating carriers to a recipient’s **current deliverable destination address** at time of processing.

### When do I need PAA?
I need PAA when I want any sender (a friend, a merchant, a government office) to mail me something using a stable address token, without learning my true home address and without having to update their records when I relocate.

### Stakeholders (who must understand this)
PAA only works if *very few* stakeholders need to know the address is special. Most systems should treat a PAA alias as a boring, valid postal address string that passes existing validation.

Stakeholders that **must** understand PAA:
- **Carrier operations (e.g., USPS)**: recognizes the alias format, routes it to the right internal resolver, and performs alias → destination resolution at processing time.
	- **Carrier software vendors / sorting equipment vendors**: implement the lookup + relabel/forward logic.
- **Recipient (me)**: creates/rotates aliases and sets the current destination.
- **Automation clients** (password managers, browser autofill, e-commerce plugins): optionally create/fill aliases with explicit user consent (and manage them via delegated auth).

Stakeholders that **do not** need to understand PAA (by design):
- **Senders**: write what looks like a normal postal address; no special steps.
- **Address-entry ecosystems** (merchant checkout forms, CRMs, address validation tools): accept the alias as syntactically valid and store it like any other address.

### Address format (looks like a P.O. Box)
PAA aliases should be formatted to survive typical address validators and human workflows. A simple approach is to reserve a carrier-recognized “ingress” facility and encode the alias token into a P.O. Box-like field.

Example (illustrative; not normative):

- **Name**: `Jane Q Public`
- **Address line 1**: `PO BOX PAA-7H3K-9Q2M`
- **City**: `WASHINGTON`
- **State**: `DC`
- **ZIP**: `20001`

Important property: the printed City/State/ZIP are “ingress routing” fields that get the item into the carrier’s PAA resolution path. They may not match the ultimate destination where the piece is delivered.

### Resolution model (what the carrier does)
PAA defines a carrier-internal resolution step:
- **Parse**: extract alias token from the address (e.g., from the PO BOX field).
- **Lookup**: query a carrier-operated PAA registry for the token’s current destination and policy (active/expired/revoked, delivery constraints).
- **Transform**: replace the alias address with the resolved destination address (optionally applying routing labels/barcodes).
- **Deliver**: proceed through normal routing to the resolved destination.

PAA’s critical invariant is that senders never need to know the resolved destination, and only the carrier (or a delegated resolver operated under carrier authority) can perform resolution.

### Alias lifecycle (what a user can do)
PAA requires these basic operations:
- **Create alias**: mint a new alias token (optionally per-merchant/per-relationship).
- **Revoke alias**: stop delivery (e.g., if an alias starts attracting junk mail).
- **Update destination**: change the resolved destination of all my aliases when I move.

### Updating my destination address (carrier-facing mechanism)
PAA needs an authenticated channel for me to change where aliases resolve to, without exposing my destination to senders.
High-level options (not mutually exclusive):

- **Online account + identity proofing**: I sign in to a carrier account and submit a destination update (similar to a change-of-address flow, but scoped to aliases).
- **In-person verification**: I update the destination at a post office with identity verification, for high-assurance changes.
- **Delegated API updates**: a trusted client (e.g., my password manager) can update destinations only if I explicitly grant a token with that scope.

Operational detail the carrier must support: updates can be **effective-dated** (e.g., “start delivering to the new destination on 2026‑01‑01”) to avoid lost mail during a move.

### Programmatic management (password managers + OAuth)
To support password-manager-style generation at checkout, PAA includes an API surface plus delegated authorization.

PAA’s management API conceptually needs:
- **An OAuth 2.0 authorization server** (e.g., “Sign in with USPS”) that can mint tokens scoped to alias management.
- **A resource API** for alias operations (create/rotate/revoke/update destination) and returning a formatted address bundle suitable for autofill.

Example scopes (illustrative):
- `paa.aliases:create`
- `paa.aliases:revoke`
- `paa.destination:update`

The intended UX: my password manager requests a narrowly scoped token, then creates an alias and receives back a standard postal-looking address to autofill into merchant forms.

### Password-manager autofill flow (one possible UX)
The autofill integration should feel like email alias generators: I pick “Create new mailing alias”, and everything else is automatic.

At a high level:
- **Authorize once**: I grant my password manager `paa.aliases:create` (and optionally `paa.aliases:revoke`) via OAuth.
- **Create per-merchant alias**: the password manager calls “create alias” with metadata like the merchant domain/name for my own bookkeeping.
- **Return an address bundle**: the API returns fields that fit typical checkout forms (name, address line 1, city, state, ZIP).
- **Autofill**: the password manager fills the merchant form with the alias address.
- **Later changes**: if I move, I update the destination once in the carrier system; existing aliases keep working without touching merchant accounts.

## Solution without USPS involvement
What would work while **avoiding postal-carrier involvement**? The alias solution is a non-starter. 

Instead, we could rely on sender-side lookup: I publish a machine-readable “current mailing address” record on the internet, and senders (or their tooling) resolve it *before* mailing and print a normal destination address.

**However**, this breaks the “sender doesn’t need special steps” requirement (unless address book / merchant tooling adopts it).

This also runs into a modern privacy constraint: it used to be normal for home addresses to be widely listed (e.g., White Pages), but today I generally want my physical mailing address to be private. That means “publish it on the internet” needs a clear story for authentication and leakage.

Some possible solutions:
- DNS: create a TXT record for your personal domain, that points to your mailing address.
	- ⚠️ OOPS! DNS is designed to be public. Even if you use an unguessable record name, DNS data can leak via logs, passive DNS, and zone-transfer/hosting mistakes. DNS doesn’t give you real “only authenticated senders can see this” access control.
- Decentralized Identifier (DID) Document: publish a signed [DID Document](https://www.w3.org/TR/did-core/) that resolves to your current mailing address.
	- ⚠️ OOPS! Many DID methods are effectively public by default (and some are anchored to public ledgers). A signature proves authenticity/integrity, but it doesn’t make the contents secret.
- URL: publish a contact document at a stable URL 
	- e.g. `https:/your-server.me/.contact`, or see [RFC 8615 (.well-known URIs)](https://datatracker.ietf.org/doc/html/rfc8615)
	- Ideally using a standard JSON contact format like [JSContact (RFC 9553)](https://www.ietf.org/rfc/rfc9553.html)
	- Optionally advertise/discover it via [WebFinger (RFC 7033)](https://datatracker.ietf.org/doc/html/rfc7033).
	- Authentication is at least possible here (HTTP auth, OAuth, client certs, etc.), but a “secret URL with a token in the path/query” is a brittle capability: it can leak through referrers, logs, screenshots, forwarding, browser history, and email threads.
