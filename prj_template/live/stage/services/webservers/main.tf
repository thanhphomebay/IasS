module "webservers" {
  source = "../../../../modules/services/webservers"
  env = "dev"
  cluster_name           = "webservers-stage"
  #  db_remote_state_bucket = "(YOUR_BUCKET_NAME)"
  #db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"
  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
}
