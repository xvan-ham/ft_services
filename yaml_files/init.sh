#!/bin/bash

 echo "Starting Services needed to launch ft_server:" && \
			service mysql start && \
			echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password && \
			echo "GRANT ALL ON wordpress.* TO 'root'@'localhost';" | mysql -u root --skip-password && \
			echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password && \
			echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql -u root --skip-password &&\
			service nginx start && \
			service php7.3-fpm start && \
			service php7.3-fpm status && \
			export PATH=$PATH:/home/bin && \
			/bin/bash
