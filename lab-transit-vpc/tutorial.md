# Tutorial

<walkthrough-watcher-constant key="job-name" value="select-1"></walkthrough-watcher-constant>

## Introduction

<walkthrough-tutorial-duration duration="30"></walkthrough-tutorial-duration>

Click the **Start** button to move to the next step.

## Select A Project

<walkthrough-project-setup></walkthrough-project-setup>

<walkthrough-footnote>NOTE: need owner permission</walkthrough-footnote>

## Enable APIs

<walkthrough-enable-apis apis="compute.googleapis.com,servicenetworking.googleapis.com,sql-component.googleapis.com,sqladmin.googleapis.com,redis.googleapis.com,container.googleapis.com"></walkthrough-enable-apis>

## Grant Permissions

n/a

## Create VPC

### On-Prem

```bash
gcloud compute networks create on-prem-net --subnet-mode custom
```
```bash
gcloud compute networks subnets create on-prem-subnet --network on-prem-net --range 192.168.101.0/24 --region asia-east1
```
```bash
gcloud compute firewall-rules create on-prem-fw --network on-prem-net --allow tcp:22,icmp
```

### Transitive

```bash
gcloud compute networks create transitive-net --subnet-mode custom
```
```bash
gcloud compute networks subnets create transitive-subnet --network transitive-net --range 192.168.102.0/24 --region asia-east1
```
```bash
gcloud compute firewall-rules create transitive-fw --network transitive-net --allow tcp:22,icmp
```

### Peered

```bash
gcloud compute networks create peered-net --subnet-mode custom
```
```bash
gcloud compute networks subnets create peered-subnet --network peered-net --range 192.168.103.0/24 --region asia-east1
```
```bash
gcloud compute firewall-rules create peered-fw --network peered-net --allow tcp:22,icmp
```

## Create Peering

```bash
gcloud compute networks peerings create peer-transitive-to-peered --auto-create-routes --network=transitive-net --peer-project {{project-id}} --peer-network peered-net
```
```bash
gcloud compute networks peerings create peer-peered-to-transitive --auto-create-routes --network=peered-net --peer-project {{project-id}} --peer-network transitive-net
```


## Create VPN

### IP

```bash
gcloud compute addresses create on-prem-vpn-gw --region asia-east1
```
```bash
gcloud compute addresses create transitive-vpn-gw --region asia-east1
```
```bash
on_prem_vpn_gw_ip=$(gcloud compute addresses describe on-prem-vpn-gw --region asia-east1 --format='value(address)')
```
```bash
transitive_vpn_gw_ip=$(gcloud compute addresses describe transitive-vpn-gw --region asia-east1 --format='value(address)')
```

### Gateway

```bash
gcloud compute target-vpn-gateways create on-prem-vpn-gw --network on-prem-net --region asia-east1
```
```bash
gcloud compute target-vpn-gateways create transitive-vpn-gw --network transitive-net --region asia-east1
```

### Forwarding Rule

```bash
gcloud compute forwarding-rules create on-prem-fr-esp --ip-protocol ESP --address $on_prem_vpn_gw_ip --target-vpn-gateway on-prem-vpn-gw --region asia-east1
```
```bash
gcloud compute forwarding-rules create on-prem-fr-udp500 --ip-protocol UDP --ports 500 --address $on_prem_vpn_gw_ip --target-vpn-gateway on-prem-vpn-gw --region asia-east1
```
```bash
gcloud compute forwarding-rules create on-prem-fr-udp4500 --ip-protocol UDP --ports 4500 --address $on_prem_vpn_gw_ip --target-vpn-gateway on-prem-vpn-gw --region asia-east1
```
```bash
gcloud compute forwarding-rules create transitive-fr-esp --ip-protocol ESP --address $transitive_vpn_gw_ip --target-vpn-gateway transitive-vpn-gw --region asia-east1
```
```bash
gcloud compute forwarding-rules create transitive-fr-udp500 --ip-protocol UDP --ports 500 --address $transitive_vpn_gw_ip --target-vpn-gateway transitive-vpn-gw --region asia-east1
```
```bash
gcloud compute forwarding-rules create transitive-fr-udp4500 --ip-protocol UDP --ports 4500 --address $transitive_vpn_gw_ip --target-vpn-gateway transitive-vpn-gw --region asia-east1
```

