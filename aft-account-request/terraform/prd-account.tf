# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
module "sandbox_account_01" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail = "prd@example.com"
    AccountName  = "prd"
    # Syntax for top-level OU
    ManagedOrganizationalUnit = "Workload"
    # Syntax for nested OU
    # ManagedOrganizationalUnit = "Sandbox (ou-xfe5-a8hb8ml8)"
    SSOUserEmail     = "prd@example.com"
    SSOUserFirstName = "prd"
    SSOUserLastName  = "account"
  }

  account_tags = {
    "ABC:Owner"       = "prd@example.com"
    "ABC:Division"    = "ENG"
    "ABC:Environment" = "Dev"
    "ABC:CostCenter"  = "000002"
    "ABC:Vended"      = "true"
    "ABC:DivCode"     = "102"
    "ABC:BUCode"      = "DEV002"
    "ABC:Project"     = "000002"
  }

  change_management_parameters = {
    change_requested_by = "Admin"
    change_reason       = "Enable PRD Account"
  }

  custom_fields = {
    project = "prd"
    environment = "nprd"
    cidr_block = "10.64.1.0/24"
    region  = "sa-east-1"
  }

  account_customizations_name = "prd"
}
