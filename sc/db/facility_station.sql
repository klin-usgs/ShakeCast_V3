--
-- Table structure for table `seismic_station`
--

CREATE TABLE station (
  STATION_ID int(11) NOT NULL auto_increment,
  STATION_NETWORK varchar(10) NOT NULL default '',
  EXTERNAL_STATION_ID varchar(32) default NULL,
  STATION_NAME varchar(128) default NULL,
  SOURCE varchar(255) default NULL,
  COMMTYPE varchar(32) default NULL,
  LATITUDE double NOT NULL default '0',
  LONGITUDE double NOT NULL default '0',
  UPDATE_USERNAME varchar(10) default NULL,
  UPDATE_TIMESTAMP datetime default NULL,
  PRIMARY KEY  (STATION_ID),
  UNIQUE KEY STATION_EXT_ID_IDX (STATION_NETWORK,EXTERNAL_STATION_ID),
  KEY LATITUDE (LATITUDE),
  KEY STATION_NAME (STATION_NAME)
) TYPE=MyISAM;

--
-- Table structure for table `facility_station`
--

CREATE TABLE station_facility (
  FACILITY_ID int(11) NOT NULL default '0',
  STATION_ID int(11) NOT NULL default '0',
  DESCRIPTION varchar(255) default NULL,
  UPDATE_USERNAME varchar(10) default NULL,
  UPDATE_TIMESTAMP datetime default NULL,
  PRIMARY KEY  (FACILITY_ID)
) TYPE=MyISAM;

--
-- Table structure for table `station_shaking`
--

CREATE TABLE station_shaking (
  STATION_ID int(11) NOT NULL default '0',
  GRID_ID int(11) NOT NULL default '0',
  RECORD_ID int(11) NOT NULL auto_increment,
  value_1 double default NULL,
  value_2 double default NULL,
  value_3 double default NULL,
  value_4 double default NULL,
  value_5 double default NULL,
  value_6 double default NULL,
  PRIMARY KEY  (RECORD_ID)
) TYPE=MyISAM;
