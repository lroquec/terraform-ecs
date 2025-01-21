project_name           = "testing-ground"
container_image        = "lroquec/cicd-tests:latest"
ecs_cluster_name       = "MyECSCluster"
task_definition_family = "MyflaskApp"
ecs_service_name       = "MyflaskAppService"
container_port = 5000