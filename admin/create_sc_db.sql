drop database IF EXISTS sc;
create database sc;
set password for 'root'@'localhost' = password('scadmin');
grant usage on *.* to sc@localhost identified by 'sc';
grant all privileges on sc.* to sc@localhost;
update mysql.user set password=password('sc') where user='sc';
flush privileges;
