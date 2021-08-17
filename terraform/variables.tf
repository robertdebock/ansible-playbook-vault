variable "do_token" {}

variable "amount" {
  description = "The number of instances to create."
  type        = number
  default     = 5
  validation {
    condition     = var.amount % 2 == 1
    error_message = "Please set an odd number for amount, like 1, 3 or 5."
  }
}
