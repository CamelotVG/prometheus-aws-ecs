# prometheus-aws-ecs
Prometheus on ECS

This is a terraform project to automate the provisioning of a ECS cluster with the following containers:

* Prometheus - need mount point in /etc/prometheus to load the config.yml
* Grafana
* cAdvisor
* etc


The ECS cluster instances are:

* Mounting EFS on each instance using the user-data script from the launch configuration.

* Instance image : amzn-ami-2017.03.f-amazon-ecs-optimized (ami-8fcc32f6)


At the moment you can get the task definitions. I will upload the rest soon.

Interesting links:

* https://aws.amazon.com/blogs/compute/running-an-amazon-ecs-task-on-every-instance/