### Tunnel

```bash
gcloud compute vpn-tunnels create on-prem-tunnel --peer-address $transitive_vpn_gw_ip --target-vpn-gateway on-prem-vpn-gw --ike-version 2 --local-traffic-selector 0.0.0.0/0 --remote-traffic-selector 0.0.0.0/0 --shared-secret=sharedsecret --region asia-east1
```
```bash
gcloud compute vpn-tunnels create transitive-tunnel --peer-address $on_prem_vpn_gw_ip --target-vpn-gateway transitive-vpn-gw --ike-version 2 --local-traffic-selector 0.0.0.0/0 --remote-traffic-selector 0.0.0.0/0 --shared-secret=sharedsecret --region asia-east1
```

### Route

```bash
gcloud compute routes create on-prem-route-to-transitive --destination-range 192.168.102.0/24 --network on-prem-net --next-hop-vpn-tunnel on-prem-tunnel --next-hop-vpn-tunnel-region asia-east1
```
```bash
gcloud compute routes create transitive-route-to-on-prem --destination-range 192.168.101.0/24 --network transitive-net --next-hop-vpn-tunnel transitive-tunnel --next-hop-vpn-tunnel-region asia-east1
```

## Create VM

```bash
gcloud compute instances create "on-prem-vm" --zone "asia-east1-a" --subnet "on-prem-subnet"
```
```bash
gcloud compute instances create "transitive-vm" --zone "asia-east1-a" --subnet "transitive-subnet"
```
```bash
gcloud compute instances create "peered-vm" --zone "asia-east1-a" --subnet "peered-subnet"
```

## Exchange Custom Route

```bash
gcloud compute routes create on-prem-route-to-peered --destination-range 192.168.103.0/24 --network on-prem-net --next-hop-vpn-tunnel on-prem-tunnel --next-hop-vpn-tunnel-region asia-east1
```
```bash
gcloud compute networks peerings update peer-transitive-to-peered --network=transitive-net --export-custom-routes
```
```bash
gcloud compute networks peerings update peer-peered-to-transitive --network=peered-net --import-custom-routes
```

## Verify

VM on-prem-vm - - ping - -> peered-vm

## Private Service Connection

