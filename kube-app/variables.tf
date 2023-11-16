variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "image" {
  type = string
}

variable "replicas" {
  type    = number
  default = 1
}

variable "ports" {
  type = map(object({
    port     = number
    protocol = optional(string, "TCP")
  }))
  default = {}
}

variable "envs" {
  type    = map(string)
  default = {}
}

variable "liveness_probe" {
  type = object({
    command           = optional(list(string))
    timeout_seconds   = optional(number, 10)
    period_seconds    = optional(number, 30)
    failure_threshold = optional(number, 5)
  })
  default = {}
}

variable "volumes" {
  type = map(object({
    container_path = string
    size           = string
  }))
  default = {}
}
