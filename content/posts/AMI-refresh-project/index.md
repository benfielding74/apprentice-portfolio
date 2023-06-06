---
title: "AMI Refresh Project"
date: 2023-05-28T17:14:42+01:00
draft: true
---

### Situation

In order to patch vulnerabilities and install software version updates so as to decrease the attack surface or servers and ensure they are equipped to support feature team applications, a process is in place within our department that builds a new Amazon Machine Image.  This is then updated within the application and infrastructure stacks by applying Terraform before finally Auto Scaling Group refreshes are manually carried out to apply the new launch templates. This manual process is carried out on a bi-weekly basis. The ASG refresh for production environment has to be carried out as an Out-of-hours task.

### Task

A project team has been assembled consisting of myself, another apprentice and a fast-stream staff member, supported by two of the senior engineers. Our task is to find a way to automate the process of refreshing the auto scaling groups and testing that they are running. This turned out to be phase one of the task/project as once we had completed this intial step we were asked to also implement automation for the AMI build and the launch template updates. 

### Action

Our first project meeting was held to discuss how we might carry out the task. We met in person, as we felt it was the best option to give us the bandwidth to share ideas synchronously, and discussed setting up a Jenkins build pipeline that could update the AMI in the launch template after building, refresh the Auto Scaling Groups and then carry out some checks and smoke tests.  Another option that we explored and discounted was to write a script using one of the AWS SDK's or CLI commands that could be placed on an instance, then run on a scheduled cron job. We then looked at AWS serverless options such as Lambda and decided that we could quickly build and deploy a Lambda that would update the Auto Scaling Group launch templates with the newly built AMI and then refresh the ASG's. We decided to create a spike of this option first to see if it would work.[(*K19*)]({{< ref "/posts/work-mapping-table#K19.1">}})

Due to the scale of the project we each took on different tasks throughout. We created a list of issues we wanted to resolve and then created tickets to tackle each issue. I first researched how we used Hashicorp Packer to build the AMI. This is done with a Jenkins build job that is scheduled to build each week. Once the AMI is built it is pushed to AWS Elastic Container Registry where it can be used by the launch templates. We discussed as a team how to trigger the Lambda that would handle the ASG refreshes and decided to use resource tagging to add meta data to the ASG's which logic in the Lambda code could use to determine if it needed to be refreshed as part of that event.

#### HACK HW-352 Implementation of default tags

The Lambda created by another project member pulls tags from the ASG for each project for comparison before updating the AMI version on the launch template.

These default tags are set in a project config module within the `variables _workspace.tf` file. I communicated with the feature teams and our team lead to agree a schedule for the automated refreshes that would not disrupt service for the public facing apps and then implemented the default schedule tags.[(*K18*)]({{< ref "/posts/work-mapping-table#K18.2">}})

```hcl

variable "ami_refresh_schedule" {
  type = map(object({
    AMI_update_day  = string
    AMI_update_time = string
  }))
  description = "An AMI update schedule for variable Valid Values are HH:MM, mon, tue, wed, thur, fri, sat, sun"
  default = {
    sandbox = {
      AMI_update_day  = "sun"
      AMI_update_time = "19:00"
    },
    dev = {
      AMI_update_day  = "sun"
      AMI_update_time = "19:00"
    },
    qa = {
      AMI_update_day  = "mon"
      AMI_update_time = "15:00"
    },
    qa2 = {
      AMI_update_day  = "tue"
      AMI_update_time = "15:00"
    },
    test = {
      AMI_update_day  = "mon"
      AMI_update_time = "15:00"
    },
    training = {
      AMI_update_day  = "mon"
      AMI_update_time = "15:00"
    },
    build = {
      AMI_update_day  = "mon"
      AMI_update_time = "15:00"
    },
    stage = {
      AMI_update_day  = "tue"
      AMI_update_time = "15:00"
    },
    prod = {
      AMI_update_day  = "wed"
      AMI_update_time = "15:00"
    }
  }
}

```
These tags are then referenced in the project config `tags.tf` and passed to outputs.tf for use in the project stacks. This gives flexibility then to the feature teams, or anyone else who may want to use the project in the future, as they are then able to override the schedule by calling the tags in a `locals.tf` file of their own project and then setting their own schedule.

```hcl

locals {
  ami_refresh_schedule = {
    sandbox = {
      AMI_refresh_day = "mon"
      AMI_refresh_time = "10:00"
    }
  }
}

locals {
  refresh_tags = merge(module.config.items.tags.refresh, local.ami_refresh_schedule[local.environment])
}

```

We deployed the Lambda to the Sandbox environment and implemented the tagging on one of the project stacks to be able to test. Once this was successfully implemented we held a meeting with the team leads to discuss project progress and demonstrate our solution.[(*S1*)]({{< ref "/posts/work-mapping-table#S1.1">}}) The team lead liked our solution and asked us to expand on it in the next phase of the project by adding a Lambda to update the new AMI version in the ASG launch templates so that we would not need to apply Terraform to do this and also to look into how we could add notifications and tests. 

#### HW-372 Create Notification and alerting system for automated refreshes

My next project ticket was to create the Notification and alerting system. I decided to use Lambda again to trigger alerts and notifications to Slack as I had successfully implemented this previously on another project. My Lambda would be triggered by a Cloudwatch event notifying that the refresh process had taken place and also by any payload from the testing Lambda that another colleague was working on. I used conditions to determine which of these payloads was triggering the Lambda and to then act accordingly.

``` python

def lambda_handler(event, context):
# variables
  webhook_url = 'https://hooks.slack.com/services/EXAMPLE'
  channel_name = 'ami-refresh'
  log_message = event
  message = 'ASG REFRESH'
  attachment = []
  color = 'good'
  title = ''

# processing different message types 
  result = log_message.keys()
  if 'Payload' in result:
    res = log_message['Payload']['Payload']['Test_result']
    if res == 'pass':
      message = 'ASG tests passed, refresh complete'
      title = log_message['Payload']['Payload']['slack_message']
    elif res == 'fail':
      message = 'ASG tests failed, starting rollback'
      title = log_message['Payload']['Payload']['slack_message']
      color = 'danger'
  elif 'InstanceRefreshState' in result:
    res = log_message['InstanceRefreshState']
    if res == 'Started':
      asg = log_message['ASG_name']
      message = 'Starting ASG Refresh'
      title = 'Starting refresh of ' + asg

  # set up contents of message
  attachment_value = {}
  attachment_value['color'] = color
  attachment_value['title'] = title
  attachment.append(attachment_value)

# once trigger is received then send the message
  message_payload = {
    'text': message,
    'channel': channel_name,
    'attachments': attachment
  }

  req_slack = Request(webhook_url, json.dumps(message_payload).encode('utf-8'))
  response = urlopen(req_slack)
  response.read()
  logger.info("Message posted to %s", message_payload['channel'])

```

The other project members had been working on testing that the refreshed ASG's were healthy and implementing Terraform to grant neccesary permissions and to deploy the Lambda's. At this stage we held another project meeting and a show and tell session to talk through our work with other members of the team. THe feedback overall was good but there was some concern about how we were going to orchestrate the four Lambdas we now had deployed and that our initial testing process was not sufficient to determine if applications were running. We decided to carry out some further research and see how we could address the concerns raised.


### Result