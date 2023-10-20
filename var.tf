# variable for vpc

variable "east_vpc" {
  type        = string
  default     = "10.0.0.0/16"
  description = "creating vpc in us-east-2"
}

# variable for 6 subnet

variable "web1_subnet" {
  type        = string
  description = "web 1 public subnet"
  default     = "10.0.1.0/24"
}
