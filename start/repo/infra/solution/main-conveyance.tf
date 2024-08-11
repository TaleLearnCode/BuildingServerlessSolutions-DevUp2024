# #############################################################################
# Conveyance resources
# #############################################################################

# -----------------------------------------------------------------------------
# Storage Blob Container
# -----------------------------------------------------------------------------

resource "azurerm_storage_container" "conveyance" {
  name                  = "conveyance"
  storage_account_name  = azurerm_storage_account.remanufacturing.name
  container_access_type = "private"
}