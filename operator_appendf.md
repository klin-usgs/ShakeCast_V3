---
layout: page
title: Appendix A Template Keywords
permalink: /operator_appendf.html
---
# ShakeCast Notification Template Keywords

1. **Table 1.** EVENT Notification Keywords

| Constant | Description |
| --- | --- |
| EVENT\_ID | Earthquake identifier e.g., nn00423851 |
| EVENT\_VERSION | Integer indicating event version |
| EVENT\_STATUS | ShakeMap statusNORMAL:  RELEASEDREVIEWEDCANCELLED: |
| EVENT\_NAME | String name describing event; defined by local network |
| MAGNITUDE | Event magnitude |
| EVENT\_LOCATION\_DESCRIPTION | String name describing event location with geographic reference; defined by local networke.g., "32km WNW of Alamo, Nevada" |
| EVENT\_TIMESTAMP | Event timestamp
e.g., yyyy-mm-ddThh:mm:ssZ |
| LAT | Event latitude (decimal degrees, north) |
| LON | Event longitude (decimal degrees, east) |
| EXTERNAL\_EVENT\_ID | Same as EVENT\_ID in V3 |
| NOTIFICATION\_ID | Sequence ID in ShakeCast notification table |
| TRIES | Number of notification attempts. |
| DELIVERY\_STATUS | Result of notification attempt. |
| SHAKECAST\_USER | ShakeCast User ID |
| DELIVERY\_ADDRESS | Email address for delivery |
| DELIVERY\_METHOD | Product delivery type for the given notificationEMAIL\_HTML:  email with html formattingEMAIL\_TEXT:  plain text emailPAGER:  simple text message for SMS delivery |
| EVENT\_TYPE | Types of events that will trigger notifications to be sent:ALL: includes all event types (inclusive)ACTUAL:  real earthquakeSCENARIO:  a scenario or converted actual eventTEST:  system testHEARTBEAT:  a heartbeat system test message |
| NOTIFICATION\_TYPE | Types of events that will trigger a notification to be sent Valid notification types:NEW\_EVENT:  an earthquake exceeding a user-set threshold value. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.DAMAGE: Triggered when the ground shaking parameter at a facility (or facilities) is between the high and low values of the user-set facility parameters. Requires EVENT\_TYPE, DELIVERY\_METHOD, and DAMAGE\_LEVEL tags.SHAKING: Triggered when the ground shaking parameter at the facility location of the facility exceeds the preset value. Requires EVENT\_TYPE, DELIVERY\_METHOD, METRIC, and LIMIT\_VALUE tags.CAN\_EVENT:  cancelled event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.UPD\_EVENT: updated event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.NEW\_PROD:  triggered when a specific ShakeMap product becomes available. Require EVENT\_TYPE, DELIVERY\_METHOD, and PRODUCT tags. |
| MESSAGE\_FORMAT | Name of notification template (default) |
| LIMIT\_VALUE | Minimum magnitude for a notification to be sent |
| PRODUCT\_TYPE | Type of product to be delivered. If omitted, product is plain text.PDF:  PDF from templates |
| FILENAME | External files to be attached to message |
| AGGREGATION\_GROUP | Notification to be sent based on GROUP type defined by membership in a GROUP. ShakeCast has a predefined CITY group of global cities. |
| MAX\_TRIES | Maximum number of notification attempts. |
| FACILITY\_ID | Unique facility identifier. Text(32) |
| FACILITY\_TYPE | Type of facility. Current defined types are: BRIDGE, CAMPUS, CITY, COUNTY, DAM, DISTRICT, ENGINEERED, INDUSTRIAL, MULTIFAM, ROAD, SINGLEFAM, STRUCTURE, TANK, TUNNEL, UNKNOWN, and HAZUS building types. |
| EXTERNAL\_FACILITY\_ID | Organization's unique facility identifier. Text (32)This field must be unique for a facility type but the same external\_facility\_id may be used for different types of facilities. |
| FACILITY\_NAME | Facility name. Text(128). The value of this field is displayed to the user. |
| SHORT\_NAME | Shortened version of facility name. Text(128).ShakeCast uses the value in this field when a shorter version of the name is needed due to output space limitations. |
| DESCRIPTION | Facility description. Text(255). |
| FACILITY\_LAT | Facility latitude (decimal degrees, north) |
| FACILITY\_LON | Facility longitude (decimal degrees, east) |
| GEOM\_TYPE | The value of this field is used by ShakeCast to handle the geometry coordinates from the geom field. Text(32)Currently defined types are: POINT, POLYLINE, POLYGON, RECTANGLE, and CIRCLE. |
| GEOM | Geometry of a facility. The value of this field is used specify the coordinates of the facility. Text(32)Format of this field is in (longitude latitude) pairs separated by a white space. The size limit of data is ~16MB. |
| AGGREGATE | Flag to indicate whether notifications should be combined into a single messageInteger value e.g., 1 |
| SERVER\_ID | Identifier of this ShakeCast server |
| DNS\_ADDRESS | Domain name of this ShakeCast server |

