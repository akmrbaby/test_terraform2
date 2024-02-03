resource "azurerm_service_plan" "common" {
  name                = "asp-${var.project}-${var.env}-${var.location}-001"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1" // F1 にしてみる
  // ref: https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans
  // sku として指定できる値：「B1 B2 B3 S1 S2 S3 P1v2 P2v2 P3v2 P1v3 P2v3 P3v3 Y1 EP1 EP2 EP3 F1 FREE I1 I2 I3 I1v2 I2v2 I3v2 D1 SHARED WS1 WS2 WS3」
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.project}-${var.env}-${var.location}-001"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.common.id

  public_network_access_enabled = false // プライベートエンドポイント追加前は、true/false がうまく動いていた。Azure上の表示が変なだけで、pep あっても上手く設定できてそう！

  site_config {
    always_on = false

    application_stack {
      docker_image_name = "nodejs-app:latest"  // コンテナレジストリのサーバー名などは、アプリの環境変数として設定するのが推奨になった。
    }

    ip_restriction {
      name = "Deny all"
      action = "Deny"
      ip_address = "0.0.0.0/0"
      priority = 500
    }
    ip_restriction {
      name = "Allow from myNet"
      action = "Allow"
      ip_address = "106.178.0.0/16"
      priority = 300
    }
  }

  app_settings = {
    WEBSITES_PORT                   = 3000
    DOCKER_REGISTRY_SERVER_PASSWORD = var.container_registry_password
    DOCKER_REGISTRY_SERVER_URL      = "${var.container_registry_name}.azurecr.io"
    DOCKER_REGISTRY_SERVER_USERNAME = var.container_registry_user
  }

  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 0
        retention_in_mb   = 35
      }
    }
  }
}

resource "azurerm_private_endpoint" "app" {
  name                = "pep-${var.project}-${var.env}-${var.location}-001"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.app_pep.id
  private_dns_zone_group {
    name = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.app.id]
  }
  private_service_connection {
    name = "privateendpointconnection"
    private_connection_resource_id = azurerm_linux_web_app.app.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}