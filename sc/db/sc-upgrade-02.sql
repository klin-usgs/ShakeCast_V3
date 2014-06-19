--
-- 2011-05-09: Update database from version 20040625-01
--

alter table `event` add (
  `EVENT_REGION` varchar(4) DEFAULT NULL,
  `EVENT_SOURCE_TYPE` varchar(4) DEFAULT NULL,
  `MAGNITUDE` double DEFAULT NULL);

-- 
-- Table structure for table `facility_model`
-- 

CREATE TABLE `facility_model` (
  `FACILITY_MODEL_ID` int(11) NOT NULL AUTO_INCREMENT,
  `FACILITY_ID` int(11) NOT NULL,
  `GMPE` varchar(32) NOT NULL,
  `UPDATE_USERNAME` varchar(32) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `METRIC` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`FACILITY_MODEL_ID`),
  KEY `facility_model_facility_ix` (`FACILITY_ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=785 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_model_shaking`
-- 

CREATE TABLE `facility_model_shaking` (
  `facility_id` int(11) NOT NULL,
  `SEQ` int(11) NOT NULL AUTO_INCREMENT,
  `dist` double DEFAULT NULL,
  `value_1` double DEFAULT NULL,
  `value_2` double DEFAULT NULL,
  `value_3` double DEFAULT NULL,
  `value_4` double DEFAULT NULL,
  `value_5` double DEFAULT NULL,
  `value_6` double DEFAULT NULL,
  `value_7` double DEFAULT NULL,
  `value_8` double DEFAULT NULL,
  `value_9` double DEFAULT NULL,
  `value_10` double DEFAULT NULL,
  PRIMARY KEY (`facility_id`,`SEQ`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------



--
-- END
--