1. **Table 2.** PRODUCT Notification Keywords

| Constant | Description |
| --- | --- |
|   | PRODUCT\_ID | Product sequence ID in ShakeCast database |
|   | PRODUCT\_TYPE | Type of product to be delivered. If omitted, product is plain text.PDF:  PDF from templates |
|   | NAME | Short product type description |
|   | DESCRIPTION | Long product type description |
|   | FILENAME | Filename for the product on local system |
|   | GENERATION\_TIMESTAMP | Timestamp showing when the product was created on remote or local server |
|   | PRODUCT\_STATUS | Status of product as RELEASED, REVIEWED, or CANCELLED |
|   | EVENT\_ID | Earthquake identifier e.g., nn00423851 |
|   | EVENT\_VERSION | Integer indicating event version |
|   | EVENT\_NAME | String name describing event; defined by local network |
|   | MAGNITUDE | Event magnitude |
|   | EVENT\_LOCATION\_DESCRIPTION | String name describing event location with geographic reference; defined by local networke.g., "32km WNW of Alamo, Nevada" |
|   | EVENT\_TIMESTAMP | Event timestamp
e.g., yyyy-mm-ddThh:mm:ssZ |
|   | LAT | Event latitude (decimal degrees, north) |
|   | LON | Event longitude (decimal degrees, east) |
|   | SHAKEMAP\_ID | Same as the event id |
|   | SHAKEMAP\_VERSION | Integer indicating map revision |
| NOTIFICATION\_ID | Sequence ID in ShakeCast notification table |
| TRIES | Number of notification attempts. |
| DELIVERY\_STATUS | Result of notification attempt. |
| SHAKECAST\_USER | ShakeCast User ID |
| DELIVERY\_ADDRESS | Email address for delivery |
|   | DELIVERY\_METHOD | Product delivery type for the given notificationEMAIL\_HTML:  email with html formattingEMAIL\_TEXT:  plain text emailPAGER:  simple text message for SMS delivery |
|   | NOTIFICATION\_TYPE | Types of events that will trigger a notification to be sent Valid notification types:NEW\_EVENT:  an earthquake exceeding a user-set threshold value. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.DAMAGE: Triggered when the ground shaking parameter at a facility (or facilities) is between the high and low values of the user-set facility parameters. Requires EVENT\_TYPE, DELIVERY\_METHOD, and DAMAGE\_LEVEL tags.SHAKING: Triggered when the ground shaking parameter at the facility location of the facility exceeds the preset value. Requires EVENT\_TYPE, DELIVERY\_METHOD, METRIC, and LIMIT\_VALUE tags.CAN\_EVENT:  cancelled event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.UPD\_EVENT: updated event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.NEW\_PROD:  triggered when a specific ShakeMap product becomes available. Require EVENT\_TYPE, DELIVERY\_METHOD, and PRODUCT tags. |
|   | MESSAGE\_FORMAT | Name of notification template (default) |
|   | LIMIT\_VALUE | Minimum magnitude for a notification to be sent |
|   | AGGREGATION\_GROUP | Notification to be sent based on GROUP type defined by membership in a GROUP. ShakeCast has a predefined CITY group of global cities. |
| MAX\_TRIES | Maximum number of notification attempts. |
|   | FACILITY\_ID | Unique facility identifier. Text(32) |
|   | FACILITY\_TYPE | Type of facility. Current defined types are: BRIDGE, CAMPUS, CITY, COUNTY, DAM, DISTRICT, ENGINEERED, INDUSTRIAL, MULTIFAM, ROAD, SINGLEFAM, STRUCTURE, TANK, TUNNEL, UNKNOWN, and HAZUS building types. |
|   | EXTERNAL\_FACILITY\_ID | Organization's unique facility identifier. Text (32)This field must be unique for a facility type but the same external\_facility\_id may be used for different types of facilities. |
|   | FACILITY\_NAME | Facility name. Text(128). The value of this field is displayed to the user. |
|   | SHORT\_NAME | Shortened version of facility name. Text(128).ShakeCast uses the value in this field when a shorter version of the name is needed due to output space limitations. |
|   | DESCRIPTION | Facility description. Text(255). |
|   | FACILITY\_LAT | Facility latitude (decimal degrees, north) |
|   | FACILITY\_LON | Facility longitude (decimal degrees, east) |
|   | GEOM\_TYPE | The value of this field is used by ShakeCast to handle the geometry coordinates from the geom field. Text(32)Currently defined types are: POINT, POLYLINE, POLYGON, RECTANGLE, and CIRCLE. |
|   | GEOM | Geometry of a facility. The value of this field is used specify the coordinates of the facility. Text(32)Format of this field is in (longitude latitude) pairs separated by a white space. The size limit of data is ~16MB. |
|   | AGGREGATE | Flag to indicate whether notifications should be combined into a single messageInteger value e.g., 1 |
|   | SERVER\_ID | Identifier of this ShakeCast server |
|   | DNS\_ADDRESS | Domain name of this ShakeCast server |



