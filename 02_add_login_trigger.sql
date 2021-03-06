SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

-- ADD login information to users table
ALTER TABLE `users` DROP IF EXISTS last_login;
ALTER TABLE `users` DROP IF EXISTS last_logout;

ALTER TABLE `users` ADD `last_login` TIMESTAMP NULL AFTER `type`, ADD `last_logout` TIMESTAMP NULL AFTER `last_login`;

-- Create login tracking information

DROP TABLE IF EXISTS `logs`;

CREATE TABLE `logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  `type` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `logs`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

-- Login trigger

DROP TRIGGER IF EXISTS `user_login_trigger`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `user_login_trigger` AFTER UPDATE ON `users` FOR EACH ROW
BEGIN
  IF OLD.last_login <> NEW.last_login THEN
    INSERT INTO `logs` (`user_id`, `date`, `type`) VALUES(new.id, 'CURRENT_TIMESTAMP()', 0);
  END IF;
  
  IF OLD.last_logout <> NEW.last_logout THEN
    INSERT INTO `logs` (`user_id`, `date`, `type`) VALUES(new.id, 'CURRENT_TIMESTAMP()', 1);
  END IF;
END;

DELIMITER ;

-- Create DeleteLogs stored procedure

DROP PROCEDURE IF EXISTS DeleteLogs;

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteLogs`()
   MODIFIES SQL DATA
DELETE FROM logs;

CREATE VIEW sorted_users AS SELECT * FROM users ORDER BY users.type DESC;


COMMIT;
