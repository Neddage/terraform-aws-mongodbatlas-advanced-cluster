# terraform-aws-mongodbatlas-advanced-cluster

Terraform module which creates an MongoDB Atlas cluster on AWS with VPC peering, using the advanced_cluster resource type. This module is based on [guyelia/terraform-aws-mongodbatlas](https://github.com/guyelia/terraform-aws-mongodbatlas) with updated resource types and additional configuration options.

The module will launch a mongodb atlas cluster on AWS in a single region into a new project. It will create the appropriate atlas network container and configure the VPC peering connections between the new atlas cluster VPC and the VPCs specified via the input variables. 

These types of resources are supported/created:
* [Project](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project.html)
* [Teams](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/teams)
* [Network Container](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/network_container)
* [Project IP Access List](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project_ip_access_list)
* [Advanced Cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/advanced_cluster)
* [Network Peering](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/network_peering)
* [AWS VPC Peering Connection Accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter)
* [AWS Route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)

## Terraform versions

Terraform versions >=1.0.0 are supported
   
## Usage
### Minimal Example
```hcl
module "atlas_advanced_cluster" {
  source = ".//terraform-aws-mongodbatlas-advanced-cluster"

  project_name="my-atlas-project"
  org_id="996228199622819962281"
  region="eu-west-2"
  
  cluster_name = "my-cluster"
  instance_size = "M10"
  
}
```

### Full Example

```hcl
module "atlas_advanced_cluster" {
  source = ".//terraform-aws-mongodbatlas-advanced-cluster"

  project_name="my-atlas-project"
  org_id="996228199622819962281"
  region="eu-west-2"
  cluster_name = "my-cluster"
  instance_size = "M10"

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
      vpc_id = "vpc-0660c7a86412fdr3e"
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
      vpc_id = "vpc-0660c7a86412fdr3e"
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
```
## Prerequisites
* [MongoDB Cloud account](https://www.mongodb.com/cloud)
* [MongoDB Atlas Organization](https://cloud.mongodb.com/v2#/preferences/organizations/create)
* [MongoDB Atlas API key](https://www.terraform.io/docs/providers/mongodbatlas/index.html)

#### Manual tasks:

* Configure the API key before applying the module
* Get your MongoDB Atlas Organization ID from the UI

#### Create Teams:
In case you want to create Teams and associate them with the project, users must be added in advance and making sure they have accepted the invitation.
Users who have not accepted an invitation to join the organization cannot be added as team members. 

## VPC Peering
In case vpc peering is required, AWS provider will be used, the following information is required:
* [Access to AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
* VPC ID
* [AWS account ID](https://docs.aws.amazon.com/general/latest/gr/acct-identifiers.html)
* Region
* [Routable cidr block](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/network_peering.html#route_table_cidr_block)
* List of [Route Table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) Ids to add routes to atlas vpc to.

You can add them manually, or through other Terraform resources, and pass it to the module via ```vpc_peers``` variable:
```hcl
  vpc_peers = {
    peer1 : {
      aws_account_id = "890987654321"
      region = "eu-west-1"
      vpc_id = "vpc-0660c7a86412fdr3e"
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
      vpc_id = "vpc-0660c7a86412fdr3e"
      route_table_cidr_block = "172.31.0.0/16"
      add_cidr_to_whitelist = true
      route_tables = [
        "rtb-10e4b8ccface7f771",
        "rtb-55pu21arface7d707",
        "rtb-91h4b8frfty75gg46"
      ] 
    }
  }
```

You can see a [full example](https://github.com/Neddage/terraform-aws-mongodbatlas-advanced-cluster/blob/master/examples/full/main.tf) in the examples folder.

## Requirements

| Name | Version |
|------|---------|
| terraform | \>= 1.00 |


## Providers

| Name | Version |
|------|---------|
|mongodb/mongodbatlas|\>= 1.6.0 |
|hashicorp/aws|\>= 4.22 |




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | The name of the project you want to create. | `string` |  | yes |
| org_id | The ID of the Atlas organization you want to create the project within. | `string` |  | yes |
| region | The AWS region-name that the cluster will be deployed on. | `string` |  | yes |
| cluster_name | The cluster name. | `string` |  | yes |
| instance_size | The Atlas instance-type name. | `string` |  | yes |
| teams | An object that contains all the groups that should be created in the project. | `map(any)` | `{}` | no |
| white_lists | An object that contains all the network white-lists that should be created in the project. | `map(any)` | `{}` | no |
| mongodb_major_version | The MongoDB cluster major version, must be specified if mongodb_version_release_system = LTS | `number` | `null` | no |
| mongodb_version_release_system | The version release system to use - LTS/CONTINUOUS | `string` | `"CONTINUOUS"` | no |
| cluster_type | The MongoDB Atlas cluster type - SHARDED/REPLICASET/GEOSHARDED. | `string` | `"REPLICASET"` | no |
| num_shards | number of shards. | `number` | `null` | no |
| num_nodes | number of nodes. | `number` | `3` | no |
| pit_enabled | Indicating if the cluster uses Cloud Backup for backups. | `bool` | `false` | no |
| pit_enabled | Indicating if the cluster uses Continuous Cloud Backup, if set to true - backup_enabled must also be set to true | `bool` | `false` | no |
| disk_size_gb | Capacity,in gigabytes,of the host’s root volume. | `number` | `null` | no |
| auto_scaling_disk_gb_enabled | Indicating if disk auto-scaling is enabled. | `bool` | `false` | no |
| auto_scaling_compute_enabled | Indicating if compute auto scaling should be enabled | `bool` | `false` | no |
| auto_scaling_compute_scale_down_enabled | Flag that indicates whether the instance size may scale down. | `bool` | `false` | no |
| auto_scaling_compute_min_instance_size | The minimum instance size for compute autoscaling | `string` | `null` | no |
| auto_scaling_compute_max_instance_size | The maximum instance size for compute autoscaling | `string` | `null` | no |
| volume_type | STANDARD or PROVISIONED for IOPS higher than the default instance IOPS. | `string` | `"STANDARD"` | no |
| disk_iops | The maximum IOPS the system can perform | `number` | `null` | no |
| encryption_at_rest_enabled | Indicating if the AWS EBS encryption feature encrypts the server’s root volume | `bool` | `false` | no |
| termination_protection_enabled | Whether termination protections should be enabled, defaults to true | `bool` | `true` | no |
| atlas_vpc_cidr_block | The CIDR block to use for the Atlas VPC/network Container | `string` | `"192.168.248.0/21"` | no |
| vpc_peers | An object that contains all VPC peering requests from the cluster to AWS VPC's. See below for object format/details. | `map(any)` | `{}` | no

### VPC Peer Objects

If you wish to setup VPC peering then provide a map of VPC peer objects to via the `vpc_peers` input. 

Example peer object:

```
{
  aws_account_id = "123456789098"
  region = "eu-west-2"
  vpc_id = "vpc-0660c7a86412fdr3e"
  route_table_cidr_block = "172.31.0.0/16"
  add_cidr_to_whitelist = true
  route_tables = [
    "rtb-10e4b8ccface7f771",
    "rtb-55pu21arface7d707",
    "rtb-91h4b8frfty75gg46"
  ] 
}
```

#### Peer Object Parameters

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_account_id | The ID of the AWS account containing the VPC to peer with  | `string` |  | yes |
| region | The AWS region  that the VPC to peer with is in | `string` |  | yes |
| vpc_id | The VPC ID of the VPC to peer with | `string` |  | yes |
| route_table_cidr_block | The CIDR block for the VPC | `string` |  | yes |
| add_cidr_to_whitelist | An object that contains all the groups that should be created in the project. | `bool` |  | yes |
| route_tables | A list of AWS route table IDs which should be updated to add route traffic designed for the atlas VPC IP range via the VPC peering connection. | `list(string)` | `[]` | no |

## Outputs

TODO: Review what is being output and ensure its suitable

| Name | Description |
|------|-------------|
| cluster_id | The cluster ID. |
| mongo_db_version | Version of MongoDB the cluster runs, in major-version.minor-version format. |
| connection_strings | Set of connection strings that your applications use to connect to this cluster. |
| container_id | The Network Peering Container ID. |
| state_name |  Current state of the cluster. |
