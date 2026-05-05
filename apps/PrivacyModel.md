This defines my personal privacy philosophy. Cryptographic security tracked in [[ThreatModel]].
## Core Philosophy
Closed platforms (e.g. Google) will profile and microtarget me based on behavioral inferences. My bright line is **data leaving that closed system**. Data brokers, Facebook, political campaigns, and other third parties should be prevented from getting access to sensitive inferences made about me.

Being targeted *within* a system I conditionally trust is an acceptable trade-off for benefits like free services. Having my profile packaged and sold to less scrupulous actors is not.

(This reflects the right set of trade-offs for me, at this phase in my life. I'm not asserting that everyone adopting these views leads to the best systemic outcomes.)
## Trust Boundaries

As with knowing a news outlet's bias: it's not that I trust Google... I just trust them to act in certain ways.

| Actor                      | Trust Level | Rationale                                                                                                   |
| -------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------- |
| Banks                      | Conditional | Highly regulated; limited third-party sharing. Consider your bank's opt-out disclosures                      |
| Google                     | Conditional | Closed ecosystem; data stays within Google's ad system [^google]                                            |
| Apple                      | Conditional | Strong on-device privacy stance; App Tracking Transparency enforcement                                      |
| Microsoft                  | Lowish      | Windows advertising ID are on by default [^microsoft]                                                       |
| Payment networks (Visa/MC) | Low         | Visa paused selling data in 2021, but Mastercard still selling                                              |
| Cell carriers              | Low         | Have sold aggregated location data to third parties; AT&T, Verizon, T-Mobile have all faced FCC enforcement |
| ISPs                       | Low         | Can sell browsing history; use [[dns-over-https]] to limit exposure                                         |
| Facebook                   | Untrusted   | Aggressive cross-site and cross-device tracking; political ad exposure                                      |
| Retail Loyalty Programs    | Untrusted   | Anything beyond a paper punch card means the company has behavioral data to sell                            |

[^google]: With a company as large as Alphabet, I can reasonably trust that my data will stay within the system — they won't be acquired by VC. If broken up by antitrust, I would need to reconsider. Google has all my webmail data, but they claim to have stopped using it for ads; training for [[INBOX zero notes#email-priority]] is welcomed! (There are *other* concerns that might make you want to [[degoogle]].)
[^microsoft]: Windows 11 has opt-out **advertising ID** for cross-app targeted ads... Unlike Google, Microsoft's revenue is primarily enterprise/cloud. The incentive to monetize consumer data is lower, but so is the mechanism to use data in ad auctions without selling.

- [ ] Disable #windows ad id: Settings > Privacy & Security > General
- [ ] Check my bank's opt-outs
- [ ] Does VISA need another row

## What I Accept
- Behavioral profiling and microtargeting *within* a platform I use directly
- Personalized ads based on first-party data
- That platform trust is probabilistic and needs periodic reevaluation
- Software with crash reporting and usage telemetry has a higher chance of sharing PII or fingerprinting my account. But as a dev I appreciate when my users turn this on. My usage and crashes being reported hopefully focus project resources towards my use-cases.
- NSLs, FISA orders, or foreign government compulsion orders bypass the data-broker model entirely; I feel comfortable leaning towards "I have nothing to hide" while rejecting that this must be broadly accepted in a free society.

## What I Reject
- Cross-context data sharing (my profile leaving a platform I chose to use)
- Sensitive inference sharing or de-anonymization (health/politics/finances reaching data brokers)
- Fingerprinting as a tracking vector. It seems too easy for device/browser fingerprinting to let third parties re-identify me

## Children's Privacy
Don't just blindly create a Gmail account for your child? [Proton Mail](https://proton.me/blog/born-private) lets you reserve a `@proton.me` address, held inactive for up to 15 years. Proton is Swiss-based, end-to-end encrypted, no ads or message scanning.

## Further Reading: Reject Convenience
[Reject Convenience](https://www.youtube.com/@rejectconvenience) is a no-sponsor YouTube channel focused on privacy education.

- [I looked into VPN sponsors...](https://www.youtube.com/watch?v=mIwfNw5UaHA): VPNs are advertised as a general privacy solution, but they don't address most real threats (ad tracking, fingerprinting, platform profiling) if you use HTTPS. You're shifting trust to the VPN provider, whose ownership and data practices are often opaque.
- [What DeleteMe and Incogni aren't telling you](https://youtu.be/iX3JT6q3AxA): data deletion services don't cover the full broker ecosystem, and recurring re-ingestion means deletion is never permanent. The real lever is upstream: reducing what gets collected.
    - I felt strongly this should just be a public utility! Well, as of 2026, California residents can use the [DROP (Delete Request and Opt-out Platform)](https://privacy.ca.gov/drop) free government service.
    - [ ] Submit DROP request ⏫
        - [ ] Submit for kids (data brokers build files on minors.)
