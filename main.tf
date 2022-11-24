# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ATLAS PROJECT THAT THE CLUSTER WILL RUN INSIDE
# ---------------------------------------------------------------------------------------------------------------------
resource "mongodbatlas_project" "project" {
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
# CREATE NETWORK CONTAINER
# ---------------------------------------------------------------------------------------------------------------------
resource "mongodbatlas_network_container" "container" {
  project_id       = mongodbatlas_project.project.id
  atlas_cidr_block = var.atlas_vpc_cidr_block
  provider_name    = "AWS"
  region_name      = var.region_aws_atlas_map[var.region]
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

  project_id = mongodbatlas_project.project.id
  comment    = each.key
  cidr_block = each.value
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE MONGODB ATLAS CLUSTER IN THE PROJECT
# ---------------------------------------------------------------------------------------------------------------------

resource "mongodbatlas_advanced_cluster" "cluster" {
  project_id                  = mongodbatlas_project.project.id
  name                        = var.cluster_name
  cluster_type                = var.cluster_type
  backup_enabled              = var.backup_enabled
  disk_size_gb                = var.disk_size_gb
  encryption_at_rest_provider = var.encryption_at_rest_enabled ? "AWS" : "NONE"
  mongo_db_major_version      = var.mongodb_version_release_system == "LTS" ? var.mongodb_major_version : null
  version_release_system      = var.mongodb_version_release_system
  pit_enabled                 = var.pit_enabled
  replication_specs {
    num_shards = var.cluster_type == "REPLICASET" ? null : var.num_shards
    region_configs {
      provider_name = "AWS"
      region_name   = var.region_aws_atlas_map[var.region]
      priority      = 7
      auto_scaling {
        disk_gb_enabled            = var.auto_scaling_disk_gb_enabled
        compute_enabled            = var.auto_scaling_compute_enabled
        compute_min_instance_size  = var.auto_scaling_compute_enabled ? var.auto_scaling_compute_min_instance_size : null
        compute_max_instance_size  = var.auto_scaling_compute_enabled ? var.auto_scaling_compute_max_instance_size : null
        compute_scale_down_enabled = var.auto_scaling_compute_scale_down_enabled
      }
      electable_specs {
        instance_size   = var.instance_size
        disk_iops       = var.disk_iops
        ebs_volume_type = var.volume_type
        node_count      = var.num_nodes
      }
    }
  }
  termination_protection_enabled = var.termination_protection_enabled


  # Ignore instance_size lifecycle changes so if the clsuter is scaled up/down terraform doesn't try to reset it
  # This isn't working, have implemented against documentation but stil no dice. So commented out for now
  # lifecycle {
  #   ignore_changes = [
  #     instance_size
  #   ]
  # }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS PEER REQUESTS TO AWS VPC
# ---------------------------------------------------------------------------------------------------------------------
resource "mongodbatlas_network_peering" "mongo_peer" {
  for_each = var.vpc_peers

  accepter_region_name   = each.value.region
  project_id             = mongodbatlas_project.project.id
  container_id           = mongodbatlas_network_container.container.id
  provider_name          = "AWS"
  route_table_cidr_block = each.value.route_table_cidr_block
  vpc_id                 = each.value.vpc_id
  aws_account_id         = each.value.aws_account_id

}

# ---------------------------------------------------------------------------------------------------------------------
# ADD VPC CIDR TO WHITELIST
# ---------------------------------------------------------------------------------------------------------------------
resource "mongodbatlas_project_ip_access_list" "vpc" {
  for_each   = { for k, v in var.vpc_peers : k => v if v.add_cidr_to_whitelist }
  project_id = mongodbatlas_project.project.id
  comment    = "AWS VPC CIDR #${each.key}"
  cidr_block = each.value.route_table_cidr_block
}

# ---------------------------------------------------------------------------------------------------------------------
# ACCEPT THE PEER REQUESTS ON AWS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc_peering_connection_accepter" "peer" {
  for_each                  = var.vpc_peers
  vpc_peering_connection_id = mongodbatlas_network_peering.mongo_peer[each.key].connection_id
  auto_accept               = true

}

# ---------------------------------------------------------------------------------------------------------------------
# ADD ROUTE INTO ROUTE TABLES ON AWS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route" "peer" {
  for_each = {
    for i, peer_rt in flatten([
      for peer_key, peer in var.vpc_peers : [
        for rt_key, rt in peer.route_tables : {
          connection_id  = mongodbatlas_network_peering.mongo_peer[peer_key].connection_id
          route_table_id = rt
        }
      ]
    ]) : i => peer_rt
  }
  # for_each = tomap(flatten([ for i, p in var.vpc_peer: [for rti, rt in p.route_tables: {
  #   connection_id = mongodbatlas_network_peering.mongo_peer[i].connection_id
  #   route_table_id = var.vpc_peer[i].route_tables[rti]
  # }]]))
  route_table_id            = each.value.route_table_id
  destination_cidr_block    = var.atlas_vpc_cidr_block
  vpc_peering_connection_id = each.value.connection_id
}