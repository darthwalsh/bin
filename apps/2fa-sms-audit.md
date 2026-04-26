#app-idea
## SMS audit: identify top 2FA senders
Goal: export 2 years of Android SMS, find which services send the most OTP codes → prioritized list for passkey/TOTP migration.

- [ ] Run this audit and build migration checklist

**Step 1 — Export SMS from Pixel**: Use e.g. [SMS Backup & Restore by SyncTech](https://play.google.com/store/apps/details?id=com.riteshsahu.SMSBackupRestore), export as XML.

**Step 2 — Parse with Python**

Some AI-generated started code:
```python
import xml.etree.ElementTree as ET
import re
import time
from collections import Counter

tree = ET.parse("sms.xml")
root = tree.getroot()

otp_pattern = re.compile(r"\b\d{4,8}\b")
two_years_ago = time.time() - (2 * 365 * 24 * 3600)
senders = Counter()

for sms in root.findall("sms"):
    date = int(sms.attrib.get("date", 0)) / 1000
    if date < two_years_ago:
        continue
    body = sms.attrib.get("body", "")
    address = sms.attrib.get("address", "")
    if otp_pattern.search(body) and any(k in body.lower() for k in ["code", "otp", "verification"]):
        senders[address] += 1

for sender, count in senders.most_common(20):
    print(f"{sender}: {count}")
```

**Caveats:**
- Sender IDs are short codes / aliases (`AMZN`, `74681`), not domain names — requires manual mapping
- OTP detection is heuristic; some false positives/negatives
- Optional: extract probable site name with `re.search(r"(?:for|to)\s+([A-Za-z0-9.\-]+)", body)`

**Interpretation:** high-frequency senders + financial/critical accounts = highest ROI for migration to passkeys or TOTP in 1Password.
