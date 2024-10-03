# Before running

- make sure use [install gcloud cli](https://cloud.google.com/sdk/docs/install).
- run `gcloud auth login` to authenticate with your GCP project. See [this link](https://cloud.google.com/sdk/gcloud/reference/auth/login).
- configure project `gcloud config set project <your_gcp_project_id>`

# Usage

- `create_gce_instance.bash` creates VMs based on name, CPU, Ram, Disk size, zone that user set (via environment variables, see belows.)
- other specs not included in this PoC
- there are limitation, you cannot input whatever you want. See more in [this GCP documentation](https://cloud.google.com/compute/docs/instances/creating-instance-with-custom-machine-type).


```bash
export VM_NAME="my-custom-vm"
export CPU=2                # Number of vCPUs
export RAM=1024             # Memory in MB (e.g., 8192 for 8GB)
export DISK_SIZE=100        # Disk size in GB
export ZONE="asia-east1-a"  # Specify your desired zone

bash create_gce_instance.bash
```


Example output:
```txt
WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
Created [https://www.googleapis.com/compute/v1/projects/xxx/zones/asia-east1-a/instances/my-custom-vm].
WARNING: Some requests generated warnings:
 - Disk size: '100 GB' is larger than image size: '10 GB'. You might need to resize the root repartition manually if the operating system does not support automatic resizing. See https://cloud
ompute/docs/disks/add-persistent-disk#resize_pd for details.

NAME          ZONE          MACHINE_TYPE                   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
my-custom-vm  asia-east1-a  custom (e2, 2 vCPU, 1.00 GiB)               x.x.x.x      x.x.x.x        RUNNING
VM 'my-custom-vm' created successfully with 2 vCPUs, 1024 MB RAM, and a boot disk of 100GB.
```
