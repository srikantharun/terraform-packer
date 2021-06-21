env = "dev"

aws_region = "eu-west-1"

prefix = "srikarun"

db_prefix = "srikarun"

owner = "srik-arun"

cidr_range = "10.230.0.0/16"

azs = "eu-west-1a,eu-west-1b,eu-west-1c"

public_subnets = "10.230.11.0/24,10.230.12.0/24,10.230.13.0/24"

private_subnets = "10.230.14.0/24,10.230.15.0/24,10.230.16.0/24"

in_allowed_cidr_blocks = "185.73.154.30/32"

bastion_ami = "ami-06a41750343781de7"

bastion_instance_type = "t2.micro"

web_instance_type = "t2.micro"

ssh_key_pair_name = "srikarun-ao"

asg_instance_type = "t2.micro"

asg_min_size = 2

asg_max_size = 6

asg_desired_capacity = 3

domain_name = "srikarun.co.uk"

email = "test@srikarun.co.uk"

db_instance_class = "db.t2.micro"

db_username = "db_user"

db_password = "abcdefghi123456789"

db_size = 5
