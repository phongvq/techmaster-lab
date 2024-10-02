# Usage

This script send allow user to perform healthcheck for particular services, and send alert(s) to specified recepient.


Environment variables:
- `SERVICES`: list of services to be monitored, separated by comma(s) `,`.
- `LOGFILE`: path to log file
- `EMAIL`: email to send alert to


__Note__: you need to install your mail service in server first. For reference: https://www.digitalocean.com/community/tutorials/send-email-linux-command-line


# Example

```bash
SERVICES=docker,networkd LOGFILE=a EMAIL='example.com' bash service_healthcheck.bash

```

Output:


```txt
docker is running.
networkd is down!
Alert email sent for networkd.

```
