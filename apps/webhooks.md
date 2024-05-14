Webhooks allows for push-model messages using HTTP.
You configure the webhook in some app or API, to `POST` a message to your server.
(This is different than OAuth flows.)

To implement a webhook, you need to create a dynamic HTTP or HTTPS server that runs some code when receiving the message.

Technologies you can use:
- Persistent server configured to run some simple web server on launch
	- Pros: don't need to depend on the cloud
	- Cons: maintaining server, manual deployment
- Cloud Function like AWS lambda:
	- Pros: trivial integration with cloud services on the same account; cheap; scales
	- Cons: installing dependencies could be hard, limited choice of language runtimes; limited execution duration
-  Bespoke dynamic server site:
	- [ ] Try [Val Town](https://docs.val.town/guides/creating-a-webhook/) tool next time I need a webhook without cloud dependencies