/*
1: Create a custom vpc in ca-central-1 region.
2: Create IGW for the vpc to have internet access
3: Create a RT
4: Create a subnet
5: Perform a subnet association
6: Create a S.G to allow port 80, 22 and 443
7: Create a network interface
8: Assigning an elastic IP to the network interface created in step 7 above
9: Install httpd on Amazon ec2 server

Note: In other to ssh into the ec2 instance, i had to create a key-pair need on ec2 dashbord and the key name
was referenced under ec2 resource block.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider Block
provider "aws" {
  profile = "default" #AWS credentials Profile configured on local environment
  region  = "ca-central-1"
}
