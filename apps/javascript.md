
## Import Maps
https://caniuse.com/import-maps shows Baseline 2023
https://github.com/WICG/import-maps
>proposal allows control over what URLs get fetched by JavaScript `import` statements

If you create the map
```json
{
  "imports": {
    "moment": "/node_modules/moment/src/moment.js",
    "@material/": "https://unpkg.com/material-components-web@latest/dist/material-components-web.min.js"
  }
}
```

Then the code
```js
import moment from "moment";
import { list as MDCList } from "@material"
```
behaves like
```js
import moment from "/node_modules/moment/src/moment.js";
import { list as MDCList } from "https://unpkg.com/material-components-web@latest/dist/material-components-web.min.js"
```
- [ ] For my next JS import modules project, try this!