provider "aws" {
  region = "eu-west-2"
}

provider "mongodbatlas" {}


module "advanced_atlas_cluster" {
  source = "../../"

  project_name="my-atlas-project"
  org_id="996228199622819962281"
  region="eu-west-2"
  teams = {
    Devops: {
      users: ["example@mail.io", "user@mail.io"]
      role: "GROUP_OWNER"
    },
    DevTeam: {
      users: ["developer@mail.io",]
      role: "GROUP_READ_ONLY"
    }
  }
  white_lists = {
    "example comment": "10.0.0.1/32",
    "second example": "10.10.10.8/32"
  }
  cluster_name = "my-cluster"
  instance_size = "M10"
  mongodb_major_version = 6.1
  mongodb_version_release_system = "CONTINUOUS"
  cluster_type = "REPLICASET"
  num_shards = 1
  num_nodes = 3
  backup_enabled = true
  pit_enabled =  true
  disk_size_gb = 20
  auto_scaling_disk_gb_enabled = true
  auto_scaling_compute_enabled = true
  auto_scaling_compute_scale_down_enabled = true
  auto_scaling_compute_min_instance_size = "M10"
  auto_scaling_compute_max_instance_size = "M30"
  volume_type = "STANDARD"
  disk_iops = 1000
  encryption_at_rest_enabled = false
  termination_protection_enabled = true
  atlas_vpc_cidr_block = "192.168.248.0/21"
  vpc_peers = {
    peer1 : {
      aws_account_id = "890987654321"
      region = "eu-west-1"
      vpc_id = "vpc-0420c7a65412fdr3e"
      route_table_cidr_block = "172.16.0.0/16"
      add_cidr_to_whitelist = true
      route_tables = [
        "rtb-08e4b8ccface7f466",
        "rtb-18yu75trface7d787",
        "rtb-77h4b8ccfty75gg46"
      ] 
    },
    peer2 : {
      aws_account_id = "123456789098"
      region = "eu-west-2"
      vpc_id = "vpc-0420c7a65412fdr3e"
      route_table_cidr_block = "172.31.0.0/16"
      add_cidr_to_whitelist = true
      route_tables = [
        "rtb-10e4b8ccface7f771",
        "rtb-55pu21arface7d707",
        "rtb-91h4b8frfty75gg46"
      ] 
    }
  }  

}