# Terraform Packer Example Stack

## Overview

This repository is used to demonstrate how we use Packer and Terraform to create a basic 3 tier app. Here is a basic description for the problem that this repository intends to solve:

- Build a basic web app that should run within AWS using best practices. 

Please see [Caveats](## Caveats) section for relevant Caveats to using this repository

## Requirements

- Requred Terraform v0.14.0 or above
- Required packer 1.6.6 or above version
- AWS Account with access to S3, EC2, R53 resources
- Everything in private subnets with internet access via NAT gateways
- Instances set up with Autoscaling Groups being Elastic Load Balancers
- Require to generate ssh  keys 
- Required s3 bucket in eu-west-1
- Generate an aws keypair for use in terraform

## Build Flow

- Images with required packages, OS updates and app code are to be built using Packer. These will become the deployment artifacts
- Once images are created, then Terraform will build the required environments (Dev, QA, Prod) depending on user requirements.

--------

## Packer

We are using AMIs that are built using Hashicorp Packer that uses Ansible to provision the image.

The Ansible playbook is located within `packer/playbooks`

The Ansible role does the following
- Modify the default SSH port (modified to port 2849)
- Disable root login
- Create a standard user called deploy with full sudo privileges
- Created a nginx static web page (Tested with my domain http://srikarun-dev-web-elb-1150215799.eu-west-1.elb.amazonaws.com/)
- Created a shell script called monitordiskspace to report usage on the main filesystem of the host, i.e “ / “ 
  The script records the amount of free disk space a timestamp, and write it out to a log file named /var/log/freespace 
- Configured cron to allow the script monitordiskspace to execute every 5min
- Configure log rotation to rotate and compress the log file every 1 hour, retaining a maximum of 10 rotated logs.
- Configure an external repo (github.com/firehol/netdata.git) and install netdata, ensure it starts on machine boot

## Perform the following action
```shell
# Clone the repo https://github.com/srikantharun/terraform-packer
cd /opt; git clone https://github.com/srikantharun/terraform-packer

# Create a ssh key pair and copy to the playbook files folder
cd /opt/terraform-packer; ssh-keygen -t rsa -f ${PWD}/id_rsa -N '';
cp id_rsa.pub /opt/terraform-packer/packer/playbooks/roles/web/files/authorized_keys

# create an aws keypair to be used in tfvars before running terraform
aws ec2 create-key-pair --key-name srikanth-ao --region eu-west-1 --query 'keyMaterial' --output text > srikarun-ao.pem

#Create a s3 bucket in eu-west-1 and use that as terraform backend in terraform/environment/dev/dev.tf

#Install packer and terraform before executing below commands
cd /opt/terraform-packer/packer && packer validate base.json
packer build base.json

#Once packer execution is complete, please copy the ami image name and use them in the terraform/environment/dev/dev.tfvars for bastion_ami

#Please edit /opt/terraform-packer/terraform/environment/dev/dev.tfvars and replace required variables including domain name

#Execute Terraform Steps
cd /opt/terraform-packer/terraform/environment/dev
terraform init
terraform plan --var-file=dev.tfvars
terraform apply --var-file=dev.tfvars
```

### Caveats

- The ssh keys to be kept locally as that is the only source to any hosted VMs

- Only http based web page is displayed, did not enable certificate due to time constraint
