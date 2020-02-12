
variable resource_group_name {
    type = string
}
variable "region" {
    type = string
}
variable "nsg_id" {
    type = string
}
variable "subnet_id" {
    type = string
}
variable "environment" {
   type = string
}
variable "inst_name" {
   type = string
}
variable "nic_count" {
    type = number
}
