# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
module "network" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail = "network@example.com"
    AccountName  = "network"
    # Syntax for top-level OU
    ManagedOrganizationalUnit = "Infrastructure"
    # Syntax for nested OU
    # ManagedOrganizationalUnit = "Sandbox (ou-xfe5-a8hb8ml8)"
    SSOUserEmail     = "network@example.com"
    SSOUserFirstName = "Network"
    SSOUserLastName  = "Account"
  }

  account_tags = {
    "ABC:Owner"       = "network@example.com"
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
    change_reason       = "Enable Network Account"
  }

  custom_fields = {
    project = "network"
    environment = "prd"
    cidr_block_summarized_us = "10.166.0.0/16"
    cidr_block_summarized_sa = "10.164.0.0/16"
    cidr_block_us = "10.166.0.0/22"
    cidr_block_sa = "10.164.0.0/22"
    fwd_rule_domain_name = "example.com"
  }

  account_customizations_name = "network"
}
