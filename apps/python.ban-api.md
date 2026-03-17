- [ ] #ai-slop test if this works
## Not sure how to ban use of API
https://chatgpt.com/share/68507ea6-56ec-8011-b0fe-ac37e4276a7e
Can prevent imports:
```toml
[tool.ruff]
select = ["TID", ...]  # TID is for tidy-imports

[tool.ruff.flake8-tidy-imports.banned-api]
"PyQt5.QtWidgets.QMessageBox.information" = "Use a custom dialog instead of QMessageBox.information"
```

Then for
```python
from PyQt5.QtWidgets import QMessageBox

QMessageBox.information(None, "Title", "Message")
```
would get warning
>TID252: Use a custom dialog instead of QMessageBox.information

- [ ] But ChatGPT says this couldn't be prevented??

```python
import PyQt5

PyQt5.QtWidgets.QMessageBox.information(None, "Title", "Message")
```
