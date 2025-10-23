#app-idea 
The Spinnaker website can involve a minute of manual effort to click into an error.
I want a dev tool to diagnose Spinnaker pipeline failures quickly.
Tool will automatically traverse the pipeline execution graph and child pipelines, and surface the deepest error or console message. 

## How to auth?
Spent a while digging into this with ChatGPT: https://chatgpt.com/share/68ebebb4-4c8c-8011-90a2-f27ff39ba374
I can run:
```
http 'https://spinnaker-api.example.net/pipelines/THE_EXECUTION_ID' Cookie:SESSION=$TOKEN
```
and get results...

But in order to get the session cookie i have to open the spinnaker website, which defeats the purpose!
There are plenty of [documented auth methods](https://spinnaker.io/docs/setup/other_config/spin/#configure-spin) to the spinnaker Gate API endpoint, but I don't think any are usable on our instance.