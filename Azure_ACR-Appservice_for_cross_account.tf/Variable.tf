#Variable.tf:

variable "client_id" {
  description = "The Client ID of the service principal for authentication in the target account"
  type        = string
  default     = "7b57073b-ddb7-48b7-a261-a2f74e30e59f"
}
 variable "client_secret" {
  description = "The Client Secret of the service principal for authentication in the target account"
  type        = string
  sensitive   = true
  default     = "giK8Q~iJS7ItlLO39_B_VZBOUZORtjYvh2pyocMr"
}
 variable "tenant_id" {
  description = "The Tenant ID of the service principal for authentication in the target account"
  type        = string
  default     = "ba255db9-2ad5-4db9-8650-6be3a3aeec5e"
}
 variable "subscription_id" {
  description = "The Subscription ID of the target account"
  type        = string
  default     = "aafa3dc0-c36e-4c43-8085-696b5820bcf3"
}
 variable "resource_group_name" {
  description = "The name of the resource group to create in the target account"
  type        = string
  default     = "umenbot"
}
 variable "location" {
  description = "The Azure region to deploy the resources in the target account"
  type        = string
  default     = "South India"
}
 variable "app_service_plan_name" {
  description = "The name of the App Service Plan in the target account"
  type        = string
  default     = "umenbot-serviceplan"
}
 variable "app_service_name" {
  description = "The name of the App Service in the target account"
  type        = string
  default     = "umenbot-appservice"
}
 variable "acr_name" {
  description = "The name of the Azure Container Registry in the source account"
  type        = string
  default     = "umenbotpythonds"
}
 variable "acr_image_name" {
  description = "The name of the Docker image in the source account ACR"
  type        = string
  default     = "umenbotpythonds"
}
 variable "acr_image_tag" {
  description = "The tag of the Docker image in the source account ACR"
  type        = string
  default     = "umenbot_python"
}
 variable "acr_username" {
  description = "The service principal app ID from the source account"
  type        = string
  default     = "af4220dd-c081-40c4-9618-8c02be12cf53"
}
 variable "acr_password" {
  description = "The service principal secret from the source account"
  type        = string
  sensitive   = true
  default     = "VM18Q~eU.SXVhr1vzT82QnIeMfcvdF6lZM2SgcnW"
}
