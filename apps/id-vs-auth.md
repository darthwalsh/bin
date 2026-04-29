# Identifier vs Authenticator

A common design failure: treating a government identifier as a secret password.

**Identifier**: a label that uniquely names you — meant to be looked up, shared, referenced.
**Authenticator**: a secret you present to prove you're you — meant to be kept private, rotatable.

When these two roles collapse into one value, you get a system that is both fragile and hard to fix.

## The SSN problem: America's accidental password

The US [Social Security Number](https://en.wikipedia.org/wiki/Social_Security_number) was designed in 1936 as an account number for the Social Security program. It was never designed to be a secret. For decades, SSNs appeared on mail, Medicare cards, military dog tags, and university IDs.

Over time, financial institutions and government agencies began using it as an authenticator — "tell me your SSN to prove you're you." Now it plays both roles simultaneously, which makes it:

- **Non-rotatable**: you can't get a new SSN (in almost all cases)
- **Widely shared**: decades of exposure to employers, insurers, universities, banks
- **High-value target**: worth stealing because it unlocks credit, identity fraud, and tax returns
- **Impossible to deprecate**: too deeply embedded in US infrastructure

See [CGP Grey's video on the Worst ID System](https://www.youtube.com/watch?v=Erp8IAUouus) for a fun explainer on how this design failure became entrenched.

### What would happen if all 300M+ SSNs leaked publicly?
If a hacker dumped every US SSN in a public database (together with jobs and address history, like docusign asks to prove identity), it would cause years of chaos — fraudulent tax returns, identity theft, credit fraud at scale. But the long-term outcome might actually be positive: it would force a reckoning that the SSN cannot serve as an authenticator. Institutions would have to adopt real authentication. (Knowledge-based questions would also collapse; we'd hopefully be pushed toward cryptographic or physical authenticators and [[2fa]].)

The painful truth is that partial leaks (Equifax 2017: ~147M records; various breaches of similar scale) have not been sufficient to force this reckoning, because the damage is diffuse and the status quo is cheap for institutions.

> [!QUESTION] Conspiracy Theory: CPI for Identity Theft Protection
> I wonder if Equifax managed to *make* money after the 2017 data breach, as the settlement involved offering free identity theft protection *on their own platform!* Considering the Cost per Install of their existing marketing, what would the CPI for this funnel be? But to ground myself in reality, if you looked at the stock price change that week, this theory probably doesn't hold water.

## Countries that intentionally make identifiers public
Some countries have explicitly chosen to publish or freely share their national identifier numbers — treating them as pure identifiers, not secrets:

The [Swedish personal identity number](https://en.wikipedia.org/wiki/Personal_identity_number_(Sweden)) (`personnummer`) is widely considered semi-public. The Swedish Tax Authority can provide it on request. It's printed on driver's licenses, used in everyday transactions. Authentication in Sweden uses separate systems: [BankID](https://en.wikipedia.org/wiki/BankID) (cryptographic, phone-based) and the national eID, not the number itself.
Norway, [Estonia](https://en.wikipedia.org/wiki/Estonian_identity_card), and [Finland](https://en.wikipedia.org/wiki/National_identification_number#Finland) have similar approaches.

## Government ID *photos* are different from ID *numbers*
Even in transparency-forward countries, **no country preemptively publishes everyone's ID photo** as a public dataset. The distinction is important:
- ID numbers: unique labels, can be treated as public without enabling impersonation (if real auth exists)
- ID photos: biometric data that enables face recognition, identity fraud, and is non-rotatable (you can't easily change your face)

Even Estonia, with its very open eID system, does not publish a searchable gallery of passport photos.
