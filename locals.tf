locals {
  subnets = ["web1","web2","app1","app2","db1","db2"]
  igw_name = "myvpcig"
  anywhere = "0.0.0.0/0"
  ssh = 22
  http = 80
  tcp ="tcp"
  app = 8080
  db = 3306


}