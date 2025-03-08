# GCP PAM to slack

This app is built to be run in cloud run to be as cost efficent as possible. It listens
to the PAM pub/sub topic and forward the messages to the correct slack channel based on config.

## Goals

- Listen to GCP pub/sub subscription for PAM messages
- Depending on config based on GCP project name forward the request to a specific Slack channel
- In the Slack message forward a direct link to the approval
- After getting a approval/deny update the thread of the initial message sent.
- Store the PAM request id together with the slack id/time in a Firestore database
