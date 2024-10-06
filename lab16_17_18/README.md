
# Note
> This directory covers all 3 k8s labs: 16, 17, 18.

# Install minikube
- If you didn't have k8s yet, follow [this guide](https://minikube.sigs.k8s.io/docs/start) to install minikube.
  - Select your OS, CPU arch, etc.
- For example

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
```
- Minikube supports different driver (virtualization technology). In this demo, we use `docker`.
- Start your Docker Desktop or Docker daemon.
- Then start minikube

```bash
minikube start
```

- Enable `metrics-server` for minikube, so that we can easily view resource usage (cpu, memory) of deployed workload.
```bash
minikube addons enable metrics-server
```

- Install k8s client `kubectl` to interact with minikube. Refer to [this link](https://kubernetes.io/docs/tasks/tools/#kubectl).

```bash
> kubectl version
Client Version: v1.28.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.31.0
WARNING: version difference between client (1.28) and server (1.31) exceeds the supported minor version skew of +/-1

```

__NOTE__: try to install kubectl/minikube as closer version as possible. Avoid above WARNING.


# Deploy application
This directory contains k8s manifest of an simple `echo` app, which returns exactly samething you give it.
- app deployment: manage pods
- app service: route traffic to the pods
- hpa: monitor and scale app when memory higher than a specific threshold (percentage).
  - note: `mem percentage` = `current mem usage` / `mem request` (_NOT_ mem limit)
  - currently number of pods will be between 2 and 5, depends on mem percentage.

Go to this dir and then use `kubectl apply` to deploy everything to minikube

```txt
> kubectl apply -f .

deployment.apps/echo-app created
horizontalpodautoscaler.autoscaling/echo-app-hpa created
service/echo-service created

```

Forward this app to host network, to test if it's working:

```txt
> kubectl port-forward service/echo-service 8080:8080

Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

Use `curl` to send request to the app.

```txt
> curl http://localhost:8080/arandomendpoint
Request served by echo-app-5fd5f6c979-2mqqb

HTTP/1.1 GET /arandomendpoint

Host: localhost:8080
Accept: */*
User-Agent: curl/8.7.1

```

You can see it's echoing the request it received.

# Test autoscaling
In this lab, cpu percentage is set to 1%, so we can easily observe scaling behaviour.

Get all pods (namespace: `default`), to check:

```txt
> kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
echo-app-5fd5f6c979-2mqqb   1/1     Running   0          40s   <-- initial
echo-app-5fd5f6c979-gpj5k   1/1     Running   0          38s   <-- initial
echo-app-5fd5f6c979-lcx2b   1/1     Running   0          23s   <-- first scaling (because mem percentage > 1 %)
echo-app-5fd5f6c979-nzwn6   1/1     Running   0          23s   <-- first scaling (because mem percentage > 1 %)
echo-app-5fd5f6c979-brj5g   1/1     Running   0          8s    <-- second scaling

```
