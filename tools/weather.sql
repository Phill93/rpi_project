CREATE DATABASE  IF NOT EXISTS `weather` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `weather`;
-- MySQL dump 10.13  Distrib 5.5.49, for debian-linux-gnu (x86_64)
--
-- Host: 127.0.0.1    Database: weather
-- ------------------------------------------------------
-- Server version	5.5.49-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `archive_hours`
--

DROP TABLE IF EXISTS `archive_hours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_hours` (
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tempAverage` float NOT NULL DEFAULT '0',
  `humAverage` float NOT NULL DEFAULT '0',
  `fromTo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `archive_days`
--

DROP TABLE IF EXISTS `archive_days`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_days` (
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tempAverage` float NOT NULL DEFAULT '0',
  `humAverage` float NOT NULL DEFAULT '0',
  `fromTo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `archive_months`
--

DROP TABLE IF EXISTS `archive_months`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_months` (
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tempAverage` float NOT NULL DEFAULT '0',
  `humAverage` float NOT NULL DEFAULT '0',
  `fromTo` varchar(100) DEFAULT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sensors`
--

DROP TABLE IF EXISTS `sensors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sensors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

insert into sensors (name, description) values("Sensor 1","Default Sensor");

--
-- Table structure for table `hums`
--

DROP TABLE IF EXISTS `hums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hums` (
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `humidity` float NOT NULL DEFAULT '0',
  `id` int(11) DEFAULT '1',
  KEY `id` (`id`),
  FOREIGN KEY (`id`) REFERENCES `sensors` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `temps`
--

DROP TABLE IF EXISTS `temps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temps` (
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `temperature` float NOT NULL DEFAULT '0',
  `id` int(11) NOT NULL DEFAULT '1',
  KEY `id` (`id`),
  FOREIGN KEY (`id`) REFERENCES `sensors` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'weather'
--
/*!50003 DROP PROCEDURE IF EXISTS `archiveWeather` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `archiveWeather`( in period varchar(20) )
BEGIN
	case period
	when 'hours' then
		if ( ( select count(*) from temps ) != 0 ) and ( ( select count(*) from hums ) != 0 ) then
			insert into archive_hours(tempAverage, humAverage, fromTo)
			values(
				( select avg(temperature) from temps where tstamp < current_timestamp() ),
				( select avg(humidity) from hums where tstamp < current_timestamp() ),
				concat(
					(select min(tstamp) from temps where tstamp < current_timestamp()),
					" - ",
					(select max(tstamp) from temps where tstamp < current_timestamp())
				)
			);
			delete from temps where tstamp < current_timestamp();
			delete from hums where tstamp < current_timestamp();
		end if;
	when 'days' then
		if ( ( select count(*) from archive_hours ) != 0 ) then
			insert into archive_days(tempAverage, humAverage, fromTo)
			values(
				( select avg(tempAverage) from archive_hours where tstamp < current_timestamp() ),
				( select avg(humAverage) from archive_hours where tstamp < current_timestamp() ),
				concat(
					(select min(tstamp) from archive_hours where tstamp < current_timestamp()),
					" - ",
					(select max(tstamp) from archive_hours where tstamp < current_timestamp())
				)
			);
			delete from archive_hours where tstamp < current_timestamp();
		end if;
	when 'months' then
		if ( ( select count(*) from archive_days ) != 0 ) then
			insert into archive_months(tempAverage, humAverage, fromTo)
			values(
				( select avg(tempAverage) from archive_days where tstamp < current_timestamp() ),
				( select avg(humAverage) from archive_days where tstamp < current_timestamp() ),
				concat(
					(select min(tstamp) from archive_days where tstamp < current_timestamp()),
					" - ",
					(select max(tstamp) from archive_days where tstamp < current_timestamp())
				)
			);
		end if;
	when 'years' then
		if ( ( select count(*) from archive_months ) != 0 ) then
			insert into archive_years(tempAverage, humAverage, fromTo)
			values(
				( select avg(tempAverage) from archive_months where tstamp < current_timestamp() ),
				( select avg(humAverage) from archive_months where tstamp < current_timestamp() ),
				concat(
					(select min(tstamp) from archive_months where tstamp < current_timestamp()),
					" - ",
					(select max(tstamp) from archive_months where tstamp < current_timestamp())
				)
			);
		end if;
	end case;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fillWeather` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fillWeather`()
BEGIN
	insert into temps(temperature) values( RAND()*(70-1)+1 );
	-- insert into hums(humidity, id) values( RAND()*(70-1)+1, FLOOR(RAND()*(4-1)+1) );
	insert into hums(humidity) values( RAND()*(70-1)+1 );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

--
-- Dumping events for database 'weather'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;

/*!50106 DROP EVENT IF EXISTS `archiveMonthlyWeather` */;
-- DELIMITER ;;
-- /*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
-- /*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
-- /*!50003 SET @saved_col_connection = @@collation_connection */ ;;
-- /*!50003 SET character_set_client  = utf8 */ ;;
-- /*!50003 SET character_set_results = utf8 */ ;;
-- /*!50003 SET collation_connection  = utf8_general_ci */ ;;
-- /*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
-- /*!50003 SET sql_mode              = '' */ ;;
-- /*!50003 SET @saved_time_zone      = @@time_zone */ ;;
-- /*!50003 SET time_zone             = 'SYSTEM' */ ;;
-- /*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `archiveMonthlyWeather` ON SCHEDULE EVERY 1 MONTH STARTS date_format(current_timestamp + interval 1 month, '%Y-%m-01 00:00:05') ON COMPLETION PRESERVE ENABLE DO call archiveWeather( 'months' ) */ ;;
-- /*!50003 SET time_zone             = @saved_time_zone */ ;;
-- /*!50003 SET sql_mode              = @saved_sql_mode */ ;;
-- /*!50003 SET character_set_client  = @saved_cs_client */ ;;
-- /*!50003 SET character_set_results = @saved_cs_results */ ;;
-- /*!50003 SET collation_connection  = @saved_col_connection */ ;;
-- DELIMITER ;
/*!50106 DROP EVENT IF EXISTS `archiveDailyWeather` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `archiveDailyWeather` ON SCHEDULE EVERY 1 DAY STARTS date_format(current_timestamp + interval 1 day, '%Y-%m-%d 00:00:10') ON COMPLETION PRESERVE ENABLE DO call archiveWeather( 'days' ) */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `archiveHourlyWeather` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `archiveHourlyWeather` ON SCHEDULE EVERY 1 HOUR STARTS date_format(current_timestamp + interval 1 hour, '%Y-%m-%d %H:00:15') ON COMPLETION PRESERVE ENABLE DO call archiveWeather( 'hours' ) */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `insertData` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `insertData` ON SCHEDULE EVERY 20 SECOND STARTS date_format(current_timestamp + interval 1 minute, '%Y-%m-%d %H:%i:00') ON COMPLETION PRESERVE ENABLE DO call fillWeather() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

set global event_scheduler = on;
-- Create web user and grant privileges

drop user 'web'@'localhost';

create user web@localhost identified by 'web';
grant all privileges on weather.* to web@localhost;

-- Dump completed on 2016-06-21 20:19:48
