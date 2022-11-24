provider "aws" {
  region = "eu-west-2"
}

provider "mongodbatlas" {}


module "atlas_advanced_cluster" {
  source = "../../"

  project_name="my-atlas-project"
  org_id="996228199622819962281"
  region="eu-west-2"
  
  cluster_name = "my-cluster"
  instance_size = "M10"
}