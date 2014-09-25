-- 
-- Update 'facility_shaking' table for extended value fields
-- 

ALTER TABLE `facility_shaking` ADD `value_7` double;
ALTER TABLE `facility_shaking` ADD `value_8` double;
ALTER TABLE `facility_shaking` ADD `value_9` double;
ALTER TABLE `facility_shaking` ADD `value_10` double;

-- 
-- Update 'metric' table for additional SDPGA and SVEL measures
-- 

ALTER TABLE `metric` MODIFY `METRIC_ID` int(11) NOT NULL;
INSERT INTO `metric` (`SHORT_NAME`, `METRIC_ID`, `NAME`, `UPDATE_USERNAME`, `UPDATE_TIMESTAMP`) VALUES 
	('SDPGA', '7', 'Standard Deviation of PGA', 'kwl', '2008-10-01 15:00:00'),
	('SVEL', '8', 'Estimated Vs30 in m/s', 'kwl', '2008-10-01 15:00:00');
UPDATE `metric` SET `METRIC_ID` = 0 WHERE `SHORT_NAME` = 'MMI';
UPDATE `metric` SET `METRIC_ID` = 1 WHERE `SHORT_NAME` = 'PGA';
UPDATE `metric` SET `METRIC_ID` = 2 WHERE `SHORT_NAME` = 'PGV';
UPDATE `metric` SET `METRIC_ID` = 3 WHERE `SHORT_NAME` = 'MMI';

--
-- Prepared for Metrics service
--
INSERT INTO `notification_request_status` (`PARMNAME`, `PARMVALUE`) VALUES
	('LAST_METRIC_SEQ', 0); 
	
INSERT INTO `metric` (`SHORT_NAME`, `METRIC_ID`, `NAME`, `DESCRIPTION`, `UPDATE_USERNAME`, `UPDATE_TIMESTAMP`) VALUES 
('ARIAS', 9, 'Arias Intensity in cm/s', NULL, 'kwl', '2011-05-18 08:00:00');
