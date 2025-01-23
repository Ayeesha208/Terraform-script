Main.tf:
provider "azurerm" {
  features {}
 client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}
 resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_service_plan" "example" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "B1"
}
resource "azurerm_app_service" "example" {
  name                = var.app_service_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_service_plan.example.id
 site_config {
    linux_fx_version = "DOCKER|${var.acr_name}.azurecr.io/${var.acr_image_name}:${var.acr_image_tag}"
  }
 app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${var.acr_name}.azurecr.io"
    "DOCKER_REGISTRY_SERVER_USERNAME" = var.acr_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = var.acr_password
  }
}
 output "app_service_url" {
  value = azurerm_app_service.example.default_site_hostname
}
