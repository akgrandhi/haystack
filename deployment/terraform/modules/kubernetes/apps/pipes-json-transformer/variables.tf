variable "image" {}
variable "replicas" {}
variable "namespace" {}
variable "kafka_endpoint" {}
variable "graphite_hostname" {}
variable "termination_grace_period" {
  default = 30
}