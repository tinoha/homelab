# terraform.tf
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.7"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.8"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.14"
    }
  }
}
