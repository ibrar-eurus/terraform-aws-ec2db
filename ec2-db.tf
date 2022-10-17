resource "aws_security_group" "dbinstance" {
  name        = "${terraform.workspace}-db_instance-sg"
  description = "Allow ssh inbound traffic"
    vpc_id      = var.vpc_id

  ingress {
    description      = "ssh from db"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "mysql from db"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "${terraform.workspace}-db-SG"
  }
}

resource "aws_instance" "db_instance" {
  ami           = var.ami
  key_name      = var.key_name
  subnet_id = var.privatesubnet
  security_groups  = [aws_security_group.dbinstance.id]
  instance_type = var.instance_type
  user_data = <<-EOF
                #!/bin/bash
                apt update -y 
                apt install mysql-server -y
                mysql -u root -p' ' -e "CREATE USER '${var.DBusername}'@'%' IDENTIFIED BY '${var.password}';"
                mysql -u root -p' ' -e "GRANT ALL PRIVILEGES ON *.* TO '${var.DBusername}'@'%' ;"
                mysql -u ${var.DBusername} -p'${var.password}' -e "CREATE DATABASE ${var.Dbname};"
                mysql -u ${var.DBusername} -p'${var.password}' -e "exit;"
                cd /etc/mysql/mysql.conf.d
                sed -i 's/bind-address/#bind-address/' mysqld.cnf
                sed -i 's/mysqlx-#bind-address/mysqlx-bind-address/' mysqld.cnf
                systemctl restart mysql
                EOF
  tags = {
    Name = "${terraform.workspace}-ibrar_db"
  }
}