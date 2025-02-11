variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the VM"
  type        = string
  sensitive   = true
}

variable "bastion_sku" {
  description = "Sku of the bastion"
  type        = string
  sensitive   = true
}

variable "vm_sku" {
  description = "Sku of the VM"
  type        = string
  sensitive   = true
}