1. **Table 3.** SHAKING Notification Keywords

| Constant | Description |
| --- | --- |
|   | SHAKEMAP\_ID | Same as the event id |
|   | SHAKEMAP\_VERSION | Integer indicating map revision |
|   | SHAKEMAP\_REGION | ShakeMap Network Code |
|   | GENERATION\_TIMESTAMP | ShakeCast processing timestamp
e.g., yyyy-mm-ddThh:mm:ssZ |
|   | EVENT\_ID | Earthquake identifier e.g., nn00423851 |
|   | EVENT\_VERSION | Integer indicating event version Integer indicating event version |
|   | EVENT\_NAME | String name describing event; defined by local network |
|   | MAGNITUDE | Event magnitude |
|   | EVENT\_LOCATION\_DESCRIPTION | String name describing event location with geographic reference; defined by local networke.g., "32km WNW of Alamo, Nevada" |
|   | EVENT\_TIMESTAMP | Event timestamp
e.g., yyyy-mm-ddThh:mm:ssZ |
|   | LAT | Event latitude (decimal degrees, north) |
|   | LON | Event longitude (decimal degrees, east) |
| NOTIFICATION\_ID | Sequence ID in ShakeCast notification table |
| TRIES | Number of notification attempts. |
| DELIVERY\_STATUS | Result of notification attempt. |
| DELIVERY\_ADDRESS | Email address for delivery |
|   | METRIC | ShakeMap metric for the shaking value |
|   | GRID\_VALUE | ShakeMap shaking value |
|   | DELIVERY\_METHOD | Product delivery type for the given notificationEMAIL\_HTML:  email with html formattingEMAIL\_TEXT:  plain text emailPAGER:  simple text message for SMS delivery |
|   | NOTIFICATION\_TYPE | Types of events that will trigger a notification to be sent Valid notification types:NEW\_EVENT:  an earthquake exceeding a user-set threshold value. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.DAMAGE: Triggered when the ground shaking parameter at a facility (or facilities) is between the high and low values of the user-set facility parameters. Requires EVENT\_TYPE, DELIVERY\_METHOD, and DAMAGE\_LEVEL tags.SHAKING: Triggered when the ground shaking parameter at the facility location of the facility exceeds the preset value. Requires EVENT\_TYPE, DELIVERY\_METHOD, METRIC, and LIMIT\_VALUE tags.CAN\_EVENT:  cancelled event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.UPD\_EVENT: updated event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.NEW\_PROD:  triggered when a specific ShakeMap product becomes available. Require EVENT\_TYPE, DELIVERY\_METHOD, and PRODUCT tags. |
|   | MESSAGE\_FORMAT | Name of notification template (default) |
|   | LIMIT\_VALUE | Minimum magnitude for a notification to be sent |
|   | PRODUCT\_TYPE | Type of product to be delivered by the specified DELIVERY\_METHOD. Products includePDF: GRID\_XMLPGA\_JPGINTEN\_JPG |
|   | FILENAME | External file to be attached to message |
|   | AGGREGATION\_GROUP | Notification to be sent based on GROUP type defined by membership in a GROUP. ShakeCast has a predefined CITY group of global cities. |
|   | MAX\_TRIES | Maximum number of notification attempts. |
|   | FACILITY\_ID | Unique facility identifier. Text(32) |
|   | FACILITY\_TYPE | Type of facility. Current defined types are: BRIDGE, CAMPUS, CITY, COUNTY, DAM, DISTRICT, ENGINEERED, INDUSTRIAL, MULTIFAM, ROAD, SINGLEFAM, STRUCTURE, TANK, TUNNEL, UNKNOWN, and HAZUS building types. |
|   | EXTERNAL\_FACILITY\_ID | Organization's unique facility identifier. Text (32)This field must be unique for a facility type but the same external\_facility\_id may be used for different types of facilities. |
|   | FACILITY\_NAME | Facility name. Text(128). The value of this field is displayed to the user. |
|   | SHORT\_NAME | Shortened version of facility name. Text(128).ShakeCast uses the value in this field when a shorter version of the name is needed due to output space limitations. |
|   | DESCRIPTION | Facility description. Text(255). |
|   | FACILITY\_LAT | Facility latitude (decimal degrees, north) |
|   | FACILITY\_LON | Facility longitude (decimal degrees, east) |
|   | GEOM\_TYPE | The value of this field is used by ShakeCast to handle the geometry coordinates from the geom field. Text(32)Currently defined types are: POINT, POLYLINE, POLYGON, RECTANGLE, and CIRCLE. |
|   | GEOM | Geometry of a facility. The value of this field is used specify the coordinates of the facility. Text(32)Format of this field is in (longitude latitude) pairs separated by a white space. The size limit of data is ~16MB. |
|   | BOUND\_SOUTH | ShakeMap boundary to south |
|   | BOUND\_NORTH | ShakeMap boundary to north |
|   | BOUND\_WEST | ShakeMap boundary to west |
|   | BOUND\_EAST | ShakeMap boundary to east |
|   | AGGREGATE | Flag to indicate whether notifications should be combined into a single messageInteger value e.g., 1 |
|   | SERVER\_ID | Identifier of this ShakeCast server |
|   | DNS\_ADDRESS | Domain name of this ShakeCast server |

