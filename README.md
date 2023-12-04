# aft-sample
A Sample with a robust AWS account connectivity using AWS AFT
This repo contains the main four repos from (https://github.com/aws-ia/terraform-aws-control_tower_account_factory) with the principal assets and configuration necessary to have a up and running AWS Account Connectivity.

# Network Account
The Network account contains two transit gateway divided by two main regions, specific route tables and VPCs to follow:
1. A centralized outbound and inbound VPC
2. Network Firewall Inspection North-South and West-East
3. Transit Gateway Peering

# PRD Account
The PRD account has all the automation to connect into the correct transit gateway based on region and has Internet connectivity

# NPRD
The NPRD account has all the automation to connect into the correct transit gateway based on region and has Internet connectivity

# Get Start
Replace the following variables into your env:
- LOGS_ACCOUNT_ID
- AFT_ACCOUNT_ID
- NETWORK_ACCOUNT_ID

You need to have the AFT installed into your environment following this doc: https://docs.aws.amazon.com/controltower/latest/userguide/aft-getting-started.html
You also need to create a bucket to store the VPC FLow logs on your LOGS_ACCOUNT_ID