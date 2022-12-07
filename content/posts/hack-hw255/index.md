---
title: "Hack Hw255"
date: 2022-12-05T12:13:26Z
draft: true
---

### Situation

* Request for production database access from a dev team
 The requirement is to report against statistical information to inform:

a local job service trial; and
and future national reporting

They have explored using Charts in mongodb atlas, testing in a non production environment using dummy data and now need access to the production database to complete their task

### Task

A request for access to prod database has been approved by SDS for them to have Read Only access to prod database and write access to Charts in atlas. My task is to explore roles and permissions with mongodb atlas Charts to provide the minimum amount of access to the production database whilst still being able to fully use the charts feature and then to implement this.

### Action

* Research roles and permissions in mongodb - least privilege etc reference article
* Test on myself permissions and ability to create and edit charts - stages
* Discuss with colleague and with senior
* Attempt to create a custom role in UI without success, further reading (reference articles)
* CLarify access with SDS - SC cleared have access to prod but not ideal so proceed with least possible permission reference our security clearance stuff and GDPR k3 and k22
* Support ticket with mongodb - clarified that user needs data access to prod to work with charts
* Set up access in Mongodb UI
* Document process and apply to Terraform within project so it is a repeatable process
* Peer review on Terraform changes and on documentation

### Result

* What did I learn
* Benefits to the business