1. **Table 4.** DAMAGE Notification Keywords

| Constant | Description |
| --- | --- |
|   | SHAKEMAP\_ID | Same as the event id |
|   | SHAKEMAP\_VERSION | Integer indicating map revision |
|   | SHAKEMAP\_REGION | ShakeMap network code |
|   | GENERATION\_TIMESTAMP | ShakeCast processing timestamp
e.g., yyyy-mm-ddThh:mm:ssZ |
|   | EVENT\_ID | Earthquake identifier e.g., nn00423851 |
|   | EVENT\_VERSION | Integer indicating event version |
|   | EVENT\_NAME | String name describing event; defined by local network |
|   | MAGNITUDE | Event magnitude |
|   | EVENT\_LOCATION\_DESCRIPTION | String name describing event location with geographic reference; defined by local networke.g., "32km WNW of Alamo, Nevada" |
|   | EVENT\_TIMESTAMP | Event timestamp
e.g., yyyy-mm-ddThh:mm:ssZ |
|   | LAT | Event latitude (decimal degrees, north) |
|   | LON | Event longitude (decimal degrees, north) |
| NOTIFICATION\_ID | Sequence ID in ShakeCast notification table |
| TRIES | Number of notification attempts. |
| DELIVERY\_STATUS | Result of notification attempt. |
| SHAKECAST\_USER | ShakeCast User ID |
| DELIVERY\_ADDRESS | Email address for delivery |
|   | METRIC | ShakeMap metric used for damage assessment |
|   | GRID\_VALUE | ShakeMap value used for damage assessment |
|   | DAMAGE\_LEVEL | String parameter for notification to be sent within the damage threshold e.g., GREEN, ORANGE, YELLOW, RED |
|   | DAMAGE\_LEVEL\_NAME | Damage level description |
|   | IS\_MAX\_SEVERITY | Flag showing whether this is the most severe damage state |
|   | SEVERITY\_RANK | Rank of damage state |
|   | LOW\_LIMIT | Minimum shaking value of the damage state |
|   | HIGH\_LIMIT | Maximum shaking value of the damage state |
|   | DELIVERY\_METHOD | Product delivery type for the given notificationEMAIL\_HTML:  email with html formattingEMAIL\_TEXT:  plain text emailPAGER:  simple text message for SMS delivery |
|   | NOTIFICATION\_TYPE | Types of events that will trigger a notification to be sent Valid notification types:NEW\_EVENT:  an earthquake exceeding a user-set threshold value. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.DAMAGE: Triggered when the ground shaking parameter at a facility (or facilities) is between the high and low values of the user-set facility parameters. Requires EVENT\_TYPE, DELIVERY\_METHOD, and DAMAGE\_LEVEL tags.SHAKING: Triggered when the ground shaking parameter at the facility location of the facility exceeds the preset value. Requires EVENT\_TYPE, DELIVERY\_METHOD, METRIC, and LIMIT\_VALUE tags.CAN\_EVENT:  cancelled event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.UPD\_EVENT: updated event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.NEW\_PROD:  triggered when a specific ShakeMap product becomes available. Require EVENT\_TYPE, DELIVERY\_METHOD, and PRODUCT tags. |
|   | MESSAGE\_FORMAT | Name of notification template (default) |
|   | LIMIT\_VALUE | Minimum magnitude for a notification to be sent |
|   | PRODUCT\_TYPE | Type of product to be delivered. If omitted, product is plain text.PDF:  PDF from templates |
|   | FILENAME | External file to be attached to message |
|   | AGGREGATION\_GROUP | Notification to be sent based on GROUP type defined by membership in a GROUP. ShakeCast has a predefined CITY group of global cities. |
|   | MAX\_TRIES | Maximum number of notification attempts. |
|   | FACILITY\_ID | Unique facility identifier. Text(32) |
|   | FACILITY\_TYPE | Type of facility. Current defined types are: BRIDGE, CAMPUS, CITY, COUNTY, DAM, DISTRICT, ENGINEERED, INDUSTRIAL, MULTIFAM, ROAD, SINGLEFAM, STRUCTURE, TANK, TUNNEL, UNKNOWN, and HAZUS building types. |
|   | EXTERNAL\_FACILITY\_ID | Organization's unique facility identifier. Text (32)This field must be unique for a facility type but the same external\_facility\_id may be used for different types of facilities. |
|   | FACILITY\_NAME | Facility name. Text(128). The value of this field is displayed to the user. |
|   | SHORT\_NAME | Shortened version of facility name. Text(128).ShakeCast uses the value in this field when a shorter version of the name is needed due to output space limitations. |
|   | DESCRIPTION | Facility description. Text(255). |
|   | FACILITY\_LAT | Facility latitude (decimal degrees, north) |
|   | FACILITY\_LON | Facility longitude (decimal degrees, east) |
|   | GEOM\_TYPE | The value of this field is used by ShakeCast to handle the geometry coordinates from the geom field. Text(32)Currently defined types are: POINT, POLYLINE, POLYGON, RECTANGLE, and CIRCLE. |
|   | GEOM | Geometry of a facility. The value of this field is used specify the coordinates of the facility. Text(32)Format of this field is in (longitude latitude) pairs separated by a white space. The size limit of data is ~16MB. |
|   | BOUND\_SOUTH | ShakeMap boundary to south |
|   | BOUND\_NORTH | ShakeMap boundary to north |
|   | BOUND\_WEST | ShakeMap boundary to west |
|   | BOUND\_EAST | ShakeMap boundary to east |
|   | AGGREGATE | Flag to indicate whether notifications should be combined into a single messageInteger value e.g., 1 |
|   | SERVER\_ID | Identifier of this ShakeCast server |
|   | DNS\_ADDRESS | Domain name of this ShakeCast server |

