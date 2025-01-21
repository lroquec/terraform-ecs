project_name           = "testing-ground"
container_image        = "lroquec/cicd-tests:latest"
ecs_cluster_name       = "myECSCluster"
task_definition_family = "myflaskApp"
ecs_service_name       = "myflaskapp"
container_port         = 5000