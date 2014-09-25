-- 
-- Table structure for table `facility`
-- 

CREATE TABLE `facility` (
  `FACILITY_ID` int(11) NOT NULL AUTO_INCREMENT,
  `FACILITY_TYPE` varchar(32) NOT NULL,
  `EXTERNAL_FACILITY_ID` varchar(32) DEFAULT NULL,
  `FACILITY_NAME` varchar(128) DEFAULT NULL,
  `SHORT_NAME` varchar(32) DEFAULT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `LAT_MIN` double NOT NULL,
  `LAT_MAX` double NOT NULL,
  `LON_MIN` double NOT NULL,
  `LON_MAX` double NOT NULL,
  `UPDATE_USERNAME` varchar(32) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`FACILITY_ID`),
  KEY `FACILITY_EXT_ID_IDX` (`FACILITY_TYPE`,`EXTERNAL_FACILITY_ID`),
  KEY `FACILITY_LAT_IDX` (`LAT_MIN`,`LAT_MAX`),
  KEY `FACILITY_SHORT_NAME_IDX` (`SHORT_NAME`),
  KEY `FACILITY_NAME` (`FACILITY_NAME`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=128199 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_attribute`
-- 

CREATE TABLE `facility_attribute` (
  `facility_id` int(11) NOT NULL,
  `attribute_name` varchar(20) NOT NULL,
  `attribute_value` varchar(30) DEFAULT NULL,
  KEY `facility_id` (`facility_id`,`attribute_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_feature`
-- 

CREATE TABLE `facility_feature` (
  `FACILITY_ID` int(11) NOT NULL,
  `GEOM_TYPE` varchar(32) DEFAULT NULL,
  `GEOM` mediumtext,
  `DESCRIPTION` mediumtext,
  `UPDATE_USERNAME` varchar(32) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`FACILITY_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_fragility`
-- 

CREATE TABLE `facility_fragility` (
  `FACILITY_FRAGILITY_ID` int(11) NOT NULL AUTO_INCREMENT,
  `FACILITY_ID` int(11) NOT NULL,
  `DAMAGE_LEVEL` varchar(10) NOT NULL,
  `LOW_LIMIT` double DEFAULT NULL,
  `HIGH_LIMIT` double DEFAULT NULL,
  `UPDATE_USERNAME` varchar(32) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `METRIC` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`FACILITY_FRAGILITY_ID`),
  KEY `facility_fragility_facility_ix` (`FACILITY_ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=752872 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_fragility_model`
-- 

CREATE TABLE `facility_fragility_model` (
  `FACILITY_FRAGILITY_MODEL_ID` int(11) NOT NULL AUTO_INCREMENT,
  `FACILITY_ID` int(11) NOT NULL,
  `CLASS` varchar(32) DEFAULT NULL,
  `COMPONENT` varchar(64) NOT NULL,
  `DAMAGE_LEVEL` varchar(10) NOT NULL,
  `ALPHA` double DEFAULT NULL,
  `BETA` double DEFAULT NULL,
  `UPDATE_USERNAME` varchar(32) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `METRIC` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`FACILITY_FRAGILITY_MODEL_ID`),
  KEY `facility_fragility_model_facility_ix` (`FACILITY_ID`),
  KEY `CLASS` (`CLASS`,`COMPONENT`,`FACILITY_ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1169874 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_fragility_probability`
-- 

CREATE TABLE `facility_fragility_probability` (
  `FACILITY_ID` int(11) NOT NULL,
  `grid_id` int(11) NOT NULL,
  `FACILITY_FRAGILITY_MODEL_ID` int(11) NOT NULL,
  `DAMAGE_LEVEL` varchar(10) NOT NULL,
  `PROBABILITY` double DEFAULT NULL,
  `METRIC` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`FACILITY_ID`,`grid_id`,`FACILITY_FRAGILITY_MODEL_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

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
  `SEQ` int(11) NOT NULL,
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_notification_request`
-- 

CREATE TABLE `facility_notification_request` (
  `FACILITY_ID` int(11) NOT NULL,
  `NOTIFICATION_REQUEST_ID` int(11) NOT NULL,
  PRIMARY KEY (`FACILITY_ID`,`NOTIFICATION_REQUEST_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_process`
-- 

CREATE TABLE `facility_process` (
  `facility_id` int(11) NOT NULL,
  `process_name` varchar(32) NOT NULL,
  `process_value` varchar(32) DEFAULT NULL,
  KEY `facility_id` (`facility_id`,`process_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_shaking`
-- 

CREATE TABLE `facility_shaking` (
  `facility_id` int(11) NOT NULL,
  `grid_id` int(11) NOT NULL,
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
  PRIMARY KEY (`facility_id`,`grid_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_type`
-- 

CREATE TABLE `facility_type` (
  `FACILITY_TYPE` varchar(32) NOT NULL,
  `NAME` varchar(32) NOT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `UPDATE_USERNAME` varchar(32) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`FACILITY_TYPE`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_type_attribute`
-- 

CREATE TABLE `facility_type_attribute` (
  `FACILITY_TYPE_ATTRIBUTE_ID` int(11) NOT NULL AUTO_INCREMENT,
  `FACILITY_TYPE` varchar(32) NOT NULL,
  `ATTRIBUTE_NAME` varchar(20) NOT NULL,
  `DESCRIPTION` varchar(30) DEFAULT NULL,
  `UPDATE_USERNAME` varchar(32) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`FACILITY_TYPE_ATTRIBUTE_ID`),
  KEY `FACILITY_TYPE` (`FACILITY_TYPE`,`ATTRIBUTE_NAME`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=78 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `facility_type_fragility`
-- 

CREATE TABLE `facility_type_fragility` (
  `FACILITY_TYPE_FRAGILITY_ID` int(11) NOT NULL AUTO_INCREMENT,
  `FACILITY_TYPE` varchar(32) NOT NULL,
  `DAMAGE_LEVEL` varchar(10) NOT NULL,
  `LOW_LIMIT` double DEFAULT NULL,
  `HIGH_LIMIT` double DEFAULT NULL,
  `UPDATE_USERNAME` varchar(32) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `METRIC` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`FACILITY_TYPE_FRAGILITY_ID`),
  KEY `facility_fragility_facility_ix` (`FACILITY_TYPE`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=592 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `geometry_facility_profile`
-- 

CREATE TABLE `geometry_facility_profile` (
  `FACILITY_ID` int(11) NOT NULL,
  `PROFILE_ID` int(11) NOT NULL,
  PRIMARY KEY (`FACILITY_ID`,`PROFILE_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- 
-- Table structure for table `notification`
-- 

CREATE TABLE `notification` (
  `NOTIFICATION_ID` int(11) NOT NULL AUTO_INCREMENT,
  `NOTIFICATION_REQUEST_ID` int(11) NOT NULL,
  `SHAKECAST_USER` int(11) NOT NULL,
  `QUEUE_TIMESTAMP` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `DELIVERY_TIMESTAMP` datetime DEFAULT NULL,
  `NEXT_DELIVERY_TIMESTAMP` datetime DEFAULT NULL,
  `TRIES` int(11) DEFAULT NULL,
  `DELIVERY_ATTEMPT_TIMESTAMP` datetime DEFAULT NULL,
  `FACILITY_ID` int(11) DEFAULT NULL,
  `DELIVERY_STATUS` varchar(10) NOT NULL,
  `GRID_ID` int(11) DEFAULT NULL,
  `GRID_VALUE_ID` int(11) DEFAULT NULL,
  `event_id` varchar(80) DEFAULT NULL,
  `EVENT_VERSION` int(11) DEFAULT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `DELIVERY_ADDRESS` text,
  `METRIC` varchar(10) DEFAULT NULL,
  `GRID_VALUE` double DEFAULT NULL,
  `DELIVERY_COMMENT` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`NOTIFICATION_ID`),
  KEY `NOTIFICATION_PRODUCT_ID_IDX` (`PRODUCT_ID`),
  KEY `NOTIFICATION_EVENT_ID_DX` (`event_id`),
  KEY `NOTIFICATION_QUEUE_TS_IDX` (`QUEUE_TIMESTAMP`),
  KEY `NOTIFICATION_DELIV_TS_IDX` (`DELIVERY_TIMESTAMP`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7902 ;

-- 
-- Table structure for table `station_facility`
-- 

CREATE TABLE `station_facility` (
  `FACILITY_ID` int(11) NOT NULL,
  `STATION_ID` int(11) NOT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `UPDATE_USERNAME` varchar(32) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`FACILITY_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

