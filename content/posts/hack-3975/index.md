---
title: "hack-3975"
date: 2022-06-29T12:05:16+01:00
draft: true
---

#### Situation:

A request for a feature was added to team Knaban board. In a legacy project the Devs received a notification to a Slack channel whenever a file is added
or deleted from their S3 buckets. They were requesting that this functionality be added to the current project.

> As a developer I would like to receive a notification into the #uc-far-prod-alerts Slack channel whenever an object is added to or deleted from the new
S3 buckets. The alert should contain the following information: Bucket name, file name, size of file in bytes

---

#### Task:

Deploy a Lambda function to the existing infrastructure, using Terraform, which will listen for actions in the projects S3 buckets and then send notifications 
to the relevant Slack channel. This would involve setting up additional infrastructure for the AWS SNS service and for the Lambda function.

---

#### Actions:

I met with my line manager and discussed how I could go about resolving the request in the ticket and what I would need to do. My LM arranged access to the 
legacy account mentioned so I could look at the Lambda function there as well as any roles, permissions and SNS settings that I might need to familiarise myself
with. We agreed that I would outline a plan for my approach and discuss it with him.

**My Plan**

* Research AWS Lambda and decide if the legacy account Lambda could be revised and resused in the new project
* Research AWS SNS and the new concepts of topics and subscriptions which would needed
* Set up the infrastructure to deploy the Lambda function in a sandbox environment within an example application Terraform stack in the exisiting codebase
* Test that adding or removing objects from a test bucket triggered notifications to my Slack
* Move the changes into the project Terraform stack and through sandbox, stage and finally production

My LM agreed this was a good approach and so I moved the ticket into 'in progress' and started to work.

The Terraform stack for an example application within our codebase introduced me to new concepts that I had not covered in the bootcamp. The Terraform is 
split into modules that do different things within the infrastructure such as creating S3 buckets, creating IAM roles and setting permissions, setting up the 
network, and deploying a Lambda function. The modules are all version controlled within a GitLab repositories and to call a module into th eproject for use
you add the module URL and version to a Terrafile. I updated the Terrafile to include a Lambda module and an IAM module as these were missing from the example
application project. I then identified which files within the project I would need to append or alter. These were:

* iam.tf - which contains all of the IAM roles, granting permissions for the Lambda
* project.tf - which invokes the different modules
* lambda.tf in the lambda module - to set up infrastructure for the Lambda function, zip the lambda and deploy it
* I also had to place the lambda_function.py file in a /src directory at the root of the project



