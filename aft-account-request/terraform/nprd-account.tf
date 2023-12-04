# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-3.0
#
module "sandbox_account_02" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail = "nprd@example.com"
    AccountName  = "nprd"
    # Syntax for top-level OU
    ManagedOrganizationalUnit = "Workload"
    # Syntax for nested OU
    # ManagedOrganizationalUnit = "Sandbox (ou-xfe5-a8hb8ml8)"
    SSOUserEmail     = "nprd@example.com"
    SSOUserFirstName = "nprd"
    SSOUserLastName  = "account"
  }

  account_tags = {
    "ABC:Owner"       = "nprd@example.com"
    "ABC:Division"    = "ENG"
    "ABC:Environment" = "Dev"
    "ABC:CostCenter"  = "000003"
    "ABC:Vended"      = "true"
    "ABC:DivCode"     = "103"
    "ABC:BUCode"      = "DEV003"
    "ABC:Project"     = "000003"
  }

  change_management_parameters = {
    change_requested_by = "Admin"
    change_reason       = "Enable NPRD Account"
  }

  custom_fields = {
    project = "nprd"
    environment = "nprd"
    cidr_block = "10.64.0.0/24"
    region  = "us-east-1"
  }

  account_customizations_name = "nprd"
}