1. **Table 5.** SYSTEM Notification Keywords

| Constant | Description |
| --- | --- |
|   | LOG\_MESSAGE\_ID | Log sequence ID in ShakeCast database |
|   | LOG\_MESSAGE\_TYPE | Message type in WARNING or ERROR |
|   | SERVER\_ID | Local ID for this ShakeCast server |
|   | DESCRIPTION | Server description |
|   | RECEIVE\_TIMESTAMP | Timestamp when this notification was requested
e.g., yyyy-mm-ddThh:mm:ssZ |
| NOTIFICATION\_ID | Sequence ID in ShakeCast notification table |
| TRIES | Number of notification attempts. |
| DELIVERY\_STATUS | Result of notification attempt. |
| SHAKECAST\_USER | ShakeCast User ID |
| DELIVERY\_ADDRESS | Email address for delivery |
|   | DELIVERY\_METHOD | Product delivery type for the given notificationEMAIL\_HTML:  email with html formattingEMAIL\_TEXT:  plain text emailPAGER:  simple text message for SMS delivery |
|   | NOTIFICATION\_TYPE | Types of events that will trigger a notification to be sent Valid notification types:NEW\_EVENT:  an earthquake exceeding a user-set threshold value. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.DAMAGE: Triggered when the ground shaking parameter at a facility (or facilities) is between the high and low values of the user-set facility parameters. Requires EVENT\_TYPE, DELIVERY\_METHOD, and DAMAGE\_LEVEL tags.SHAKING: Triggered when the ground shaking parameter at the facility location of the facility exceeds the preset value. Requires EVENT\_TYPE, DELIVERY\_METHOD, METRIC, and LIMIT\_VALUE tags.CAN\_EVENT:  cancelled event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.UPD\_EVENT: updated event. Requires EVENT\_TYPE and DELIVERY\_METHOD tags.NEW\_PROD:  triggered when a specific ShakeMap product becomes available. Require EVENT\_TYPE, DELIVERY\_METHOD, and PRODUCT tags. |
|   | MESSAGE\_FORMAT | Filename of notification template (default) |
|   | LIMIT\_VALUE | Minimum magnitude for a notification to be sent |
|   | AGGREGATE | Flag to indicate whether notifications should be combined into a single messageInteger value e.g., 1 |
|   | AGGREGATION\_GROUP | Notification to be sent based on GROUP type defined by membership in a GROUP. ShakeCast has a predefined CITY group of global cities. |
|   | MAX\_TRIES | Maximum number of notification attempts. |
|   | SERVER\_ID | Identifier of this ShakeCast server |
|   | DNS\_ADDRESS | Domain name of this ShakeCast server |

1. **Table 6.** Derived Value Keywords

| Facility Attributes As ATTR\_[ATTRIBUTE\_NAME] | Description |
| --- | --- |
|   | \_ITEMNO | Total number of entries in this notification |
|   | \_NUM\_[METRIC] (SHAKING/DAMAGE only) | Total number of entries for the specified ShakeMap metric |
|   | \_MIN\_[METRIC] (SHAKING/DAMAGE only) | The minimum reported value for the specified ShakeMap metric |
|   | \_MAX\_[METRIC] (SHAKING/DAMAGE only) | The maximum reported value for the specified ShakeMap metric |
|   | \_MEAN\_[METRIC] (SHAKING/DAMAGE only) | The averaged value for the specified ShakeMap metric |
|   | EXCEEDANCE\_RATIO (DAMAGE only) | The relative position between the LOW\_LIMIT and HIGH\_LIMIT values, normalized to between 0 and 1. |
