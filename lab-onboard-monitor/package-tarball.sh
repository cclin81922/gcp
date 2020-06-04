#!/bin/bash

set -e

rm -rf terraform/deploy-1/.terraform/
rm -rf terraform/deploy-1/terraform.tfstate
rm -rf terraform/deploy-1/terraform.tfstate.backup

rm -rf terraform/deploy-2/.terraform/
rm -rf terraform/deploy-2/terraform.tfstate
rm -rf terraform/deploy-2/terraform.tfstate.backup

tar -czf terraform.tar.gz terraform
