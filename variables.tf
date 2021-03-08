variable "region" {
    default = "us-west-2"
    type = string
    description = "Tells in which region VPC is creating"
  
}

variable "vpccidr" {
    type = string
    default = "198.160.0.0/16"
    description = "allocates IPv4 address"
  
}
