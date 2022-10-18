---
title: "Hack HW98"
date: 2022-10-18T14:00:48+01:00
draft: true
---

## Situation

Developer team working on application for Find and Refer service are alerted within a Slack channel when a file is added to some specific targeted AWS s3 buckets. They have made a request which has been added to the HACK team sprint as a working ticket. They have requested that 'to support incident management and ease repetitive cognitive load' they would also like to be alerted when specific files have NOT been added to their buckets by a given time.

## Task

After discussion within team about options, including deploying another Lambda to check buckets and alert, the consensus was that we should use s3-exporter. This tool had recently been implemented within the team to scrape buckets and check for backup files. I was assigned this ticket and my task was to implement a new configuration within the monitoring Terraform stack that would scrape the app buckets at given times and alert if files were not present.

## Action

Within the Terraform monitoring stack there is an alertmanager module. Alertmanager takes in alerts from the Prometheus server and then sends out notifications to another service, in this case Slack. An alert is the result of an alerting rule set up in Prometheus that is actively firing. My first step was to add a receiver to the alertmanager template that would look for alerts from my job rules and send them to the slack channel that I would designate. The file has some global rules that are common to all routes that are set up. A route block defines a node in a routing tree and it's children. Every alert sent by the Prometheus server and traverses these nodes until it finds one matching a job name. A receiver then holds the webhook of the alerting channel that the alert is to be forwarded to. To ensure variables such as the webhook weren't hardcoded into the terraform I added the webhook as a secret in Vault and configured the receiver to pull from there when the alertmanager was configured.

![example of receiver configuration](receiver.svg)

*fig 1: An example of the route and receiver configuration for this ticket*

My next step was to create the rules that would trigger the Prometheus alerts. These are written in a yml file which is used when the docker prometheus image is built and deployed. Within the yml file you set a name for the rule, which is what the receiver is looking for, and then set some rules for the alert. An expression is written in PromQL, which is a query language for Prometheus, and this sets the parameters that the s3_exporter will use to scrape the buckets. You also format the message that is delivered to Slack within this file.

![example of rules yml](rules_yml.svg)

*fig 2: An example of the rules I created for Prometheus to generate alerts*

I had to test various different queries in my expression to get the desired result. My final example checks for the last modified object in the given bucket and with the given prefix and checks between given times (between 8pm and 11pm in my example). If the object is more than 12 hours old then an alert is triggered.

## Result
