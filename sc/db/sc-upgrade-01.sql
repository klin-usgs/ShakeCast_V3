--
-- 2004-08-24: Update database from version 20040625-01
--

alter table damage_level add (severity_rank int default 0,
	is_max_severity tinyint default 0);

truncate table message_format;

alter table message_format change message_format message_format
	int auto_increment primary key;

alter table message_format change format_string file_name varchar(255);

alter table message_format add constraint unique (name);

insert into message_format (
        name, description, file_name,
        update_username, update_timestamp)
    values (
        'Event CSV', 'CSV of Events', 'eventcsv.txt',
        'scadmin', '2004-08-14 16:11:52');

update damage_level set severity_rank=100 where damage_level='GREEN';
update damage_level set severity_rank=200 where damage_level='YELLOW';
update damage_level set severity_rank=300 where damage_level='RED';

update damage_level set is_max_severity=1 where damage_level='RED';

alter table event_type         add primary key (event_type);

insert into event_type (
        event_type, name, description, 
        update_username, update_timestamp)
    values (
        'HEARTBEAT', 'Heartbeat', 'Network heartbeat event',
        'scadmin', '2004-08-25 17:00:00');

--
-- Create some missing PKs
--
alter table administrator_role add primary key (administrator_role);
alter table damage_level       add primary key (damage_level);
alter table delivery_status    add primary key (delivery_status);
alter table delivery_method    add primary key (delivery_method);
alter table event_status       add primary key (event_status);
alter table facility_type      add primary key (facility_type);
alter table log_message_type   add primary key (log_message_type);
alter table notification_class add primary key (notification_class);
alter table notification_request_status
                               add primary key (parmname);
alter table notification_type  add primary key (notification_type);
alter table product_format     add primary key (product_format);
alter table product_status     add primary key (product_status);
alter table product_type       add primary key (product_type);
alter table server             add primary key (server_id);
alter table server_status      add primary key (server_status);
alter table shakemap_region    add primary key (shakemap_region);
alter table shakemap_status    add primary key (shakemap_status);
alter table user_type          add primary key (user_type);

--
-- Drop obsolete tables
--
drop table exchange_action;
drop table exchange_log;
drop table exchange_type;

--
-- END
--
