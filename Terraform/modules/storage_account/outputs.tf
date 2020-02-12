# Module Outputs
output "storage_uri" {
    value = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
}
