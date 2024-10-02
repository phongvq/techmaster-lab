#!/usr/bin/env bash

# Configuration
email="${EMAIL}"  # Email to send alerts
subject="Service Alert: Down Service Detected"
logfile="${LOGFILE}:-/var/log/service_health_check.log"

# Read services from the environment variable
# Default to "nginx,mysql" if not set
services=${SERVICES:-"nginx,mysql"}

# Convert the comma-separated string into an array
IFS=',' read -r -a service_array <<< "$services"

# Function to check service status
check_service() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        echo "$service is running."
        return 0
    else
        echo "$service is down!"
        return 1
    fi
}

# Function to send email alert
send_alert() {
    local service=$1
    if echo "$service is down on $(hostname) at $(date)" | mail -s "$subject" "$email"; then
        echo "Alert email sent for $service."
    else
        echo "Failed to send alert email for $service." >> "$logfile"
    fi
}

# Main loop to check services
for service in "${service_array[@]}"; do
    if ! check_service "$service"; then
        send_alert "$service"
        echo "$(date): $service is down!" >> "$logfile"
    fi
done

