variable "project" {
  default = "terraform"
}
variable "env" {
  default = "dev"
}
variable "location" {
  default = "japaneast"
}
variable "container_registry_name" {
  //
}
variable "container_registry_user" {
  //
}
variable "container_registry_password" {
  sensitive = true
}