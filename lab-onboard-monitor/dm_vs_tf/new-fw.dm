resources:
- name: allow-icmp-by-dm
  type: compute.v1.firewall
  properties:
    network: "global/networks/default"
    allowed:
    - IPProtocol: ICMP