[doc](https://cloud.google.com/vpc/docs/configure-private-services-access?hl=en_US)

### IP Range

```bash
gcloud compute addresses create transitive-ip-ranges-for-private-services --global --purpose=VPC_PEERING --addresses=192.168.0.0 --prefix-length=20 --network=transitive-net
```

### Connection

```bash
gcloud services vpc-peerings connect --service=servicenetworking.googleapis.com --ranges=transitive-ip-ranges-for-private-services --network=transitive-net
```

As result, two connections and two peerings will be created:
* connection name
  * cloudsql-mysql-googleapis-com
  * servicenetworking-googleapis-com
* peering name
  * cloudsql-mysql-googleapis-com
  * servicenetworking-googleapis-com

## Private CloudSQL

```bash
gcloud beta sql instances create private-cloudsql-00 --network transitive-net
```

### Exchange Custom Route

```bash
gcloud compute routes create on-prem-route-to-privateservices --destination-range 192.168.0.0/20 --network on-prem-net --next-hop-vpn-tunnel on-prem-tunnel --next-hop-vpn-tunnel-region asia-east1
```
```bash
gcloud compute networks peerings update cloudsql-mysql-googleapis-com --network=transitive-net --export-custom-routes
```

### Verify

* VM transitive-vm - - 3306 - -> private-cloudsql-00 [o]
* VM on-prem-vm - - 3306 - -> private-cloudsql-00 [o]
* VM peered-vm - - 3306 - -> private-cloudsql-00 [x]

## Private MemoryStore

```bash
gcloud redis instances create private-memorystore-00 --connect-mode private_service_access --network transitive-net --region asia-east1
```

<walkthrough-footnote>NOTE: must be in the same region as the VM</walkthrough-footnote>

### Exchange Custom Route

```bash
gcloud compute routes create on-prem-route-to-privateservices --destination-range 192.168.0.0/20 --network on-prem-net --next-hop-vpn-tunnel on-prem-tunnel --next-hop-vpn-tunnel-region asia-east1
```
```bash
gcloud compute networks peerings update servicenetworking-googleapis-com --network=transitive-net --export-custom-routes
```

### Verify

* VM transitive-vm - - 6379 - -> private-memorystore-00 [o]
* VM on-prem-vm - - 6379 - -> private-memorystore-00 [o]
* VM peered-vm - - 6379 - -> private-memorystore-00 [x]

## Private FileStore

TODO:

## Private NetApp

TODO: need another private serivce connection


## Private Kubernetes

```bash
gcloud compute networks subnets create transitive-subnet-gke --network transitive-net --region asia-east1 --range 192.168.16.0/20 --secondary-range pod-ip-range=192.168.32.0/20,svc-ip-range=192.168.48.0/20 --enable-private-ip-google-access
```

<walkthrough-footnote>NOTE: common mask for pod-ip-range is 14 bits</walkthrough-footnote>

```bash
gcloud container clusters create private-gke-00 --zone asia-east1-a --network transitive-net --subnetwork transitive-subnet-gke --cluster-secondary-range-name pod-ip-range --services-secondary-range-name svc-ip-range --enable-private-nodes --enable-ip-alias --master-ipv4-cidr 192.168.201.0/28 --enable-private-endpoint --enable-master-authorized-networks
```

At this point, these are the only IP addresses that have access to the cluster master:

* The primary range of transitive-subnet-gke. (192.168.16.0/20)
* The secondary range used for Pods. (192.168.32.0/20)

NOTE

* Master address range mask size must be /28
* Pod address range mask size must be /9 ~ /21
* Service address range mask size must be /16 ~ /27

### Exchange Custom Route

```bash
gcloud compute routes create on-prem-route-to-privategkemaster --destination-range 192.168.201.0/28 --network on-prem-net --next-hop-vpn-tunnel on-prem-tunnel --next-hop-vpn-tunnel-region asia-east1
```
```bash
gke_peering=$(gcloud container clusters describe private-gke-00 --zone asia-east1-a --format='value(privateClusterConfig.peeringName)')
```
```bash
gcloud compute networks peerings update $gke_peering --network=transitive-net --export-custom-routes
```

### Authorized Network

```bash
gcloud container clusters update private-gke-00 --zone asia-east1-a --enable-master-authorized-networks --master-authorized-networks 192.168.101.0/24,192.168.102.0/24
```

At this point, these are the only IP addresses that have access to the cluster master:

* The primary range of transitive-subnet-gke. (192.168.16.0/20)
* The secondary range used for Pods. (192.168.32.0/20)
* on-prem-subnet (192.168.101.0/24)
* transitive-subnet (192.168.102.0/24)

<walkthrough-footnote>NOTE: no way to allow cloud shell because public endpoint is disabled.</walkthrough-footnote>

### Verify

* VM transitive-vm - - kubectl - -> private-gke-00 [o]
* VM on-prem-vm - - kubectl - -> private-gke-00 [o]
* VM peered-vm - - kubectl - -> private-memorystore-00 [x]

### Optional

Let on-prem-vm can access pods

```bash
gcloud compute routes create on-prem-route-to-privategkepod --destination-range 192.168.32.0/20 --network on-prem-net --next-hop-vpn-tunnel on-prem-tunnel --next-hop-vpn-tunnel-region asia-east1
```

## Clean Up

```bash
TODO
```
