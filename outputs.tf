output "cluster_id" {
  value       = mongodbatlas_advanced_cluster.cluster.cluster_id
  description = "The cluster ID"
}

output "mongo_db_version" {
  value       = mongodbatlas_advanced_cluster.cluster.mongo_db_version
  description = "Version of MongoDB the cluster runs, in major-version.minor-version format"
}

output "mongo_connection_strings" {
  value       = mongodbatlas_advanced_cluster.cluster.connection_strings
  description = "connection strings for the cluster"
}

output "everything" {
  value = mongodbatlas_advanced_cluster.cluster
}

output "container_id" {
  value       = mongodbatlas_advanced_cluster.cluster.replication_specs.*.container_id[0]
  description = "The Network Peering Container ID"
}

# output "mongo_uri_updated" {
#   value       = mongodbatlas_advanced_cluster.cluster.mongo_uri_updated
#   description = "Lists when the connection string was last updated"
# }

# output "mongo_uri_with_options" {
#   value       = mongodbatlas_advanced_cluster.cluster.mongo_uri_with_options
#   description = "connection string for connecting to the Atlas cluster. Includes the replicaSet, ssl, and authSource query parameters in the connection string with values appropriate for the cluster"
# }

# output "connection_strings" {
#   value       = mongodbatlas_advanced_cluster.cluster.connection_strings
#   description = "Set of connection strings that your applications use to connect to this cluster"
# }



# output "paused" {
#   value       = mongodbatlas_advanced_cluster.cluster.paused
#   description = "Flag that indicates whether the cluster is paused or not"
# }

# output "srv_address" {
#   value       = mongodbatlas_advanced_cluster.cluster.srv_address
#   description = "Connection string for connecting to the Atlas cluster. The +srv modifier forces the connection to use TLS/SSL"
# }

output "state_name" {
  value       = mongodbatlas_advanced_cluster.cluster.state_name
  description = "Current state of the cluster"
}
