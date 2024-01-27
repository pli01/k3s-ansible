module "vpc" {
  source = "github.com/pli01/terraform-outscale-vpc"

  config_file = var.config_file
  parameters  = var.parameters
}
