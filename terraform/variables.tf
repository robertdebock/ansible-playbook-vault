variable "do_token" {}

variable "amount" {
  description = "The number of vault instances to create."
  type        = number
  default     = 5
  validation {
    condition     = var.amount % 2 == 1
    error_message = "Please use an odd number for amount, like 1, 3 or 5."
  }
}

variable "size" {
  description = "The size to deploy Vault on."
  type        = string
  default     = "large"
  validation {
    condition     = contains(["small", "large"], var.size)
    error_message = "Please use either \"small\" or \"large\"."
  }
}

variable "loadbalancers" {
  description = "The number of loadbalancer per dc and overall to create."
  type        = number
  default     = 2
  validation {
    condition     = var.loadbalancers == 1 || var.loadbalancers == 2
    error_message = "Please use either 1 or 2."
  }
}
