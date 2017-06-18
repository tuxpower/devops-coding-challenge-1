Infrastructure Coding Test
==========================

# Goal

Script the creation of a web server, and a script to check the server is up.

# Prerequisites

You will need an AWS account. Create one if you don't own one already. You can use free-tier resources for this test.

# The Task

You are required to set up a new server in AWS. It must:

* Be publicly accessible.
* Run Nginx.
* Serve a `/version.txt` file, containing only static text representing a version number, for example:

```
1.0.6
```

# Mandatory Work

Fork this repository.

* Provide instructions on how to create the server.
* Provide a script that can be run periodically (and externally) to check if the server is up and serving the expected version number. Use your scripting language of choice.
* Alter the README to contain the steps required to:
  * Create the server.
  * Run the checker script.
* Provide us IAM credentials to login to the AWS account. If you have other resources in it make sure we can only access what is related to this test.

Give our account `engagetech` access to your fork, and send us an email when you’re done. Feel free to ask questions if anything is unclear, confusing, or just plain missing.

# Extra Credit

We know time is precious, we won't mark you down for not doing the extra credits, but if you want to give them a go...

* Use a CloudFormation template to set up the server.
* Use a configuration management tool (such as Puppet, Chef or Ansible) to bootstrap the server.
* Put the server behind a load balancer.
* Run Nginx inside a Docker container.
* Make the checker script SSH into the instance, check if Nginx is running and start it if it isn't.

# Questions

#### What scripting languages can I use?

Anyone you like. You’ll have to justify your decision. We use Bash, Python and JavaScript internally. Please pick something you're familiar with, as you'll need to be able to discuss it.

#### Will I have to pay for the AWS charges?

No. You are expected to use free-tier resources only and not generate any charges. Please remember to delete your resources once the review process is over so you are not charged by AWS.

#### What will you be grading me on?

Scripting skills, ellegance, understanding of the technologies you use, security, documentation.

#### Will I have a chance to explain my choices?

Feel free to comment your code, or put explanations in a pull request within the repo.
If we proceed to a phone interview, we’ll be asking questions about why you made the choices you made.

#### Why doesn't the test include X?

Good question. Feel free to tell us how to make the test better. Or, you know, fork it and improve it!

# Challenge Accepted

#### How to create the server

Start by exporting the configuration variables for the AWS user, i.e.:

```bash
$ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
$ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
$ export AWS_DEFAULT_REGION=eu-west-1
```

Then using AWS cli create a stack with the CloudFormation template available in this repo:

```bash
$ aws cloudformation create-stack \
--stack-name DevOpsCodingChallenge \
--template-body file://DevOpsCodingChallenge.template \
--parameters ParameterKey=InstanceType,ParameterValue=t2.micro \
ParameterKey=KeyName,ParameterValue=devops-key \
ParameterKey=SSHLocation,ParameterValue="0.0.0.0/0" \
ParameterKey=Subnets,ParameterValue=subnet-47a8391e\\,subnet-861046e3\\,subnet-d1c2bda6 \
ParameterKey=VpcId,ParameterValue=vpc-3ce38759 
```

Check stack status by running the following command:

```bash
$ aws cloudformation describe-stacks --stack-name DevOpsCodingChallenge --query "Stacks[*].StackStatus" --output text
CREATE_IN_PROGRESS
```

When it finishes the stack status should change to COMPLETE:

```bash
$ aws cloudformation describe-stacks --stack-name DevOpsCodingChallenge --query "Stacks[*].StackStatus" --output text
CREATE_COMPLETE
```

Only then get the URL of the loadbalancer:

```bash
$ aws cloudformation describe-stacks --stack-name DevOpsCodingChallenge --query "Stacks[*].Outputs[3].OutputValue" --output text
http://DevOp-Appli-19K2DJZCEDV6D-157884943.eu-west-1.elb.amazonaws.com
```

Check you can access the loadbalancer and request the version.txt file:

```bash
$ curl http://DevOp-Appli-19K2DJZCEDV6D-157884943.eu-west-1.elb.amazonaws.com
$ curl http://DevOp-Appli-19K2DJZCEDV6D-157884943.eu-west-1.elb.amazonaws.com/version.txt
1.0.6
```

#### How to run the checker script

The checker script is written in bash (KISS principle). The script runs in a SSH connection and by default checks if the nginx container is running every 10 seconds. 
If is not running, it executes the same ansible playbook that was used to boostrap the server. 

* An optional interval time can be set as argument.
* Make sure you use the same SSH key defined by the time you create the cloudformation stack

```bash
$ ssh -i ~/.ssh/devops-key.pem ubuntu@54.229.177.233 '/bin/bash -s' < check-nginx.sh 10
Nginx container is running with ID 42aced6bfa38
Nginx container is running with ID 42aced6bfa38


docker: "inspect" requires a minimum of 1 argument.
See 'docker inspect --help'.

Usage:	docker inspect [OPTIONS] CONTAINER|IMAGE|TASK [CONTAINER|IMAGE|TASK...]

Return low-level information on a container, image or task
 [WARNING]: provided hosts list is empty, only localhost is available

PLAY ***************************************************************************

TASK [install docker] **********************************************************
ok: [localhost]

TASK [install docker-py] *******************************************************
ok: [localhost]

TASK [nginx container] *********************************************************
changed: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0

Nginx container is running with ID 2c66b8f30afc
Nginx container is running with ID 2c66b8f30afc
```

You can test how this script works, by estableshing a SSH connection in another session and stop the docker container:

```bash
$ ssh -i ~/.ssh/devops-key.pem ubuntu@54.229.177.233
$ sudo docker stop $(sudo docker ps -q)
```
