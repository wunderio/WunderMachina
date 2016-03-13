# DBserver role

Variables you can define:
partition_var_lib_mysql: True
change_db_root_password: True
mariadb_root_password: root
innodb_buffer_pool_size: 1024

When setting up the role for the first time you can
change the root password with the following in command line:
--extra-vars "change_db_root_password=True mariadb_root_password=[your_secure_password]"