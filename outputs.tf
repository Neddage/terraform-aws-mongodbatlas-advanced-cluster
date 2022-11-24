output "everything" {
  value = mongodbatlas_advanced_cluster.cluster
}

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

output "container_id" {
  value       = mongodbatlas_network_container.container.id
  description = "The Network Peering Container ID"
}

output "state_name" {
  value       = mongodbatlas_advanced_cluster.cluster.state_name
  description = "Current state of the cluster"
}
