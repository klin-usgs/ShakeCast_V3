-- 
-- Table structure for table `log_message`
-- 

DROP TABLE IF EXISTS log_message;
CREATE TABLE `log_message` (
  `LOG_MESSAGE_ID` int(11) NOT NULL auto_increment,
  `LOG_MESSAGE_TYPE` varchar(10) NOT NULL,
  `SERVER_ID` int(11) NOT NULL,
  `DESCRIPTION` varchar(255) default NULL,
  `RECEIVE_TIMESTAMP` datetime default NULL,
  `DELIVERY_STATUS` varchar(10) default NULL,
  PRIMARY KEY  (`LOG_MESSAGE_ID`),
  KEY `SERVER_ID` (`SERVER_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- 
-- Dumping data for table `log_message_type`
-- 

INSERT INTO `log_message_type` (`LOG_MESSAGE_TYPE`, `NAME`, `DESCRIPTION`, `UPDATE_USERNAME`, `UPDATE_TIMESTAMP`) VALUES 
('ERROR', 'Error Message', NULL, 'kwl', '2008-05-01 15:15:00'),
('WARN', 'Warning Message', NULL, 'kwl', '2008-05-01 15:15:00');

-- 
-- Dumping data for table `notification_request_status`
-- 

INSERT INTO `notification_request_status` (`PARMNAME`, `PARMVALUE`) VALUES 
('LAST_SYSTEM_SEQ', '1');

-- 
-- Dumping data for table `notification_type`
-- 

INSERT INTO `notification_type` (`NOTIFICATION_TYPE`, `NOTIFICATION_CLASS`, `NAME`, `DESCRIPTION`, `NOTIFICATION_ATTEMPTS`, `UPDATE_USERNAME`, `UPDATE_TIMESTAMP`) VALUES 
('SYSTEM', 'SYSTEM', 'System Message', 'Abnormal system process result', 10, 'kwl', '2008-05-03 12:28:00');
