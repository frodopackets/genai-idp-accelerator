# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}