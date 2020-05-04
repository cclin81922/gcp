# Tutorial

<walkthrough-watcher-constant key="compute-region" value="asia-east1"></walkthrough-watcher-constant>
<walkthrough-watcher-constant key="compute-zone" value="asia-east1-a"></walkthrough-watcher-constant>

## Introduction

<walkthrough-tutorial-duration duration="30"></walkthrough-tutorial-duration>

Click the **Start** button to move to the next step.

## Select A Project

<walkthrough-project-setup></walkthrough-project-setup>

<walkthrough-footnote>NOTE: need owner permission</walkthrough-footnote>

## Setup Cloud SDK

### Setup gcloud

```bash
gcloud config set core/project {{project-id}}
```
```bash
gcloud config set compute/region {{compute-region}}
```
```bash
gcloud config set compute/zone {{compute-zone}}
```

### Setup gsutil

About [~/.boto](https://cloud.google.com/storage/docs/boto-gsutil)

None

### Setup bq

About [~/.bigqueryrc](https://cloud.google.com/bigquery/docs/bq-command-line-tool#setting_default_values_for_command-line_flags)

None

### Setup cbt

About [.cbtrc](https://cloud.google.com/bigtable/docs/quickstart-cbt)

None

## Enable APIs

<walkthrough-enable-apis apis="stackdriver.googleapis.com"></walkthrough-enable-apis>

## Grant Permissions

None

## Apply Terraform

```bash
cd terraform
```
```bash
terraform init
```
```bash
terraform plan
```
```bash
terraform apply
```

## Test Alerting

### Test 1

```bash
gcloud compute instances create new-vm-01
```

### Test 2

```bash
gcloud compute ssh new-vm-01 -- fallocate -l 1G 1.0G.img
```
```bash
gcloud compute scp new-vm-01:~/1.0G.img .
```

### Test 3

```
# data size = 1.76 GB

bq query --nouse_legacy_sql --nouse_cache 'SELECT * FROM `bigquery-public-data`.baseball.games_wide'
```

## Clean Up

```bash
cd terraform
```
```bash
terraform destroy
```
