# #############################################################################
# Notification Manager resources
# #############################################################################

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "notification_manager" {
  name     = "${module.resource_group.name.abbreviation}-CoolRevive-Remanufacturing-NotificationManager-${var.azure_environment}-${module.azure_regions.region.region_short}"
  location = module.azure_regions.region.region_cli
  tags     = local.tags
}

# -----------------------------------------------------------------------------
# Communication Services
# -----------------------------------------------------------------------------

resource "azurerm_email_communication_service" "notification_manager" {
  name                = "email-NotificationManager${var.resource_name_suffix}-${var.azure_environment}-${module.azure_regions.region.region_short}"
  resource_group_name = azurerm_resource_group.notification_manager.name
  data_location       = var.acs_data_location
  tags                = local.tags
}

resource "azurerm_email_communication_service_domain" "notification_manager" {
  name              = "AzureManagedDomain"
  email_service_id  = azurerm_email_communication_service.notification_manager.id
  domain_management = "AzureManaged"
}

resource "azurerm_communication_service" "notification_manager" {
  name                = "${module.communication_services.name.abbreviation}-NotificationManager-${var.azure_environment}-${module.azure_regions.region.region_short}"
  resource_group_name = azurerm_resource_group.notification_manager.name
  data_location       = var.acs_data_location
  tags                = local.tags
}

#resource "azurerm_key_vault_secret" "communication_service_connection_string" {
#  name         = "NotificationManager-CommunicationService-ConnectionString"
#  value        = azurerm_communication_service.notification_manager.primary_connection_string
#  key_vault_id = azurerm_key_vault.remanufacturing.id
#}
#
#resource "azurerm_app_configuration_key" "communication_services_connection_string" {
#  configuration_store_id = azurerm_app_configuration.remanufacturing.id
#  key                    = "NotificationManager:CommunicationService:ConnectionString"
#  type                   = "vault"
#  label                  = var.azure_environment
#  vault_key_reference    = azurerm_key_vault_secret.communication_service_connection_string.versionless_id
#  lifecycle {
#    ignore_changes = [
#      value
#    ]
#  }
#}

# -----------------------------------------------------------------------------
# Service Bus Topic: Next Core in Transit
# -----------------------------------------------------------------------------

resource "azurerm_servicebus_subscription" "nextcoreintransit_notificationmanager" {
  name                                      = "${module.service_bus_topic_subscription.name.abbreviation}-CoolRevive-NCIT-NotifyMgr${var.resource_name_suffix}-${var.azure_environment}-${module.azure_regions.region.region_short}"
  topic_id                                  = azurerm_servicebus_topic.next_core_in_transit.id
  dead_lettering_on_filter_evaluation_error = false
  dead_lettering_on_message_expiration      = true
  max_delivery_count                        = 10
}