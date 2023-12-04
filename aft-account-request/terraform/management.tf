# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
module "management" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail = "user@example.com"
    AccountName  = "John Doe"
    # Syntax for top-level OU
    ManagedOrganizationalUnit = "Root"
    # Syntax for nested OU
    # ManagedOrganizationalUnit = "Sandbox (ou-xfe5-a8hb8ml8)"
    SSOUserEmail     = "user@example.com"
    SSOUserFirstName = "John"
    SSOUserLastName  = "Doe"
  }

  account_tags = {
    "ABC:Owner"       = "user@example.com"
    "ABC:Division"    = "ENG"
    "ABC:Environment" = "Dev"
    "ABC:CostCenter"  = "000001"
    "ABC:Vended"      = "false"
    "ABC:DivCode"     = "001"
    "ABC:BUCode"      = "DEV001"
    "ABC:Project"     = "000001"
  }

  change_management_parameters = {
    change_requested_by = "Admin"
    change_reason       = "Enable Management Account"
  }

  custom_fields = {
    custom1 = "a"
    custom2 = "b"
  }

  account_customizations_name = "management"
}
