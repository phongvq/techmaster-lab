#!/usr/bin/env bash


#!/bin/bash

# Check if required environment variables are set
if [[ -z "${VM_NAME}" || -z "${CPU}" || -z "${RAM}" || -z "${DISK_SIZE}" || -z "${ZONE}" ]]; then
    echo "Error: Please set the following environment variables: VM_NAME, CPU, RAM, DISK_SIZE, ZONE"
    exit 1
fi

# Construct the machine type based on CPU and RAM
MACHINE_TYPE="e2-custom-${CPU}-${RAM}"

# Create the VM using gcloud
# Ofc, we can allow user to specify image-family, image-project or any other spec
# but I keep only cpu, mem, disk, name for poc purpose
gcloud compute instances create "${VM_NAME}" \
    --machine-type "${MACHINE_TYPE}" \
    --zone "${ZONE}" \
    --boot-disk-size "${DISK_SIZE}GB" \
    --image-family debian-11 \
    --image-project debian-cloud

# Check if the VM creation was successful
if [[ $? -eq 0 ]]; then
    echo "VM '${VM_NAME}' created successfully with ${CPU} vCPUs, ${RAM} MB RAM, and a boot disk of ${DISK_SIZE}GB."
else
    echo "Failed to create VM '${VM_NAME}'."
fi

