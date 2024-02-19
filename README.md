# Terraform AWS EC2 Project

This repository contains a Terraform project that creates an AWS EC2 instance with a specific IAM role and security group.

## Prerequisites

Before you begin, ensure you have met the following requirements:

* You have installed the latest version of [Docker](https://docs.docker.com/get-docker/).

## Using Terraform AWS EC2 Project with Docker

To use this project with Docker, follow these steps:

1. Clone the repository to your local machine.
2. Navigate to the directory containing the project.
3. Check for vulnerabilities with TFSec

    ```bash
    docker-compose run --rm tfsec /work
    ```

4. Check linting and formatting

    ```bash
    docker-compose run --rm tflint /work
    docker-compose run --rm localtf fmt -check
    docker-compose run --rm localtf validate
    ```

5. Run tests with Terratest. All bar one of these tests will fail until you have completed the tasks below 🤓

    ```bash
    docker-compose run --rm terratest
    ```

## Tasks

We would like you to create a PR with the following changes:

1. Update to a more ESG friendly instance type `m7g.micro`
2. Update the AMI to use [nib's latest hardened base image](https://github.com/nib-group/nib-base-win)
3. Resolve the TFSec findings (and still allow the instance to act as a web server)
4. Add a userdata script to run a file named `Configure-Instance.ps1` at the root of the C drive

Success can be measured by the tests passing and/or by the interview panel. A test exists for each of these tasks, be sure that each test passes before moving on.