-- 
-- Table structure for table `facility_process`
-- 

DROP TABLE IF EXISTS facility_process;
CREATE TABLE `facility_process` (
  `facility_id` int(11) NOT NULL,
  `process_name` varchar(32) NOT NULL,
  `process_value` varchar(32) DEFAULT NULL,
  KEY `facility_id` (`facility_id`,`process_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

