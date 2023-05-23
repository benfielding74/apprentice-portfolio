---
title: "Hack 4361"
date: 2023-05-23T18:57:19+01:00
draft: true
---

### Situation

The Nomad health check for the Find and Refer kong-traefik(1) service is failing. Following Traefik deployment a smoke test is run, this test simply curls some URL's specific to the deployment. A response code HTTP 200 is the expected response, anything else will cause the health check to fail. Some preliminary investigation has identified that the health check is curling an incorrect end point.

### Task

The requirements of the ticket are to adjust the health check as neccessary

### Action

### Result

*(1)Kong Gateway is a lightweight, fast, and flexible cloud-native API gateway. An API gateway is a reverse proxy that lets you manage, configure, and route requests to your APIs. Kong Gateway runs in front of any RESTful API and can be extended through modules and plugins. It’s designed to run on decentralized architectures, including hybrid-cloud and multi-cloud deployments.*

*Traefik is a reverse proxy that sits between client requests and the backend services that handle those requests. It works by inspecting incoming requests and using a set of rules to determine how to route the request to the appropriate backend service*