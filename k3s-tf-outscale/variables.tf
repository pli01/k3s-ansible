variable "config_file" {
  description = "config.yml file"
  type        = string
}

variable "parameters" {
  description = "parameters variables defines in yaml template config file"
  type        = map(any)
}
