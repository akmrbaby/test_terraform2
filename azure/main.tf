terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-common"
    storage_account_name = "terraform4ak"
    container_name       = "dev"                   // 先に手動で作成する必要あり
    key                  = "test/20240127.tfstate" // test/20240127.tfstate のように階層構造にもできる（testフォルダは init すると自動で作られる）
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "rg-${var.project}-${var.env}-${var.location}-001" // 手動で作成した rg の名前を指定
  // ※ data.azurerm_resource_group.rg.name // 参照するときは、data. を付ける必要あり
  // location = var.location // これはつけるとエラーになる
}