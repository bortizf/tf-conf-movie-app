resource "aws_db_instance" "db" {
    allocated_storage = 8
    engine = "mariadb"
    engine_version = "10.4.13"
    instance_class = "db.t3.micro"
    name = "moviedb"
    username = var.DB_USER
    password = var.DB_PASS
    skip_final_snapshot = true
    db_subnet_group_name = "movie_db_subnet_group"
    vpc_security_group_ids = [ aws_security_group.rds-sg.id ]
    publicly_accessible = false
}
