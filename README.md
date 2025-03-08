# GCP PAM to slack

GCPs PAM solution can send notifications to email and pub/sub, but who wants to read emails?
This small app is built to be run in cloud run to be as cost efficent as possible.
It listen to the PAM pub/sub topic and forward the messages to the correct slack channel based on config.
