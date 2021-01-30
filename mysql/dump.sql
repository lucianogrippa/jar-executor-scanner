CREATE DATABASE IF NOT EXISTS mywebwalletdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
INSERT IGNORE INTO `account` (`id`,`creation_date`,`email`,`enabled`,`firstname`,`last_login_date`,`lastname`,`locked`,`need_change_password`,`password_expired`,`pwd_expire_date`,`secret`,`username`) VALUES (1,'2021-01-23 18:06:41','grippa.luciano@gmail.com',1,'Luciano','2021-01-23 18:06:41','Grippa',0,0,0,'2021-01-23 18:06:41','cf84a25f4dfc48a7dc0732ebb60becd4','l.grippa');
INSERT IGNORE INTO `roles` (`id`,`code`,`name`) VALUES (1,'ROLE_ADMIN','admin');
INSERT IGNORE INTO `roles` (`id`,`code`,`name`) VALUES (2,'ROLE_USER','user');

INSERT IGNORE INTO `accounts_roles` (`account_id`,`role_id`) VALUES (1,1);
INSERT IGNORE INTO appconfig (id, app_gateway,api_gateway, app_version, language, profile) VALUES ('b28c1de1-dbb0-44b5-8418-7f939ab5325e', 'http://172.22.10.3/mywebwallet','http://172.22.10.3/mywebwallet/api/v1', '1.0.0', 'it', 'production');