module "storage_account" {
  source  = "claranet/storage-account/azurerm"
  version = "~> 8.2.0"

  location       = var.location
  location_short = var.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = var.resource_group_name

  name_prefix                     = var.name_prefix
  name_suffix                     = var.name_suffix
  custom_name                     = var.custom_name
  diagnostic_settings_custom_name = var.diagnostic_settings_custom_name

  access_tier              = var.access_tier
  account_kind             = var.is_premium ? "BlockBlobStorage" : "StorageV2"
  account_tier             = var.is_premium ? "Premium" : "Standard"
  account_replication_type = var.account_replication_type

  https_traffic_only_enabled  = var.https_traffic_only_enabled
  public_nested_items_allowed = var.public_nested_items_allowed
  shared_access_key_enabled   = var.shared_access_key_enabled
  min_tls_version             = var.min_tls_version

  static_website_config = var.static_website_config

  sftp_enabled  = true
  nfsv3_enabled = var.nfsv3_enabled

  containers = var.containers

  blob_data_protection = var.blob_data_protection
  blob_cors_rules      = var.blob_cors_rules

  advanced_threat_protection_enabled = var.advanced_threat_protection_enabled

  network_rules_enabled   = var.network_rules_enabled
  default_firewall_action = var.default_firewall_action
  subnet_ids              = var.subnet_ids
  allowed_cidrs           = var.allowed_cidrs
  network_bypass          = var.network_bypass
  private_link_access     = var.private_link_access

  identity_type = var.identity_type
  identity_ids  = var.identity_ids

  logs_destinations_ids   = var.logs_destinations_ids
  logs_categories         = var.logs_categories
  logs_metrics_categories = var.logs_metrics_categories

  default_tags_enabled = var.default_tags_enabled

  extra_tags = var.extra_tags
}
