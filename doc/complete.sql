CREATE DATABASE `rpi_project` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE 'rpi_project';
CREATE TABLE `archive_days` (
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tempAverage` float NOT NULL DEFAULT '0',
  `humAverage` float NOT NULL DEFAULT '0',
  `fromTo` varchar(100) DEFAULT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=latin1;
CREATE TABLE `archive_hours` (
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tempAverage` float NOT NULL DEFAULT '0',
  `humAverage` float NOT NULL DEFAULT '0',
  `fromTo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
CREATE TABLE `sensors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
CREATE TABLE `hums` (
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `humidity` float NOT NULL DEFAULT '0',
  `id` int(11) DEFAULT '1',
  KEY `id` (`id`),
  CONSTRAINT `hums_ibfk_1` FOREIGN KEY (`id`) REFERENCES `sensors` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
CREATE TABLE `temps` (
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `temperature` float NOT NULL DEFAULT '0',
  `id` int(11) DEFAULT '1',
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `archive`( in currentTime timestamp, in period varchar(20) )
BEGIN
	case period
	when 'hours' then
		if ( ( select count(*) from temps ) != 0 ) and ( ( select count(*) from hums ) != 0 ) then
			insert into archive_hours(tempAverage, humAverage, fromTo)
			values(
				( select avg(temperature) from temps where hour(tstamp) = hour(currentTime)-1 ),
				( select avg(humidity) from hums where hour(tstamp) = hour(currentTime)-1 ),
				concat(
					(select min(tstamp) from temps where hour(tstamp) = hour(current_timestamp)-1),
					" - ",
					(select max(tstamp) from temps where hour(tstamp) = hour(current_timestamp)-1)
				)
			);
			delete from temps where hour(tstamp) = hour(currentTime)-1;
			delete from hums where hour(tstamp) = hour(currentTime)-1;
		#else select concat("Eine Tabelle besitzt keine Enträge!");
		end if;
	when 'days' then
		if ( ( select count(*) from archive_hours ) != 0 ) then
			insert into archive_days(tempAverage, humAverage, fromTo)
			values(
				( select avg(tempAverage) from archive_hours where day(tstamp) = day(currentTime)-1 ),
				( select avg(humAverage) from archive_hours where day(tstamp) = day(currentTime)-1 ),
				concat(
					(select min(tstamp) from archive_hours where day(tstamp) = day(current_timestamp)-1),
					" - ",
					(select max(tstamp) from archive_hours where day(tstamp) = day(current_timestamp)-1)
				)
			);
		end if;
	when 'months' then
		if ( ( select count(*) from archive_days ) != 0 ) then
			insert into archive_months(tempAverage, humAverage, fromTo)
			values(
				( select avg(tempAverage) from archive_days where month(tstamp) = month(currentTime)-1 ),
				( select avg(humAverage) from archive_days where month(tstamp) = month(currentTime)-1 ),
				concat(
					(select min(tstamp) from archive_days where month(tstamp) = month(current_timestamp)-1),
					" - ",
					(select max(tstamp) from archive_days where month(tstamp) = month(current_timestamp)-1)
				)
			);
		end if;
	when 'years' then
		if ( ( select count(*) from archive_months ) != 0 ) then
			insert into archive_years(tempAverage, humAverage, fromTo)
			values(
				( select avg(tempAverage) from archive_months where year(tstamp) = year(currentTime)-1 ),
				( select avg(humAverage) from archive_months where year(tstamp) = year(currentTime)-1 ),
				concat(
					(select min(tstamp) from archive_months where year(tstamp) = year(current_timestamp)-1),
					" - ",
					(select max(tstamp) from archive_months where year(tstamp) = year(current_timestamp)-1)
				)
			);
		end if;
	end case;
END$$
DELIMITER ;
set global event_scheduler = on;
create event archiveHourly on schedule every 1 hour starts date_format( current_timestamp + interval 1 hour, "%Y-%m-%d %H:00:05" ) do call archive( 'hours' );
create event archiveDaily on schedule every 1 day starts date_format( current_timestamp + interval 1 day, "%Y-%m-%d 00:00:10" ) do call archive( 'days' );
