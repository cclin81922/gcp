# Tutorial

<walkthrough-watcher-constant key="gke-cluster" value="demo-istio"></walkthrough-watcher-constant>
<walkthrough-watcher-constant key="gke-version" value="1.14.10-gke.27"></walkthrough-watcher-constant>
<walkthrough-watcher-constant key="istio-version" value="1.5.1"></walkthrough-watcher-constant>
<walkthrough-watcher-constant key="istio-profile" value="minimal"></walkthrough-watcher-constant>

## Introduction

<walkthrough-tutorial-duration duration="30"></walkthrough-tutorial-duration>

Click the **Start** button to move to the next step.

## Select A Project

<walkthrough-project-setup></walkthrough-project-setup>

<walkthrough-footnote>NOTE: need owner permission</walkthrough-footnote>

## Setup Cloud SDK

### gcloud

```bash
gcloud config set core/project {{project-id}}
```
```bash
gcloud config set compute/region asia-east1
```
```bash
gcloud config set compute/zone asia-east1-a
```

### gsutil

[~/.boto](https://cloud.google.com/storage/docs/boto-gsutil)

None

### bq

[~/.bigqueryrc](https://cloud.google.com/bigquery/docs/bq-command-line-tool#setting_default_values_for_command-line_flags)

None

### cbt

[.cbtrc](https://cloud.google.com/bigtable/docs/quickstart-cbt)

None

## Enable APIs

<walkthrough-enable-apis apis="container.googleapis.com"></walkthrough-enable-apis>

## Grant Permissions

n/a

## Create GKE Cluster

[doc](https://istio.io/docs/setup/platform-setup/gke/)

use the {{gke-version}} version

```bash
gcloud container clusters create {{gke-cluster}} \
  --cluster-version {{gke-version}} \
  --machine-type=n1-standard-2 \
  --num-nodes 4 \
  --enable-network-policy \
  --zone $(gcloud config get-value compute/zone)
```
```bash
kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)
```

## Install Istio

[available profiles](https://istio.io/docs/setup/additional-setup/config-profiles/)

use the {{istio-version}} version

```bash
curl -L https://istio.io/downloadIstio | ISTIO_VERSION={{istio-version}} sh -
```

add the istioctl client to your path

```bash
cd istio-{{istio-version}}
```
```bash
export PATH=$PWD/bin:$PATH
```

install the {{istio-profile}} profile

```bash
istioctl manifest apply --set profile={{istio-profile}}
```

instruct Istio to automatically inject Envoy sidecar proxies

```bash
kubectl label namespace default istio-injection=enabled
```

verify

```bash
istioctl manifest generate --set profile=minimal | istioctl verify-install -f -
```

## Demo Destination Rule

### Single Namespace

```bash
kubens default
```

deploy sample application

* client in default namespace
* server in default namespace

```bash
kubectl run server --image=gcr.io/google-samples/hello-app:1.0 --replicas=2
```
```bash
kubectl expose deploy/server --port 80 --target-port 8080
```
```bash
kubectl run client --image=gcr.io/gcp-expert-sandbox-jim/debian -- /bin/bash -c 'while true; do sleep 1; date; curl -s server; done'
```

check client logs

```bash
pod=$(kubectl get po -l run=client -o=jsonpath='{.items[0].metadata.name}')
```
```bash
kubectl logs $pod -c client
```

SHOULD BE: round robin

deploy traffic management

* dr in default namespace
* dr export to all

```bash
kubectl apply -f demo-dr/dr.yaml
```

check client logs again

SHOULD BE: sticky one

NOTE: if not sticky one, fix by either
1. re-deploy client
2. deploy demo-dr/vs.yaml


delete traffic management

```bash
kubectl delete -f demo-dr/dr.yaml
```

check client logs again

SHOULD BE: round robin

### Multiple Namespaces

[dr lookup path](https://istio.io/docs/ops/best-practices/traffic-management/#cross-namespace-configuration)

## Demo Virtual Service

### Single Namespace

```bash
kubens default
```

deploy sample application

* client in default namespace
* server-1 in default namespace
* server-2 in default namespace

```bash
kubectl run server-1 --image=gcr.io/google-samples/hello-app:1.0 --replicas=1
```
```bash
kubectl expose deploy/server-1 --port 80 --target-port 8080
```
```bash
kubectl run server-2 --image=gcr.io/google-samples/hello-app:1.0 --replicas=1
```
```bash
kubectl expose deploy/server-2 --port 80 --target-port 8080
```
```bash
kubectl run client --image=gcr.io/gcp-expert-sandbox-jim/debian -- /bin/bash -c 'while true; do sleep 1; date; curl -s server-1; done'
```

check client logs

```bash
pod=$(kubectl get po -l run=client -o=jsonpath='{.items[0].metadata.name}')
```
```bash
kubectl logs $pod -c client
```

SHOULD BE: server-1 pod

deploy traffic management

* vs in default namespace
* vs export to all

```bash
kubectl apply -f demo-vs/vs.yaml
```

check client logs again

SHOULD BE: server-2 pod

deleted traffic management

```bash
kubectl delete -f demo-vs/vs.yaml
```

check client logs again

SHOULD BE: server-1 pod

### Multiple Namespaces

vs lookup path?

## Demo Service Entry

## Demo Gateway

## Clean Up

```bash
TODO
```
