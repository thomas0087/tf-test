
mock_provider "aws" {}

run "check_instance_type" {

  command = plan

  assert {
    condition     = aws_instance.barry.instance_type == "m7g.micro"
    error_message = "EC2 instance must be a Graviton instance"
  }
}

run "check_ami_owner" {

  command = plan

  assert {
    condition     = data.aws_ami.barry_image.owners[0] == "441581275790"
    error_message = "The AMI should be from control general"
  }
}

run "check_user_data" {

  command = plan

  assert {
    condition     = strcontains(aws_instance.barry.user_data, "Configure-Instance.ps1")
    error_message = "Userdata should contain the specified script"
  }
}
