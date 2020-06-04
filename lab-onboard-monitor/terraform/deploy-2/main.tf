module "bq" {
  source = "./modules/bq"
}

module "iam" {
  source = "./modules/iam"
}

module "vpc" {
  source = "./modules/vpc"
}

module "gce" {
  source = "./modules/gce"
}