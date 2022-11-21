# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version ="~> 1.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IF var.create_new_project=true CREATE AN ATLAS PROJECT THAT THE CLUSTER WILL RUN INSIDE
# ---------------------------------------------------------------------------------------------------------------------
resource "mongodbatlas_project" "project" {
  count = var.create_new_project ? 1 : 0
  name   = var.project_name
  org_id = var.org_id

  #Associate teams and privileges if passed, if not - run with an empty object
  dynamic "teams" {
    for_each = var.teams

    content {
      team_id    = mongodbatlas_teams.team[teams.key].team_id
      role_names = [teams.value.role]
    }
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# IF var.create_new_project=false CREATE DATA RESOURCE FOTR EXISTING PROJECT 
# ---------------------------------------------------------------------------------------------------------------------
data "mongodbatlas_project" "project" {
  # If we are meant to be creating a new project, don't create this data resource as the project won't exist yet
  count = var.create_new_project ? 0 : 1
  name = var.project_name
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE TEAMS FROM **EXISTING USERS**
# ---------------------------------------------------------------------------------------------------------------------

resource "mongodbatlas_teams" "team" {
  for_each = var.teams

  org_id    = var.org_id
  name      = each.key
  usernames = each.value.users
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE NETWORK WHITE-LISTS FOR ACCESSING THE PROJECT
# ---------------------------------------------------------------------------------------------------------------------

#Optional, if no variable is passed, the loop will run on an empty object.

resource "mongodbatlas_project_ip_access_list" "whitelists" {
  for_each = var.white_lists

  project_id = var.create_new_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  comment    = each.key
  cidr_block = each.value
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE MONGODB ATLAS CLUSTER IN THE PROJECT
# ---------------------------------------------------------------------------------------------------------------------

resource "mongodbatlas_advanced_cluster" "cluster" {
  project_id                   = var.create_new_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  name                         = var.cluster_name
  cluster_type                 = var.cluster_type
  backup_enabled               = var.backup_enabled
  disk_size_gb                 = var.disk_size_gb
  encryption_at_rest_provider = var.encryption_at_rest_enabled ? "AWS" : "NONE"
  mongo_db_major_version       = var.mongodb_major_ver
  pit_enabled                  = var.pit_enabled
  replication_specs {
    num_shards = var.cluster_type == "REPLICASET" ? null : var.num_shards
    region_configs {
      provider_name = "AWS"
      region_name = var.region_aws_atlas_map[var.region]
      priority = 7
      auto_scaling {
        disk_gb_enabled = var.auto_scaling_disk_gb_enabled
        compute_enabled = var.auto_scaling_compute_enabled
        compute_min_instance_size = var.auto_scaling_compute_enabled ? var.auto_scaling_compute_min_instance_size : null
        compute_max_instance_size = var.auto_scaling_compute_enabled ? var.auto_scaling_compute_max_instance_size : null
        compute_scale_down_enabled = var.auto_scaling_compute_scale_down_enabled
      }
      electable_specs {
        instance_size = var.instance_size
        disk_iops = var.disk_iops
        ebs_volume_type = var.volume_type
      }
    }
  }
  termination_protection_enabled= var.termination_protection_enabled

 
  # Ignore instance_size lifecycle changes so if the clsuter is scaled up/down terraform doesn't try to reset it
  # THis isn't working, have implimented against documentation bgut stil no dice. So commented out for now
  lifecycle {
    ignore_changes = [
      instance_size
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS PEER REQUESTS TO AWS VPC
# ---------------------------------------------------------------------------------------------------------------------
resource "mongodbatlas_network_peering" "mongo_peer" {
  for_each = var.vpc_peer

  accepter_region_name   = each.value.region
  project_id             = var.create_new_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  # Doesn't feel like the best way to do this, however I think there should only ever be one container_id anyway, certainly for our needs of AWS only
  container_id           = mongodbatlas_advanced_cluster.cluster.replication_specs.*.container_id[0]
  provider_name          = "AWS"
  route_table_cidr_block = each.value.route_table_cidr_block
  vpc_id                 = each.value.vpc_id
  aws_account_id         = each.value.aws_account_id
}

# ---------------------------------------------------------------------------------------------------------------------
# ACCEPT THE PEER REQUESTS ON THE AWS SIDE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_peering_connection_accepter" "peer" {
  for_each = var.vpc_peer

  vpc_peering_connection_id = mongodbatlas_network_peering.mongo_peer[each.key].connection_id
  auto_accept               = true
}
