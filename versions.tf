terraform {
  required_version = ">= 1.3"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.3"
    }
  }
}
