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

(doc)[https://istio.io/docs/setup/platform-setup/gke/]

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

deploy sample application

```bash
kubectl run
```
```bash
kubectl run
```
```bash
kubectl expose
```

check log
```bash
kubectl logs
```

deploy traffic management

```bash
kubectl apply
```

check log
```bash
kubectl logs
```

### Multiple Namespaces

## Demo Virtual Service

## Demo Service Entry

## Demo Gateway

## Clean Up

```bash
TODO
```
