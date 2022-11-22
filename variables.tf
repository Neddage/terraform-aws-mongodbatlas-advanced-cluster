variable "project_name" {
  description = "The name of the project you want to create/use"
  type        = string
}

variable "org_id" {
  description = "The ID of the Atlas organization you want to create the project within"
  type        = string
}

variable "region" {
  description = "The AWS region-name that the cluster will be deployed on"
  type        = string
}

# variable "create_new_project" {
#   description = "Whether we should create a new project rather than using an existing one."
#   type = bool
#   default = false
# }

variable "teams" {
  description = "An object that contains all the groups that should be created in the project"
  type        = map(any)
  default     = {}
}

variable "white_lists" {
  description = "An object that contains all the network white-lists that should be created in the project"
  type        = map(any)
  default     = {}
}

variable "region_aws_atlas_map" {
  description = "Maps aws region format to the atlas region format ie. eu-west-2 = EU_WEST_2"
  type = map(any)
  default = {
    "eu-west-1" = "EU_WEST_1"
    "eu-west-2" = "EU_WEST_2"
    "eu-west-3" = "EU_WEST_3"
    "eu-central-1" = "EU_CENTRAL_1"
    "eu-north-1" = "EU_NORTH_1"
    "eu-south-1" = "EU_SOUTH_1"
  }
}

variable "cluster_name" {
  description = "The cluster name"
  type        = string
}

variable "instance_size" {
  description = "The Atlas instance-type name. ie. M10"
  type        = string
}

variable "mongodb_major_version" {
  description = "The MongoDB cluster major version, must be specified if mongodb_version_release_system = LTS"
  type        = number
  default     = null
}

variable "mongodb_version_release_system" {
  description = "The version release system to use - LTS/CONTINUOUS"
  type = string
  default = "LTS"
}

variable "cluster_type" {
  description = "The MongoDB Atlas cluster type - SHARDED/REPLICASET/GEOSHARDED"
  type        = string
}

variable "num_shards" {
  description = "number of shards"
  type        = number
}

variable "num_nodes" {
  description = "The Number of electable nodes"
  type        = number
  default     = 3
}

variable "backup_enabled" {
  description = "Indicating if the cluster uses Cloud Backup for backups"
  type        = bool
  default     = true
}

variable "pit_enabled" {
  description = "Indicating if the cluster uses Continuous Cloud Backup, if set to true - backup_enabled must also be set to true"
  type        = bool
  default     = true
}

variable "disk_size_gb" {
  description = "Capacity,in gigabytes,of the host’s root volume"
  type        = number
  default     = null
}

variable "auto_scaling_disk_gb_enabled" {
  description = "Indicating if disk auto-scaling is enabled"
  type        = bool
  default     = true
}

variable "auto_scaling_compute_enabled" {
  description = "Indicating if compute auto scaling should be enabled"
  type        = bool
  default     = false
}

variable "auto_scaling_compute_scale_down_enabled" {
  description = "Flag that indicates whether the instance size may scale down."
  type        = bool
  default     = false
}

variable "auto_scaling_compute_min_instance_size" {
  description = "The minimum instance size for compute autoscaling"
  type = string
  default = null
}

variable "auto_scaling_compute_max_instance_size" {
  description = "The maximum instance size for compute autoscaling"
  type = string
  default = null
}

variable "volume_type" {
  description = "STANDARD or PROVISIONED for IOPS higher than the default instance IOPS"
  type        = string
  default     = "STANDARD"
}

variable "disk_iops" {
  description = "The maximum IOPS the system can perform"
  type        = number
  default     = null
}

variable "encryption_at_rest_enabled" {
  description = "Indicating if the AWS EBS encryption feature encrypts the server’s root volume"
  type        = bool
  default     = false
}

variable "vpc_peer" {
  description = "An object that contains all VPC peering requests from the cluster to AWS VPC's"
  type        = map(any)
  default     = {}
}

variable "termination_protection_enabled" {
  description = "Whether termination protections should be enabled, defaults to true"
  type = bool
  default = true
}

variable "atlas_vpc_cidr_block" {
  description = "The CIDR block to use for the Atlas VPC/network Container"
  type = string
  default = "192.168.248.0/21"
}
