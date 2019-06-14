-- ----------------------------
-- 1、Trigger 作为 Blob 类型存储(用于 Quartz 用户用 JDBC 创建他们自己定制的 Trigger 类型，JobStore 并不知道如何存储实例的时候)
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_blob_triggers]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_blob_triggers]
GO

CREATE TABLE [dbo].[qrtz_blob_triggers] (
  [sched_name]             nvarchar(120)            NOT NULL,
  [trigger_name]           nvarchar(200)            NOT NULL,
  [trigger_group]          nvarchar(200)            NOT NULL,
  [blob_data]              varbinary(max)               NULL
)
GO

-- ----------------------------
-- 2、以 Blob 类型存储存放日历信息， quartz可配置一个日历来指定一个时间范围
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_calendars]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_calendars]
GO

CREATE TABLE [dbo].[qrtz_calendars] (
  [sched_name]             nvarchar(120)            NOT NULL,
  [calendar_name]          nvarchar(200)            NOT NULL,
  [calendar]               varbinary(max)           NOT NULL
)
GO

-- ----------------------------
-- 3、存储 Cron Trigger，包括 Cron 表达式和时区信息
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_cron_triggers]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_cron_triggers]
GO

CREATE TABLE [dbo].[qrtz_cron_triggers] (
  [sched_name]             nvarchar(120)                              NOT NULL,
  [trigger_name]           nvarchar(200)                              NOT NULL,
  [trigger_group]          nvarchar(200)                              NOT NULL,
  [cron_expression]        nvarchar(200)                              NOT NULL,
  [time_zone_id]           nvarchar(80)         DEFAULT NULL          NULL
)
GO

-- ----------------------------
-- 初始化-qrtz_cron_triggers表数据
-- ----------------------------
INSERT INTO [dbo].[qrtz_cron_triggers]  VALUES (N'RuoyiScheduler', N'__TASK_CLASS_NAME__1', N'DEFAULT', N'0/10 * * * * ?', N'Asia/Shanghai')
GO

INSERT INTO [dbo].[qrtz_cron_triggers]  VALUES (N'RuoyiScheduler', N'__TASK_CLASS_NAME__2', N'DEFAULT', N'0/20 * * * * ?', N'Asia/Shanghai')
GO


-- ----------------------------
-- 4、存储与已触发的 Trigger 相关的状态信息，以及相联 Job 的执行信息
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_fired_triggers]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_fired_triggers]
GO

CREATE TABLE [dbo].[qrtz_fired_triggers] (
  [sched_name]             nvarchar(120)                           NOT NULL,
  [entry_id]               nvarchar(95)                            NOT NULL,
  [trigger_name]           nvarchar(200)                           NOT NULL,
  [trigger_group]          nvarchar(200)                           NOT NULL,
  [instance_name]          nvarchar(200)                           NOT NULL,
  [fired_time]             bigint                                  NOT NULL,
  [sched_time]             bigint                                  NOT NULL,
  [priority]               int                                     NOT NULL,
  [state]                  nvarchar(16)                            NOT NULL,
  [job_name]               nvarchar(200)        DEFAULT NULL           NULL,
  [job_group]              nvarchar(200)        DEFAULT NULL           NULL,
  [is_nonconcurrent]       nvarchar(1)          DEFAULT NULL           NULL,
  [requests_recovery]      nvarchar(1)          DEFAULT NULL           NULL
)
GO

-- ----------------------------
-- 5、存储每一个已配置的 jobDetail 的详细信息
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_job_details]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_job_details]
GO

CREATE TABLE [dbo].[qrtz_job_details] (
  [sched_name]             nvarchar(120)                          NOT NULL,
  [job_name]               nvarchar(200)                          NOT NULL,
  [job_group]              nvarchar(200)                          NOT NULL,
  [description]            nvarchar(250)        DEFAULT NULL          NULL,
  [job_class_name]         nvarchar(250)                          NOT NULL,
  [is_durable]             nvarchar(1)                            NOT NULL,
  [is_nonconcurrent]       nvarchar(1)                            NOT NULL,
  [is_update_data]         nvarchar(1)                            NOT NULL,
  [requests_recovery]      nvarchar(1)                            NOT NULL,
  [job_data]               varbinary(max)                             NULL
)
GO

-- ----------------------------
-- 初始化-qrtz_job_details表数据
-- ----------------------------
INSERT INTO [dbo].[qrtz_job_details]  VALUES (N'RuoyiScheduler', N'__TASK_CLASS_NAME__1', N'DEFAULT', NULL, N'com.ruoyi.project.monitor.job.util.ScheduleJob', N'0', N'1', N'0', N'0', 0xACED0005737200156F72672E71756172747A2E4A6F62446174614D61709FB083E8BFA9B0CB020000787200266F72672E71756172747A2E7574696C732E537472696E674B65794469727479466C61674D61708208E8C3FBC55D280200015A0013616C6C6F77735472616E7369656E74446174617872001D6F72672E71756172747A2E7574696C732E4469727479466C61674D617013E62EAD28760ACE0200025A000564697274794C00036D617074000F4C6A6176612F7574696C2F4D61703B787001737200116A6176612E7574696C2E486173684D61700507DAC1C31660D103000246000A6C6F6164466163746F724900097468726573686F6C6478703F4000000000000C770800000010000000017400135F5F5441534B5F50524F504552544945535F5F73720028636F6D2E72756F79692E70726F6A6563742E6D6F6E69746F722E6A6F622E646F6D61696E2E4A6F6200000000000000010200084C000E63726F6E45787072657373696F6E7400124C6A6176612F6C616E672F537472696E673B4C00086A6F6247726F757071007E00094C00056A6F6249647400104C6A6176612F6C616E672F4C6F6E673B4C00076A6F624E616D6571007E00094C000A6D6574686F644E616D6571007E00094C000C6D6574686F64506172616D7371007E00094C000D6D697366697265506F6C69637971007E00094C000673746174757371007E000978720029636F6D2E72756F79692E6672616D65776F726B2E7765622E646F6D61696E2E42617365456E7469747900000000000000010200074C0008637265617465427971007E00094C000A63726561746554696D657400104C6A6176612F7574696C2F446174653B4C0006706172616D7371007E00034C000672656D61726B71007E00094C000B73656172636856616C756571007E00094C0008757064617465427971007E00094C000A75706461746554696D6571007E000C787074000561646D696E7372000E6A6176612E7574696C2E44617465686A81014B59741903000078707708000001622CDE29E0787074000070707074000E302F3130202A202A202A202A203F740018E7B3BBE7BB9FE9BB98E8AEA4EFBC88E697A0E58F82EFBC897372000E6A6176612E6C616E672E4C6F6E673B8BE490CC8F23DF0200014A000576616C7565787200106A6176612E6C616E672E4E756D62657286AC951D0B94E08B0200007870000000000000000174000672795461736B74000A72794E6F506172616D7374000074000133740001317800)
GO

INSERT INTO [dbo].[qrtz_job_details]  VALUES (N'RuoyiScheduler', N'__TASK_CLASS_NAME__2', N'DEFAULT', NULL, N'com.ruoyi.project.monitor.job.util.ScheduleJob', N'0', N'1', N'0', N'0', 0xACED0005737200156F72672E71756172747A2E4A6F62446174614D61709FB083E8BFA9B0CB020000787200266F72672E71756172747A2E7574696C732E537472696E674B65794469727479466C61674D61708208E8C3FBC55D280200015A0013616C6C6F77735472616E7369656E74446174617872001D6F72672E71756172747A2E7574696C732E4469727479466C61674D617013E62EAD28760ACE0200025A000564697274794C00036D617074000F4C6A6176612F7574696C2F4D61703B787001737200116A6176612E7574696C2E486173684D61700507DAC1C31660D103000246000A6C6F6164466163746F724900097468726573686F6C6478703F4000000000000C770800000010000000017400135F5F5441534B5F50524F504552544945535F5F73720028636F6D2E72756F79692E70726F6A6563742E6D6F6E69746F722E6A6F622E646F6D61696E2E4A6F6200000000000000010200084C000E63726F6E45787072657373696F6E7400124C6A6176612F6C616E672F537472696E673B4C00086A6F6247726F757071007E00094C00056A6F6249647400104C6A6176612F6C616E672F4C6F6E673B4C00076A6F624E616D6571007E00094C000A6D6574686F644E616D6571007E00094C000C6D6574686F64506172616D7371007E00094C000D6D697366697265506F6C69637971007E00094C000673746174757371007E000978720029636F6D2E72756F79692E6672616D65776F726B2E7765622E646F6D61696E2E42617365456E7469747900000000000000010200074C0008637265617465427971007E00094C000A63726561746554696D657400104C6A6176612F7574696C2F446174653B4C0006706172616D7371007E00034C000672656D61726B71007E00094C000B73656172636856616C756571007E00094C0008757064617465427971007E00094C000A75706461746554696D6571007E000C787074000561646D696E7372000E6A6176612E7574696C2E44617465686A81014B59741903000078707708000001622CDE29E0787074000070707074000E302F3230202A202A202A202A203F740018E7B3BBE7BB9FE9BB98E8AEA4EFBC88E69C89E58F82EFBC897372000E6A6176612E6C616E672E4C6F6E673B8BE490CC8F23DF0200014A000576616C7565787200106A6176612E6C616E672E4E756D62657286AC951D0B94E08B0200007870000000000000000274000672795461736B7400087279506172616D73740002727974000133740001317800)
GO


-- ----------------------------
-- 6、存储程序的悲观锁的信息(假如使用了悲观锁)
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_locks]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_locks]
GO

CREATE TABLE [dbo].[qrtz_locks] (
  [sched_name]             nvarchar(120)            NOT NULL,
  [lock_name]              nvarchar(40)             NOT NULL
)
GO

-- ----------------------------
-- 初始化-qrtz_locks表数据
-- ----------------------------
INSERT INTO [dbo].[qrtz_locks]  VALUES (N'RuoyiScheduler', N'STATE_ACCESS')
GO

INSERT INTO [dbo].[qrtz_locks]  VALUES (N'RuoyiScheduler', N'TRIGGER_ACCESS')
GO


-- ----------------------------
-- 7、存储已暂停的 Trigger 组的信息
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_paused_trigger_grps]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_paused_trigger_grps]
GO

CREATE TABLE [dbo].[qrtz_paused_trigger_grps] (
  [sched_name]             nvarchar(120)            NOT NULL,
  [trigger_group]          nvarchar(200)            NOT NULL
)
GO

-- ----------------------------
-- 8、存储少量的有关 Scheduler 的状态信息，假如是用于集群中，可以看到其他的 Scheduler 实例
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_scheduler_state]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_scheduler_state]
GO

CREATE TABLE [dbo].[qrtz_scheduler_state] (
  [sched_name]             nvarchar(120)            NOT NULL,
  [instance_name]          nvarchar(200)            NOT NULL,
  [last_checkin_time]      bigint                   NOT NULL,
  [checkin_interval]       bigint                   NOT NULL
)
GO

-- ----------------------------
-- 初始化-qrtz_scheduler_state表数据
-- ----------------------------
INSERT INTO [dbo].[qrtz_scheduler_state]  VALUES (N'RuoyiScheduler', N'DADI-20190220OQ1551669914890', N'1551670111964', N'15000')
GO


-- ----------------------------
-- 9、存储简单的 Trigger，包括重复次数，间隔，以及已触发的次数
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_simple_triggers]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_simple_triggers]
GO

CREATE TABLE [dbo].[qrtz_simple_triggers] (
  [sched_name]            nvarchar(120)             NOT NULL,
  [trigger_name]          nvarchar(200)             NOT NULL,
  [trigger_group]         nvarchar(200)             NOT NULL,
  [repeat_count]          bigint                    NOT NULL,
  [repeat_interval]       bigint                    NOT NULL,
  [times_triggered]       bigint                    NOT NULL
)
GO

-- ----------------------------
-- 10、Table structure for qrtz_simprop_triggers
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_simprop_triggers]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_simprop_triggers]
GO

CREATE TABLE [dbo].[qrtz_simprop_triggers] (
  [sched_name]           nvarchar(120)                                NOT NULL,
  [trigger_name]         nvarchar(200)                                NOT NULL,
  [trigger_group]        nvarchar(200)                                NOT NULL,
  [str_prop_1]           nvarchar(512)           DEFAULT NULL              NULL,
  [str_prop_2]           nvarchar(512)           DEFAULT NULL              NULL,
  [str_prop_3]           nvarchar(512)           DEFAULT NULL              NULL,
  [int_prop_1]           int                     DEFAULT NULL              NULL,
  [int_prop_2]           int                     DEFAULT NULL              NULL,
  [long_prop_1]          bigint                  DEFAULT NULL              NULL,
  [long_prop_2]          bigint                  DEFAULT NULL              NULL,
  [dec_prop_1]           decimal(13,4)           DEFAULT NULL              NULL,
  [dec_prop_2]           decimal(13,4)           DEFAULT NULL              NULL,
  [bool_prop_1]          nvarchar(1)             DEFAULT NULL              NULL,
  [bool_prop_2]          nvarchar(1)             DEFAULT NULL              NULL
)
GO

-- ----------------------------
-- 11、存储已配置的 Trigger 的信息
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[qrtz_triggers]') AND type IN ('U'))
	DROP TABLE [dbo].[qrtz_triggers]
GO

CREATE TABLE [dbo].[qrtz_triggers] (
  [sched_name]           nvarchar(120)                                        NOT NULL,
  [trigger_name]         nvarchar(200)                                        NOT NULL,
  [trigger_group]        nvarchar(200)                                        NOT NULL,
  [job_name]             nvarchar(200)                                        NOT NULL,
  [job_group]            nvarchar(200)                                        NOT NULL,
  [description]          nvarchar(250)          DEFAULT NULL                      NULL,
  [next_fire_time]       bigint                 DEFAULT NULL                      NULL,
  [prev_fire_time]       bigint                 DEFAULT NULL                      NULL,
  [priority]             int                    DEFAULT NULL                      NULL,
  [trigger_state]        nvarchar(16)                                         NOT NULL,
  [trigger_type]         nvarchar(8)                                          NOT NULL,
  [start_time]           bigint                                               NOT NULL,
  [end_time]             bigint                 DEFAULT NULL                      NULL,
  [calendar_name]        nvarchar(200)          DEFAULT NULL                      NULL,
  [misfire_instr]        smallint               DEFAULT NULL                      NULL,
  [job_data]             varbinary(max)                                           NULL
)
GO

-- ----------------------------
-- 初始化-qrtz_triggers表数据
-- ----------------------------
INSERT INTO [dbo].[qrtz_triggers]  VALUES (N'RuoyiScheduler', N'__TASK_CLASS_NAME__1', N'DEFAULT', N'__TASK_CLASS_NAME__1', N'DEFAULT', NULL, N'1551080480000', N'-1', N'5', N'PAUSED', N'CRON', N'1551080476000', N'0', NULL, N'2', 0xACED0005737200156F72672E71756172747A2E4A6F62446174614D61709FB083E8BFA9B0CB020000787200266F72672E71756172747A2E7574696C732E537472696E674B65794469727479466C61674D61708208E8C3FBC55D280200015A0013616C6C6F77735472616E7369656E74446174617872001D6F72672E71756172747A2E7574696C732E4469727479466C61674D617013E62EAD28760ACE0200025A000564697274794C00036D617074000F4C6A6176612F7574696C2F4D61703B787001737200116A6176612E7574696C2E486173684D61700507DAC1C31660D103000246000A6C6F6164466163746F724900097468726573686F6C6478703F4000000000000C770800000010000000017400135F5F5441534B5F50524F504552544945535F5F73720028636F6D2E72756F79692E70726F6A6563742E6D6F6E69746F722E6A6F622E646F6D61696E2E4A6F6200000000000000010200084C000E63726F6E45787072657373696F6E7400124C6A6176612F6C616E672F537472696E673B4C00086A6F6247726F757071007E00094C00056A6F6249647400104C6A6176612F6C616E672F4C6F6E673B4C00076A6F624E616D6571007E00094C000A6D6574686F644E616D6571007E00094C000C6D6574686F64506172616D7371007E00094C000D6D697366697265506F6C69637971007E00094C000673746174757371007E000978720029636F6D2E72756F79692E6672616D65776F726B2E7765622E646F6D61696E2E42617365456E7469747900000000000000010200074C0008637265617465427971007E00094C000A63726561746554696D657400104C6A6176612F7574696C2F446174653B4C0006706172616D7371007E00034C000672656D61726B71007E00094C000B73656172636856616C756571007E00094C0008757064617465427971007E00094C000A75706461746554696D6571007E000C787074000561646D696E7372000E6A6176612E7574696C2E44617465686A81014B59741903000078707708000001622CDE29E0787074000070707074000E302F3130202A202A202A202A203F740018E7B3BBE7BB9FE9BB98E8AEA4EFBC88E697A0E58F82EFBC897372000E6A6176612E6C616E672E4C6F6E673B8BE490CC8F23DF0200014A000576616C7565787200106A6176612E6C616E672E4E756D62657286AC951D0B94E08B0200007870000000000000000174000672795461736B74000A72794E6F506172616D7374000074000133740001317800)
GO

INSERT INTO [dbo].[qrtz_triggers]  VALUES (N'RuoyiScheduler', N'__TASK_CLASS_NAME__2', N'DEFAULT', N'__TASK_CLASS_NAME__2', N'DEFAULT', NULL, N'1551080480000', N'-1', N'5', N'PAUSED', N'CRON', N'1551080477000', N'0', NULL, N'2', 0xACED0005737200156F72672E71756172747A2E4A6F62446174614D61709FB083E8BFA9B0CB020000787200266F72672E71756172747A2E7574696C732E537472696E674B65794469727479466C61674D61708208E8C3FBC55D280200015A0013616C6C6F77735472616E7369656E74446174617872001D6F72672E71756172747A2E7574696C732E4469727479466C61674D617013E62EAD28760ACE0200025A000564697274794C00036D617074000F4C6A6176612F7574696C2F4D61703B787001737200116A6176612E7574696C2E486173684D61700507DAC1C31660D103000246000A6C6F6164466163746F724900097468726573686F6C6478703F4000000000000C770800000010000000017400135F5F5441534B5F50524F504552544945535F5F73720028636F6D2E72756F79692E70726F6A6563742E6D6F6E69746F722E6A6F622E646F6D61696E2E4A6F6200000000000000010200084C000E63726F6E45787072657373696F6E7400124C6A6176612F6C616E672F537472696E673B4C00086A6F6247726F757071007E00094C00056A6F6249647400104C6A6176612F6C616E672F4C6F6E673B4C00076A6F624E616D6571007E00094C000A6D6574686F644E616D6571007E00094C000C6D6574686F64506172616D7371007E00094C000D6D697366697265506F6C69637971007E00094C000673746174757371007E000978720029636F6D2E72756F79692E6672616D65776F726B2E7765622E646F6D61696E2E42617365456E7469747900000000000000010200074C0008637265617465427971007E00094C000A63726561746554696D657400104C6A6176612F7574696C2F446174653B4C0006706172616D7371007E00034C000672656D61726B71007E00094C000B73656172636856616C756571007E00094C0008757064617465427971007E00094C000A75706461746554696D6571007E000C787074000561646D696E7372000E6A6176612E7574696C2E44617465686A81014B59741903000078707708000001622CDE29E0787074000070707074000E302F3230202A202A202A202A203F740018E7B3BBE7BB9FE9BB98E8AEA4EFBC88E69C89E58F82EFBC897372000E6A6176612E6C616E672E4C6F6E673B8BE490CC8F23DF0200014A000576616C7565787200106A6176612E6C616E672E4E756D62657286AC951D0B94E08B0200007870000000000000000274000672795461736B7400087279506172616D73740002727974000133740001317800)
GO


-- ----------------------------
-- 12、参数配置表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_config]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_config]
GO

CREATE TABLE [dbo].[sys_config] (
  [config_id]           int  IDENTITY(3,1)                                          NOT NULL,
  [config_name]         nvarchar(100)            DEFAULT (N'')                          NULL,
  [config_key]          nvarchar(100)            DEFAULT (N'')                          NULL,
  [config_value]        nvarchar(100)            DEFAULT (N'')                          NULL,
  [config_type]         nchar(1)                 DEFAULT (N'N')                         NULL,
  [create_by]           nvarchar(64)             DEFAULT (N'')                          NULL,
  [create_time]         datetime2(7)             DEFAULT NULL                           NULL,
  [update_by]           nvarchar(64)             DEFAULT (N'')                          NULL,
  [update_time]         datetime2(7)             DEFAULT NULL                           NULL,
  [remark]              nvarchar(500)            DEFAULT NULL                           NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'参数主键',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'config_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'参数名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'config_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'参数键名',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'config_key'
GO

EXEC sp_addextendedproperty
'MS_Description', N'参数键值',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'config_value'
GO

EXEC sp_addextendedproperty
'MS_Description', N'系统内置（Y是 N否）',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'config_type'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'备注',
'SCHEMA', N'dbo',
'TABLE', N'sys_config',
'COLUMN', N'remark'
GO

EXEC sp_addextendedproperty
'MS_Description', N'参数配置表',
'SCHEMA', N'dbo',
'TABLE', N'sys_config'
GO

-- ----------------------------
-- 初始化-参数配置表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_config] ON
GO

INSERT INTO [dbo].[sys_config] ([config_id], [config_name], [config_key], [config_value], [config_type], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'1', N'主框架页-默认皮肤样式名称', N'sys.index.skinName', N'skin-blue', N'Y', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow')
GO

INSERT INTO [dbo].[sys_config] ([config_id], [config_name], [config_key], [config_value], [config_type], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'2', N'用户管理-账号初始密码', N'sys.user.initPassword', N'123456', N'Y', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'初始化密码 123456')
GO

SET IDENTITY_INSERT [dbo].[sys_config] OFF
GO


-- ----------------------------
-- 13、部门表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_dept]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_dept]
GO

CREATE TABLE [dbo].[sys_dept] (
  [dept_id]               int  IDENTITY(212,1)                              NOT NULL,
  [parent_id]             int                      DEFAULT ((0))                NULL,
  [ancestors]             nvarchar(50)             DEFAULT (N'')                NULL,
  [dept_name]             nvarchar(30)             DEFAULT (N'')                NULL,
  [order_num]             int                      DEFAULT ((0))                NULL,
  [leader]                nvarchar(20)             DEFAULT NULL                 NULL,
  [phone]                 nvarchar(11)             DEFAULT NULL                 NULL,
  [email]                 nvarchar(50)             DEFAULT NULL                 NULL,
  [status]                nchar(1)                 DEFAULT (N'0')               NULL,
  [del_flag]              nchar(1)                 DEFAULT (N'0')               NULL,
  [create_by]             nvarchar(64)             DEFAULT (N'')                NULL,
  [create_time]           datetime2(7)             DEFAULT NULL                 NULL,
  [update_by]             nvarchar(64)             DEFAULT (N'')                NULL,
  [update_time]           datetime2(7)             DEFAULT NULL                 NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'部门id',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'dept_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'父部门id',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'parent_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'祖级列表',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'ancestors'
GO

EXEC sp_addextendedproperty
'MS_Description', N'部门名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'dept_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'显示顺序',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'order_num'
GO

EXEC sp_addextendedproperty
'MS_Description', N'负责人',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'leader'
GO

EXEC sp_addextendedproperty
'MS_Description', N'联系电话',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'phone'
GO

EXEC sp_addextendedproperty
'MS_Description', N'邮箱',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'email'
GO

EXEC sp_addextendedproperty
'MS_Description', N'部门状态（0正常 1停用）',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'删除标志（0代表存在 2代表删除）',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'del_flag'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'部门表',
'SCHEMA', N'dbo',
'TABLE', N'sys_dept'
GO


-- ----------------------------
-- 初始化-部门表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_dept] ON
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'100', N'0', N'0', N'若依集团', N'0', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'admin', N'2019-03-04 11:18:02.2770000')
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'101', N'100', N'0,100', N'深圳总公司', N'1', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'admin', N'2019-03-04 11:01:37.7000000')
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'102', N'100', N'0,100', N'北京分公司', N'2', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'admin', N'2019-03-04 11:01:46.6430000')
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'103', N'101', N'0,100,101', N'研发部门', N'1', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000')
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'104', N'101', N'0,100,101', N'市场部门', N'2', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000')
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'105', N'101', N'0,100,101', N'测试部门', N'3', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000')
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'106', N'101', N'0,100,101', N'财务部门', N'4', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000')
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'107', N'101', N'0,100,101', N'运维部门', N'5', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000')
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'108', N'102', N'0,100,102', N'市场部门', N'1', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000')
GO

INSERT INTO [dbo].[sys_dept] ([dept_id], [parent_id], [ancestors], [dept_name], [order_num], [leader], [phone], [email], [status], [del_flag], [create_by], [create_time], [update_by], [update_time]) VALUES (N'109', N'102', N'0,100,102', N'财务部门', N'2', N'若依', N'15888888888', N'ry@qq.com', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000')
GO


SET IDENTITY_INSERT [dbo].[sys_dept] OFF
GO


-- ----------------------------
-- 14、字典数据表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_dict_data]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_dict_data]
GO

CREATE TABLE [dbo].[sys_dict_data] (
  [dict_code]             int  IDENTITY(108,1)                                 NOT NULL,
  [dict_sort]             int                           DEFAULT ((0))              NULL,
  [dict_label]            nvarchar(100)                 DEFAULT (N'')              NULL,
  [dict_value]            nvarchar(100)                 DEFAULT (N'')              NULL,
  [dict_type]             nvarchar(100)                 DEFAULT (N'')              NULL,
  [css_class]             nvarchar(100)                 DEFAULT NULL               NULL,
  [list_class]            nvarchar(100)                 DEFAULT NULL               NULL,
  [is_default]            nchar(1)                      DEFAULT (N'N')             NULL,
  [status]                nchar(1)                      DEFAULT (N'0')             NULL,
  [create_by]             nvarchar(64)                  DEFAULT (N'')              NULL,
  [create_time]           datetime2(7)                  DEFAULT NULL               NULL,
  [update_by]             nvarchar(64)                  DEFAULT (N'')              NULL,
  [update_time]           datetime2(7)                  DEFAULT NULL               NULL,
  [remark]                nvarchar(500)                 DEFAULT NULL               NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典编码',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'dict_code'
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典排序',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'dict_sort'
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典标签',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'dict_label'
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典键值',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'dict_value'
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典类型',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'dict_type'
GO

EXEC sp_addextendedproperty
'MS_Description', N'样式属性（其他样式扩展）',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'css_class'
GO

EXEC sp_addextendedproperty
'MS_Description', N'表格回显样式',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'list_class'
GO

EXEC sp_addextendedproperty
'MS_Description', N'是否默认（Y是 N否）',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'is_default'
GO

EXEC sp_addextendedproperty
'MS_Description', N'状态（0正常 1停用）',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'备注',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data',
'COLUMN', N'remark'
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典数据表',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_data'
GO


-- ----------------------------
-- 初始化-字典数据表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_dict_data] ON
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'1', N'1', N'男', N'0', N'sys_user_sex', N'', N'', N'Y', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'性别男')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'2', N'2', N'女', N'1', N'sys_user_sex', N'', N'', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'性别女')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'3', N'3', N'未知', N'2', N'sys_user_sex', N'', N'', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'性别未知')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'4', N'1', N'显示', N'0', N'sys_show_hide', N'', N'primary', N'Y', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'显示菜单')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'5', N'2', N'隐藏', N'1', N'sys_show_hide', N'', N'danger', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'隐藏菜单')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'6', N'1', N'正常', N'0', N'sys_normal_disable', N'', N'primary', N'Y', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'正常状态')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'7', N'2', N'停用', N'1', N'sys_normal_disable', N'', N'danger', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'停用状态')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'8', N'1', N'正常', N'0', N'sys_job_status', N'', N'primary', N'Y', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'正常状态')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'9', N'2', N'暂停', N'1', N'sys_job_status', N'', N'danger', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'停用状态')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'10', N'1', N'是', N'Y', N'sys_yes_no', N'', N'primary', N'Y', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'系统默认是')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'11', N'2', N'否', N'N', N'sys_yes_no', N'', N'danger', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'系统默认否')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'12', N'1', N'通知', N'1', N'sys_notice_type', N'', N'warning', N'Y', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'通知')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'13', N'2', N'公告', N'2', N'sys_notice_type', N'', N'success', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'公告')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'14', N'1', N'正常', N'0', N'sys_notice_status', N'', N'primary', N'Y', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'正常状态')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'15', N'2', N'关闭', N'1', N'sys_notice_status', N'', N'danger', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'关闭状态')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'16', N'1', N'新增', N'1', N'sys_oper_type', N'', N'info', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'新增操作')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'17', N'2', N'修改', N'2', N'sys_oper_type', N'', N'info', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'修改操作')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'18', N'3', N'删除', N'3', N'sys_oper_type', N'', N'danger', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'删除操作')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'19', N'4', N'授权', N'4', N'sys_oper_type', N'', N'primary', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'授权操作')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'20', N'5', N'导出', N'5', N'sys_oper_type', N'', N'warning', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'导出操作')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'21', N'6', N'导入', N'6', N'sys_oper_type', N'', N'warning', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'导入操作')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'22', N'7', N'强退', N'7', N'sys_oper_type', N'', N'danger', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'强退操作')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'23', N'8', N'生成代码', N'8', N'sys_oper_type', N'', N'warning', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'生成操作')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'24', N'8', N'清空数据', N'9', N'sys_oper_type', N'', N'danger', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'清空操作')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'25', N'1', N'成功', N'0', N'sys_common_status', N'', N'primary', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'正常状态')
GO

INSERT INTO [dbo].[sys_dict_data] ([dict_code], [dict_sort], [dict_label], [dict_value], [dict_type], [css_class], [list_class], [is_default], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'26', N'2', N'失败', N'1', N'sys_common_status', N'', N'danger', N'N', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'停用状态')
GO

SET IDENTITY_INSERT [dbo].[sys_dict_data] OFF
GO


-- ----------------------------
-- 15、字典类型表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_dict_type]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_dict_type]
GO

CREATE TABLE [dbo].[sys_dict_type] (
  [dict_id]               int  IDENTITY(102,1)                                        NOT NULL,
  [dict_name]             nvarchar(100)                       DEFAULT (N'')               NULL,
  [dict_type]             nvarchar(100)                       DEFAULT (N'')               NULL,
  [status]                nchar(1)                            DEFAULT (N'0')              NULL,
  [create_by]             nvarchar(64)                        DEFAULT (N'')               NULL,
  [create_time]           datetime2(7)                        DEFAULT NULL                NULL,
  [update_by]             nvarchar(64)                        DEFAULT (N'')               NULL,
  [update_time]           datetime2(7)                        DEFAULT NULL                NULL,
  [remark]                nvarchar(500)                       DEFAULT NULL                NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典主键',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type',
'COLUMN', N'dict_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type',
'COLUMN', N'dict_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典类型',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type',
'COLUMN', N'dict_type'
GO

EXEC sp_addextendedproperty
'MS_Description', N'状态（0正常 1停用）',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'备注',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type',
'COLUMN', N'remark'
GO

EXEC sp_addextendedproperty
'MS_Description', N'字典类型表',
'SCHEMA', N'dbo',
'TABLE', N'sys_dict_type'
GO

-- ----------------------------
-- 初始化-字典类型表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_dict_type] ON
GO

INSERT INTO [dbo].[sys_dict_type] ([dict_id], [dict_name], [dict_type], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'1', N'用户性别', N'sys_user_sex', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'用户性别列表')
GO

INSERT INTO [dbo].[sys_dict_type] ([dict_id], [dict_name], [dict_type], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'2', N'菜单状态', N'sys_show_hide', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'菜单状态列表')
GO

INSERT INTO [dbo].[sys_dict_type] ([dict_id], [dict_name], [dict_type], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'3', N'系统开关', N'sys_normal_disable', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'系统开关列表')
GO

INSERT INTO [dbo].[sys_dict_type] ([dict_id], [dict_name], [dict_type], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'4', N'任务状态', N'sys_job_status', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'任务状态列表')
GO

INSERT INTO [dbo].[sys_dict_type] ([dict_id], [dict_name], [dict_type], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'5', N'系统是否', N'sys_yes_no', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'系统是否列表')
GO

INSERT INTO [dbo].[sys_dict_type] ([dict_id], [dict_name], [dict_type], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'6', N'通知类型', N'sys_notice_type', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'通知类型列表')
GO

INSERT INTO [dbo].[sys_dict_type] ([dict_id], [dict_name], [dict_type], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'7', N'通知状态', N'sys_notice_status', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'通知状态列表')
GO

INSERT INTO [dbo].[sys_dict_type] ([dict_id], [dict_name], [dict_type], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'8', N'操作类型', N'sys_oper_type', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'操作类型列表')
GO

INSERT INTO [dbo].[sys_dict_type] ([dict_id], [dict_name], [dict_type], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'9', N'系统状态', N'sys_common_status', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'登录状态列表')
GO

SET IDENTITY_INSERT [dbo].[sys_dict_type] OFF
GO


-- ----------------------------
-- 16、定时任务调度表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_job]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_job]
GO

CREATE TABLE [dbo].[sys_job] (
  [job_id]                int  IDENTITY(3,1)                                        NOT NULL,
  [job_name]              nvarchar(64)                    DEFAULT (N'')             NOT NULL,
  [job_group]             nvarchar(64)                    DEFAULT (N'')             NOT NULL,
  [method_name]           nvarchar(500)                   DEFAULT (N'')                 NULL,
  [method_params]         nvarchar(50)                    DEFAULT NULL                  NULL,
  [cron_expression]       nvarchar(255)                   DEFAULT (N'')                 NULL,
  [misfire_policy]        nvarchar(20)                    DEFAULT (N'3')                NULL,
  [status]                nchar(1)                        DEFAULT (N'0')                NULL,
  [create_by]             nvarchar(64)                    DEFAULT (N'')                 NULL,
  [create_time]           datetime2(7)                    DEFAULT NULL                  NULL,
  [update_by]             nvarchar(64)                    DEFAULT (N'')                 NULL,
  [update_time]           datetime2(7)                    DEFAULT NULL                  NULL,
  [remark]                nvarchar(500)                   DEFAULT (N'')                 NULL,
  [concurrent]            nchar(1)                                                      NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'任务ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'job_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'任务名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'job_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'任务组名',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'job_group'
GO

EXEC sp_addextendedproperty
'MS_Description', N'任务方法',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'method_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'方法参数',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'method_params'
GO

EXEC sp_addextendedproperty
'MS_Description', N'cron执行表达式',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'cron_expression'
GO

EXEC sp_addextendedproperty
'MS_Description', N'计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'misfire_policy'
GO

EXEC sp_addextendedproperty
'MS_Description', N'状态（0正常 1暂停）',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'备注信息',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'remark'
GO

EXEC sp_addextendedproperty
'MS_Description', N'是否并发执行（0允许 1禁止）',
'SCHEMA', N'dbo',
'TABLE', N'sys_job',
'COLUMN', N'concurrent'
GO

EXEC sp_addextendedproperty
'MS_Description', N'定时任务调度表',
'SCHEMA', N'dbo',
'TABLE', N'sys_job'
GO

-- ----------------------------
-- 初始化-定时任务调度表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_job] ON
GO

INSERT INTO [dbo].[sys_job] ([job_id], [job_name], [job_group], [method_name], [method_params], [cron_expression], [misfire_policy], [status], [create_by], [create_time], [update_by], [update_time], [remark], [concurrent]) VALUES (N'1', N'ryTask', N'系统默认（无参）', N'ryNoParams', N'', N'0/10 * * * * ?', N'3', N'1', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'1')
GO

INSERT INTO [dbo].[sys_job] ([job_id], [job_name], [job_group], [method_name], [method_params], [cron_expression], [misfire_policy], [status], [create_by], [create_time], [update_by], [update_time], [remark], [concurrent]) VALUES (N'2', N'ryTask', N'系统默认（有参）', N'ryParams', N'ry', N'0/20 * * * * ?', N'3', N'1', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'1')
GO

SET IDENTITY_INSERT [dbo].[sys_job] OFF
GO


-- ----------------------------
-- 17、定时任务调度日志表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_job_log]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_job_log]
GO

CREATE TABLE [dbo].[sys_job_log] (
  [job_log_id]                    int  IDENTITY(1,1)                                       NOT NULL,
  [job_name]                      nvarchar(64)                                             NOT NULL,
  [job_group]                     nvarchar(64)                                             NOT NULL,
  [method_name]                   nvarchar(500)                     DEFAULT NULL               NULL,
  [method_params]                 nvarchar(50)                      DEFAULT NULL               NULL,
  [job_message]                   nvarchar(500)                     DEFAULT NULL               NULL,
  [status]                        nchar(1)                          DEFAULT (N'0')             NULL,
  [exception_info]                nvarchar(2000)                    DEFAULT (N'')              NULL,
  [create_time]                   datetime2(7)                      DEFAULT NULL               NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'任务日志ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log',
'COLUMN', N'job_log_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'任务名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log',
'COLUMN', N'job_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'任务组名',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log',
'COLUMN', N'job_group'
GO

EXEC sp_addextendedproperty
'MS_Description', N'任务方法',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log',
'COLUMN', N'method_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'方法参数',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log',
'COLUMN', N'method_params'
GO

EXEC sp_addextendedproperty
'MS_Description', N'日志信息',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log',
'COLUMN', N'job_message'
GO

EXEC sp_addextendedproperty
'MS_Description', N'执行状态（0正常 1失败）',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'异常信息',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log',
'COLUMN', N'exception_info'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'定时任务调度日志表',
'SCHEMA', N'dbo',
'TABLE', N'sys_job_log'
GO

-- ----------------------------
-- 18、系统访问记录
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_logininfor]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_logininfor]
GO

CREATE TABLE [dbo].[sys_logininfor] (
  [info_id]                     int  IDENTITY(203,1)                                       NOT NULL,
  [login_name]                  nvarchar(50)                        DEFAULT (N'')              NULL,
  [ipaddr]                      nvarchar(50)                        DEFAULT (N'')              NULL,
  [login_location]              nvarchar(255)                       DEFAULT (N'')              NULL,
  [browser]                     nvarchar(50)                        DEFAULT (N'')              NULL,
  [os]                          nvarchar(50)                        DEFAULT (N'')              NULL,
  [status]                      nchar(1)                            DEFAULT (N'0')             NULL,
  [msg]                         nvarchar(255)                       DEFAULT (N'')              NULL,
  [login_time]                  datetime2(7)                        DEFAULT NULL               NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'访问ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor',
'COLUMN', N'info_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'登录账号',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor',
'COLUMN', N'login_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'登录IP地址',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor',
'COLUMN', N'ipaddr'
GO

EXEC sp_addextendedproperty
'MS_Description', N'登录地点',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor',
'COLUMN', N'login_location'
GO

EXEC sp_addextendedproperty
'MS_Description', N'浏览器类型',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor',
'COLUMN', N'browser'
GO

EXEC sp_addextendedproperty
'MS_Description', N'操作系统',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor',
'COLUMN', N'os'
GO

EXEC sp_addextendedproperty
'MS_Description', N'登录状态（0成功 1失败）',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'提示消息',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor',
'COLUMN', N'msg'
GO

EXEC sp_addextendedproperty
'MS_Description', N'访问时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor',
'COLUMN', N'login_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'系统访问记录',
'SCHEMA', N'dbo',
'TABLE', N'sys_logininfor'
GO


-- ----------------------------
-- 19、菜单权限表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_menu]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_menu]
GO

CREATE TABLE [dbo].[sys_menu] (
  [menu_id]                     int  IDENTITY(2038,1)                                          NOT NULL,
  [menu_name]                   nvarchar(50)                                                   NOT NULL,
  [parent_id]                   int                               DEFAULT ((0))                    NULL,
  [order_num]                   int                               DEFAULT ((0))                    NULL,
  [url]                         nvarchar(200)                     DEFAULT (N'#')                   NULL,
  [menu_type]                   nchar(1)                          DEFAULT (N'')                    NULL,
  [visible]                     nchar(1)                          DEFAULT (N'0')                   NULL,
  [perms]                       nvarchar(100)                     DEFAULT NULL                     NULL,
  [icon]                        nvarchar(100)                     DEFAULT (N'#')                   NULL,
  [create_by]                   nvarchar(64)                      DEFAULT (N'')                    NULL,
  [create_time]                 datetime2(7)                      DEFAULT NULL                     NULL,
  [update_by]                   nvarchar(64)                      DEFAULT (N'')                    NULL,
  [update_time]                 datetime2(7)                      DEFAULT NULL                     NULL,
  [remark]                      nvarchar(500)                     DEFAULT (N'')                    NULL,
  [target]                      nvarchar(20)                      DEFAULT ''                       NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'菜单ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'menu_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'菜单名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'menu_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'父菜单ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'parent_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'显示顺序',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'order_num'
GO

EXEC sp_addextendedproperty
'MS_Description', N'请求地址',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'url'
GO

EXEC sp_addextendedproperty
'MS_Description', N'菜单类型（M目录 C菜单 F按钮）',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'menu_type'
GO

EXEC sp_addextendedproperty
'MS_Description', N'菜单状态（0显示 1隐藏）',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'visible'
GO

EXEC sp_addextendedproperty
'MS_Description', N'权限标识',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'perms'
GO

EXEC sp_addextendedproperty
'MS_Description', N'菜单图标',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'icon'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'备注',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'remark'
GO

EXEC sp_addextendedproperty
'MS_Description', N'打开方式（menuItem页签 menuBlank新窗口）',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu',
'COLUMN', N'target'
GO

EXEC sp_addextendedproperty
'MS_Description', N'菜单权限表',
'SCHEMA', N'dbo',
'TABLE', N'sys_menu'
GO


-- ----------------------------
-- 初始化-菜单权限表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_menu] ON
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1', N'系统管理', N'0', N'1', N'#', N'M', N'0', N'', N'fa fa-gear', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'系统管理目录', N'menuItem')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'2', N'系统监控', N'0', N'2', N'#', N'M', N'0', N'', N'fa fa-video-camera', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'系统监控目录', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'3', N'系统工具', N'0', N'3', N'#', N'M', N'0', N'', N'fa fa-bars', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'系统工具目录', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'100', N'用户管理', N'1', N'1', N'/system/user', N'C', N'0', N'system:user:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'用户管理菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'101', N'角色管理', N'1', N'2', N'/system/role', N'C', N'0', N'system:role:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'角色管理菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'102', N'菜单管理', N'1', N'3', N'/system/menu', N'C', N'0', N'system:menu:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'菜单管理菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'103', N'部门管理', N'1', N'4', N'/system/dept', N'C', N'0', N'system:dept:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'部门管理菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'104', N'岗位管理', N'1', N'5', N'/system/post', N'C', N'0', N'system:post:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'岗位管理菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'105', N'字典管理', N'1', N'6', N'/system/dict', N'C', N'0', N'system:dict:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'字典管理菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'106', N'参数设置', N'1', N'7', N'/system/config', N'C', N'0', N'system:config:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'参数设置菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'107', N'通知公告', N'1', N'8', N'/system/notice', N'C', N'0', N'system:notice:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'通知公告菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'108', N'日志管理', N'1', N'9', N'#', N'M', N'0', N'', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'日志管理菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'109', N'在线用户', N'2', N'1', N'/monitor/online', N'C', N'0', N'monitor:online:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'在线用户菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'110', N'定时任务', N'2', N'2', N'/monitor/job', N'C', N'0', N'monitor:job:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'定时任务菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'111', N'数据监控', N'2', N'3', N'/monitor/data', N'C', N'0', N'monitor:data:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'数据监控菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'112', N'服务监控', N'2', N'3', N'/monitor/server', N'C', N'0', N'monitor:server:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'服务监控菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'113', N'表单构建', N'3', N'1', N'/tool/build', N'C', N'0', N'tool:build:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'表单构建菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'114', N'代码生成', N'3', N'2', N'/tool/gen', N'C', N'0', N'tool:gen:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'代码生成菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'115', N'系统接口', N'3', N'3', N'/tool/swagger', N'C', N'0', N'tool:swagger:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'系统接口菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'500', N'操作日志', N'108', N'1', N'/monitor/operlog', N'C', N'0', N'monitor:operlog:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'操作日志菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'501', N'登录日志', N'108', N'2', N'/monitor/logininfor', N'C', N'0', N'monitor:logininfor:view', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'登录日志菜单', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1000', N'用户查询', N'100', N'1', N'#', N'F', N'0', N'system:user:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1001', N'用户新增', N'100', N'2', N'#', N'F', N'0', N'system:user:add', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1002', N'用户修改', N'100', N'3', N'#', N'F', N'0', N'system:user:edit', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1003', N'用户删除', N'100', N'4', N'#', N'F', N'0', N'system:user:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1004', N'用户导出', N'100', N'5', N'#', N'F', N'0', N'system:user:export', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1005', N'用户导入', N'100', N'6', N'#', N'F', N'0', N'system:user:import', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1006', N'重置密码', N'100', N'7', N'#', N'F', N'0', N'system:user:resetPwd', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1007', N'角色查询', N'101', N'1', N'#', N'F', N'0', N'system:role:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1008', N'角色新增', N'101', N'2', N'#', N'F', N'0', N'system:role:add', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1009', N'角色修改', N'101', N'3', N'#', N'F', N'0', N'system:role:edit', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1010', N'角色删除', N'101', N'4', N'#', N'F', N'0', N'system:role:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1011', N'角色导出', N'101', N'5', N'#', N'F', N'0', N'system:role:export', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1012', N'菜单查询', N'102', N'1', N'#', N'F', N'0', N'system:menu:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1013', N'菜单新增', N'102', N'2', N'#', N'F', N'0', N'system:menu:add', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1014', N'菜单修改', N'102', N'3', N'#', N'F', N'0', N'system:menu:edit', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1015', N'菜单删除', N'102', N'4', N'#', N'F', N'0', N'system:menu:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1016', N'部门查询', N'103', N'1', N'#', N'F', N'0', N'system:dept:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1017', N'部门新增', N'103', N'2', N'#', N'F', N'0', N'system:dept:add', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1018', N'部门修改', N'103', N'3', N'#', N'F', N'0', N'system:dept:edit', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1019', N'部门删除', N'103', N'4', N'#', N'F', N'0', N'system:dept:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1020', N'岗位查询', N'104', N'1', N'#', N'F', N'0', N'system:post:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1021', N'岗位新增', N'104', N'2', N'#', N'F', N'0', N'system:post:add', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1022', N'岗位修改', N'104', N'3', N'#', N'F', N'0', N'system:post:edit', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1023', N'岗位删除', N'104', N'4', N'#', N'F', N'0', N'system:post:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1024', N'岗位导出', N'104', N'5', N'#', N'F', N'0', N'system:post:export', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1025', N'字典查询', N'105', N'1', N'#', N'F', N'0', N'system:dict:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1026', N'字典新增', N'105', N'2', N'#', N'F', N'0', N'system:dict:add', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1027', N'字典修改', N'105', N'3', N'#', N'F', N'0', N'system:dict:edit', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1028', N'字典删除', N'105', N'4', N'#', N'F', N'0', N'system:dict:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1029', N'字典导出', N'105', N'5', N'#', N'F', N'0', N'system:dict:export', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1030', N'参数查询', N'106', N'1', N'#', N'F', N'0', N'system:config:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1031', N'参数新增', N'106', N'2', N'#', N'F', N'0', N'system:config:add', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1032', N'参数修改', N'106', N'3', N'#', N'F', N'0', N'system:config:edit', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1033', N'参数删除', N'106', N'4', N'#', N'F', N'0', N'system:config:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1034', N'参数导出', N'106', N'5', N'#', N'F', N'0', N'system:config:export', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1035', N'公告查询', N'107', N'1', N'#', N'F', N'0', N'system:notice:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1036', N'公告新增', N'107', N'2', N'#', N'F', N'0', N'system:notice:add', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1037', N'公告修改', N'107', N'3', N'#', N'F', N'0', N'system:notice:edit', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1038', N'公告删除', N'107', N'4', N'#', N'F', N'0', N'system:notice:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1039', N'操作查询', N'500', N'1', N'#', N'F', N'0', N'monitor:operlog:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1040', N'操作删除', N'500', N'2', N'#', N'F', N'0', N'monitor:operlog:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1041', N'详细信息', N'500', N'3', N'#', N'F', N'0', N'monitor:operlog:detail', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1042', N'日志导出', N'500', N'4', N'#', N'F', N'0', N'monitor:operlog:export', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1043', N'登录查询', N'501', N'1', N'#', N'F', N'0', N'monitor:logininfor:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1044', N'登录删除', N'501', N'2', N'#', N'F', N'0', N'monitor:logininfor:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1045', N'日志导出', N'501', N'3', N'#', N'F', N'0', N'monitor:logininfor:export', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1046', N'在线查询', N'109', N'1', N'#', N'F', N'0', N'monitor:online:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1047', N'批量强退', N'109', N'2', N'#', N'F', N'0', N'monitor:online:batchForceLogout', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1048', N'单条强退', N'109', N'3', N'#', N'F', N'0', N'monitor:online:forceLogout', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1049', N'任务查询', N'110', N'1', N'#', N'F', N'0', N'monitor:job:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1050', N'任务新增', N'110', N'2', N'#', N'F', N'0', N'monitor:job:add', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1051', N'任务修改', N'110', N'3', N'#', N'F', N'0', N'monitor:job:edit', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1052', N'任务删除', N'110', N'4', N'#', N'F', N'0', N'monitor:job:remove', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1053', N'状态修改', N'110', N'5', N'#', N'F', N'0', N'monitor:job:changeStatus', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1054', N'任务详细', N'110', N'6', N'#', N'F', N'0', N'monitor:job:detail', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1055', N'任务导出', N'110', N'7', N'#', N'F', N'0', N'monitor:job:export', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1056', N'生成查询', N'114', N'1', N'#', N'F', N'0', N'tool:gen:list', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

INSERT INTO [dbo].[sys_menu] ([menu_id], [menu_name], [parent_id], [order_num], [url], [menu_type], [visible], [perms], [icon], [create_by], [create_time], [update_by], [update_time], [remark], [target]) VALUES (N'1057', N'生成代码', N'114', N'2', N'#', N'F', N'0', N'tool:gen:code', N'#', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'', N'')
GO

SET IDENTITY_INSERT [dbo].[sys_menu] OFF
GO


-- ----------------------------
-- 20、通知公告表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_notice]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_notice]
GO

CREATE TABLE [dbo].[sys_notice] (
  [notice_id]                   int  IDENTITY(3,1)                                           NOT NULL,
  [notice_title]                nvarchar(50)                                                 NOT NULL,
  [notice_type]                 nchar(1)                                                     NOT NULL,
  [notice_content]              nvarchar(2000)                  DEFAULT NULL                     NULL,
  [status]                      nchar(1)                        DEFAULT (N'0')                   NULL,
  [create_by]                   nvarchar(64)                    DEFAULT (N'')                    NULL,
  [create_time]                 datetime2(7)                    DEFAULT NULL                     NULL,
  [update_by]                   nvarchar(64)                    DEFAULT (N'')                    NULL,
  [update_time]                 datetime2(7)                    DEFAULT NULL                     NULL,
  [remark]                      nvarchar(255)                   DEFAULT NULL                     NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'公告ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'notice_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'公告标题',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'notice_title'
GO

EXEC sp_addextendedproperty
'MS_Description', N'公告类型（1通知 2公告）',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'notice_type'
GO

EXEC sp_addextendedproperty
'MS_Description', N'公告内容',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'notice_content'
GO

EXEC sp_addextendedproperty
'MS_Description', N'公告状态（0正常 1关闭）',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'备注',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice',
'COLUMN', N'remark'
GO

EXEC sp_addextendedproperty
'MS_Description', N'通知公告表',
'SCHEMA', N'dbo',
'TABLE', N'sys_notice'
GO
-- ----------------------------
-- 初始化-公告信息表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_notice] ON
GO

INSERT INTO [dbo].[sys_notice] ([notice_id], [notice_title], [notice_type], [notice_content], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'1', N'温馨提醒：2018-07-01 若依新版本发布啦', N'2', N'新版本内容', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'管理员')
GO

INSERT INTO [dbo].[sys_notice] ([notice_id], [notice_title], [notice_type], [notice_content], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'2', N'维护通知：2018-07-01 若依系统凌晨维护', N'1', N'维护内容', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'管理员')
GO

SET IDENTITY_INSERT [dbo].[sys_notice] OFF
GO


-- ----------------------------
-- 21、操作日志记录
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_oper_log]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_oper_log]
GO

CREATE TABLE [dbo].[sys_oper_log] (
  [oper_id]                     int  IDENTITY(243,1)                                           NOT NULL,
  [title]                       nvarchar(50)                       DEFAULT (N'')                   NULL,
  [business_type]               int                                DEFAULT ((0))                   NULL,
  [method]                      nvarchar(100)                      DEFAULT (N'')                   NULL,
  [operator_type]               int                                DEFAULT ((0))                   NULL,
  [oper_name]                   nvarchar(50)                       DEFAULT (N'')                   NULL,
  [dept_name]                   nvarchar(50)                       DEFAULT (N'')                   NULL,
  [oper_url]                    nvarchar(255)                      DEFAULT (N'')                   NULL,
  [oper_ip]                     nvarchar(50)                       DEFAULT (N'')                   NULL,
  [oper_location]               nvarchar(255)                      DEFAULT (N'')                   NULL,
  [oper_param]                  nvarchar(2000)                     DEFAULT (N'')                   NULL,
  [status]                      int                                DEFAULT ((0))                   NULL,
  [error_msg]                   nvarchar(2000)                     DEFAULT (N'')                   NULL,
  [oper_time]                   datetime2(7)                       DEFAULT NULL                    NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'日志主键',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'oper_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'模块标题',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'title'
GO

EXEC sp_addextendedproperty
'MS_Description', N'业务类型（0其它 1新增 2修改 3删除）',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'business_type'
GO

EXEC sp_addextendedproperty
'MS_Description', N'方法名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'method'
GO

EXEC sp_addextendedproperty
'MS_Description', N'操作类别（0其它 1后台用户 2手机端用户）',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'operator_type'
GO

EXEC sp_addextendedproperty
'MS_Description', N'操作人员',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'oper_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'部门名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'dept_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'请求URL',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'oper_url'
GO

EXEC sp_addextendedproperty
'MS_Description', N'主机地址',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'oper_ip'
GO

EXEC sp_addextendedproperty
'MS_Description', N'操作地点',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'oper_location'
GO

EXEC sp_addextendedproperty
'MS_Description', N'请求参数',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'oper_param'
GO

EXEC sp_addextendedproperty
'MS_Description', N'操作状态（0正常 1异常）',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'错误消息',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'error_msg'
GO

EXEC sp_addextendedproperty
'MS_Description', N'操作时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log',
'COLUMN', N'oper_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'操作日志记录',
'SCHEMA', N'dbo',
'TABLE', N'sys_oper_log'
GO


-- ----------------------------
-- 22、岗位信息表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_post]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_post]
GO

CREATE TABLE [dbo].[sys_post] (
  [post_id]                 int  IDENTITY(5,1)                                               NOT NULL,
  [post_code]               nvarchar(64)                                                     NOT NULL,
  [post_name]               nvarchar(50)                                                     NOT NULL,
  [post_sort]               int                                                              NOT NULL,
  [status]                  nchar(1)                                                         NOT NULL,
  [create_by]               nvarchar(64)                         DEFAULT (N'')                   NULL,
  [create_time]             datetime2(7)                         DEFAULT NULL                    NULL,
  [update_by]               nvarchar(64)                         DEFAULT (N'')                   NULL,
  [update_time]             datetime2(7)                         DEFAULT NULL                    NULL,
  [remark]                  nvarchar(500)                        DEFAULT NULL                    NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'岗位ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'post_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'岗位编码',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'post_code'
GO

EXEC sp_addextendedproperty
'MS_Description', N'岗位名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'post_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'显示顺序',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'post_sort'
GO

EXEC sp_addextendedproperty
'MS_Description', N'状态（0正常 1停用）',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'备注',
'SCHEMA', N'dbo',
'TABLE', N'sys_post',
'COLUMN', N'remark'
GO

EXEC sp_addextendedproperty
'MS_Description', N'岗位信息表',
'SCHEMA', N'dbo',
'TABLE', N'sys_post'
GO

-- ----------------------------
-- 初始化-岗位信息表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_post] ON
GO

INSERT INTO [dbo].[sys_post] ([post_id], [post_code], [post_name], [post_sort], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'1', N'ceo', N'董事长', N'1', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'')
GO

INSERT INTO [dbo].[sys_post] ([post_id], [post_code], [post_name], [post_sort], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'2', N'se', N'项目经理', N'2', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'')
GO

INSERT INTO [dbo].[sys_post] ([post_id], [post_code], [post_name], [post_sort], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'3', N'hr', N'人力资源', N'3', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'')
GO

INSERT INTO [dbo].[sys_post] ([post_id], [post_code], [post_name], [post_sort], [status], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'4', N'user', N'普通员工', N'4', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'')
GO

SET IDENTITY_INSERT [dbo].[sys_post] OFF
GO


-- ----------------------------
-- 23、角色信息表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_role]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_role]
GO

CREATE TABLE [dbo].[sys_role] (
  [role_id]                       int  IDENTITY(101,1)                                       NOT NULL,
  [role_name]                     nvarchar(30)                                               NOT NULL,
  [role_key]                      nvarchar(100)                                              NOT NULL,
  [role_sort]                     int                                                        NOT NULL,
  [data_scope]                    nchar(1)                      DEFAULT (N'1')                   NULL,
  [status]                        nchar(1)                                                   NOT NULL,
  [del_flag]                      nchar(1)                      DEFAULT (N'0')                   NULL,
  [create_by]                     nvarchar(64)                  DEFAULT (N'')                    NULL,
  [create_time]                   datetime2(7)                  DEFAULT NULL                     NULL,
  [update_by]                     nvarchar(64)                  DEFAULT (N'')                    NULL,
  [update_time]                   datetime2(7)                  DEFAULT NULL                     NULL,
  [remark]                        nvarchar(500)                 DEFAULT NULL                     NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'role_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'role_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色权限字符串',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'role_key'
GO

EXEC sp_addextendedproperty
'MS_Description', N'显示顺序',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'role_sort'
GO

EXEC sp_addextendedproperty
'MS_Description', N'数据范围（1：全部数据权限 2：自定数据权限）',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'data_scope'
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色状态（0正常 1停用）',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'删除标志（0代表存在 2代表删除）',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'del_flag'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'备注',
'SCHEMA', N'dbo',
'TABLE', N'sys_role',
'COLUMN', N'remark'
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色信息表',
'SCHEMA', N'dbo',
'TABLE', N'sys_role'
GO

-- ----------------------------
-- 初始化-角色信息表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_role] ON
GO

INSERT INTO [dbo].[sys_role] ([role_id], [role_name], [role_key], [role_sort], [data_scope], [status], [del_flag], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'1', N'管理员', N'admin', N'1', N'1', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'管理员')
GO

INSERT INTO [dbo].[sys_role] ([role_id], [role_name], [role_key], [role_sort], [data_scope], [status], [del_flag], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'2', N'普通角色', N'common', N'2', N'2', N'0', N'0', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2018-03-16 11:33:00.0000000', N'普通角色')
GO

SET IDENTITY_INSERT [dbo].[sys_role] OFF
GO


-- ----------------------------
-- 24、角色和部门关联表  角色1-N部门
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_role_dept]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_role_dept]
GO

CREATE TABLE [dbo].[sys_role_dept] (
  [role_id]             int             NOT NULL,
  [dept_id]             int             NOT NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_role_dept',
'COLUMN', N'role_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'部门ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_role_dept',
'COLUMN', N'dept_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色和部门关联表',
'SCHEMA', N'dbo',
'TABLE', N'sys_role_dept'
GO


-- ----------------------------
-- 初始化-角色和部门关联表数据
-- ----------------------------
INSERT INTO [dbo].[sys_role_dept]  VALUES (N'2', N'100')
GO

INSERT INTO [dbo].[sys_role_dept]  VALUES (N'2', N'101')
GO

INSERT INTO [dbo].[sys_role_dept]  VALUES (N'2', N'105')
GO


-- ----------------------------
-- 25、角色和菜单关联表  角色1-N菜单
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_role_menu]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_role_menu]
GO

CREATE TABLE [dbo].[sys_role_menu] (
  [role_id]             int             NOT NULL,
  [menu_id]             int             NOT NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_role_menu',
'COLUMN', N'role_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'菜单ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_role_menu',
'COLUMN', N'menu_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色和菜单关联表',
'SCHEMA', N'dbo',
'TABLE', N'sys_role_menu'
GO


-- ----------------------------
-- 初始化-角色和菜单关联表数据
-- ----------------------------
INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'2')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'3')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'100')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'101')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'102')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'103')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'104')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'105')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'106')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'107')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'108')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'109')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'110')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'111')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'112')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'113')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'114')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'115')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'500')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'501')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1000')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1001')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1002')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1003')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1004')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1005')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1006')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1007')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1008')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1009')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1010')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1011')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1012')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1013')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1014')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1015')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1016')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1017')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1018')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1019')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1020')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1021')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1022')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1023')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1024')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1025')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1026')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1027')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1028')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1029')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1030')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1031')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1032')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1033')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1034')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1035')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1036')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1037')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1038')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1039')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1040')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1041')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1042')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1043')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1044')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1045')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1046')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1047')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1048')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1049')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1050')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1051')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1052')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1053')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1054')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1055')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1056')
GO

INSERT INTO [dbo].[sys_role_menu]  VALUES (N'2', N'1057')
GO


-- ----------------------------
-- 26、用户信息表
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_user]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_user]
GO

CREATE TABLE [dbo].[sys_user] (
  [user_id]                     int  IDENTITY(101,1)                                         NOT NULL,
  [dept_id]                     int                            DEFAULT NULL                      NULL,
  [login_name]                  nvarchar(30)                                                 NOT NULL,
  [user_name]                   nvarchar(30)                                                 NOT NULL,
  [user_type]                   nvarchar(2)                    DEFAULT (N'00')                   NULL,
  [email]                       nvarchar(50)                   DEFAULT (N'')                     NULL,
  [phonenumber]                 nvarchar(11)                   DEFAULT (N'')                     NULL,
  [sex]                         nchar(1)                       DEFAULT (N'0')                    NULL,
  [avatar]                      nvarchar(100)                  DEFAULT (N'')                     NULL,
  [password]                    nvarchar(50)                   DEFAULT (N'')                     NULL,
  [salt]                        nvarchar(20)                   DEFAULT (N'')                     NULL,
  [status]                      nchar(1)                       DEFAULT (N'0')                    NULL,
  [del_flag]                    nchar(1)                       DEFAULT (N'0')                    NULL,
  [login_ip]                    nvarchar(50)                   DEFAULT (N'')                     NULL,
  [login_date]                  datetime2(7)                   DEFAULT NULL                      NULL,
  [create_by]                   nvarchar(64)                   DEFAULT (N'')                     NULL,
  [create_time]                 datetime2(7)                   DEFAULT NULL                      NULL,
  [update_by]                   nvarchar(64)                   DEFAULT (N'')                     NULL,
  [update_time]                 datetime2(7)                   DEFAULT NULL                      NULL,
  [remark]                      nvarchar(500)                  DEFAULT (N'')                     NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'user_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'部门ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'dept_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'登录账号',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'login_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户昵称',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'user_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户类型（00系统用户）',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'user_type'
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户邮箱',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'email'
GO

EXEC sp_addextendedproperty
'MS_Description', N'手机号码',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'phonenumber'
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户性别（0男 1女 2未知）',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'sex'
GO

EXEC sp_addextendedproperty
'MS_Description', N'头像路径',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'avatar'
GO

EXEC sp_addextendedproperty
'MS_Description', N'密码',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'password'
GO

EXEC sp_addextendedproperty
'MS_Description', N'盐加密',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'salt'
GO

EXEC sp_addextendedproperty
'MS_Description', N'帐号状态（0正常 1停用）',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'删除标志（0代表存在 2代表删除）',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'del_flag'
GO

EXEC sp_addextendedproperty
'MS_Description', N'最后登陆IP',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'login_ip'
GO

EXEC sp_addextendedproperty
'MS_Description', N'最后登陆时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'login_date'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建者',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'create_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'create_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新者',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'update_by'
GO

EXEC sp_addextendedproperty
'MS_Description', N'更新时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'update_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'备注',
'SCHEMA', N'dbo',
'TABLE', N'sys_user',
'COLUMN', N'remark'
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户信息表',
'SCHEMA', N'dbo',
'TABLE', N'sys_user'
GO



-- ----------------------------
-- 初始化-用户信息表数据
-- ----------------------------
SET IDENTITY_INSERT [dbo].[sys_user] ON
GO

INSERT INTO [dbo].[sys_user] ([user_id], [dept_id], [login_name], [user_name], [user_type], [email], [phonenumber], [sex], [avatar], [password], [salt], [status], [del_flag], [login_ip], [login_date], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'1', N'103', N'admin', N'若依', N'00', N'ry@163.com', N'15888888888', N'1', N'', N'29c67a30398638269fe600f73a054934', N'111111', N'0', N'0', N'127.0.0.1', N'2019-03-04 11:25:24.0160000', N'admin', N'2018-03-16 11:33:00.0000000', N'ry', N'2019-03-04 11:25:24.0230000', N'管理员')
GO

INSERT INTO [dbo].[sys_user] ([user_id], [dept_id], [login_name], [user_name], [user_type], [email], [phonenumber], [sex], [avatar], [password], [salt], [status], [del_flag], [login_ip], [login_date], [create_by], [create_time], [update_by], [update_time], [remark]) VALUES (N'2', N'105', N'ry', N'若依', N'00', N'ry@qq.com', N'15666666666', N'1', N'', N'8e6d98b90472783cc73c17047ddccf36', N'222222', N'0', N'0', N'127.0.0.1', N'2019-03-03 14:44:40.0000000', N'admin', N'2018-03-16 11:33:00.0000000', N'admin', N'2019-03-04 11:02:38.7270000', N'测试员')
GO

SET IDENTITY_INSERT [dbo].[sys_user] OFF
GO


-- ----------------------------
-- 27、在线用户记录
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_user_online]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_user_online]
GO

CREATE TABLE [dbo].[sys_user_online] (
  [sessionId]                     nvarchar(50)                  DEFAULT (N'')                   NOT NULL,
  [login_name]                    nvarchar(50)                  DEFAULT (N'')                       NULL,
  [dept_name]                     nvarchar(50)                  DEFAULT (N'')                       NULL,
  [ipaddr]                        nvarchar(50)                  DEFAULT (N'')                       NULL,
  [login_location]                nvarchar(255)                 DEFAULT (N'')                       NULL,
  [browser]                       nvarchar(50)                  DEFAULT (N'')                       NULL,
  [os]                            nvarchar(50)                  DEFAULT (N'')                       NULL,
  [status]                        nvarchar(10)                  DEFAULT (N'')                       NULL,
  [start_timestamp]               datetime2(7)                  DEFAULT NULL                        NULL,
  [last_access_time]              datetime2(7)                  DEFAULT NULL                        NULL,
  [expire_time]                   int                           DEFAULT ((0))                       NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户会话id',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'sessionId'
GO

EXEC sp_addextendedproperty
'MS_Description', N'登录账号',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'login_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'部门名称',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'dept_name'
GO

EXEC sp_addextendedproperty
'MS_Description', N'登录IP地址',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'ipaddr'
GO

EXEC sp_addextendedproperty
'MS_Description', N'登录地点',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'login_location'
GO

EXEC sp_addextendedproperty
'MS_Description', N'浏览器类型',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'browser'
GO

EXEC sp_addextendedproperty
'MS_Description', N'操作系统',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'os'
GO

EXEC sp_addextendedproperty
'MS_Description', N'在线状态on_line在线off_line离线',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'status'
GO

EXEC sp_addextendedproperty
'MS_Description', N'session创建时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'start_timestamp'
GO

EXEC sp_addextendedproperty
'MS_Description', N'session最后访问时间',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'last_access_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'超时时间，单位为分钟',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online',
'COLUMN', N'expire_time'
GO

EXEC sp_addextendedproperty
'MS_Description', N'在线用户记录',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_online'
GO


-- ----------------------------
-- 28、用户与岗位关联表  用户1-N岗位
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_user_post]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_user_post]
GO

CREATE TABLE [dbo].[sys_user_post] (
  [user_id]             int              NOT NULL,
  [post_id]             int              NOT NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_post',
'COLUMN', N'user_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'岗位ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_post',
'COLUMN', N'post_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户与岗位关联表',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_post'
GO


-- ----------------------------
-- 初始化-用户与岗位关联表数据
-- ----------------------------
INSERT INTO [dbo].[sys_user_post]  VALUES (N'1', N'1')
GO

INSERT INTO [dbo].[sys_user_post]  VALUES (N'2', N'2')
GO


-- ----------------------------
-- 29、用户和角色关联表  用户N-1角色
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_user_role]') AND type IN ('U'))
	DROP TABLE [dbo].[sys_user_role]
GO

CREATE TABLE [dbo].[sys_user_role] (
  [user_id]             int             NOT NULL,
  [role_id]             int             NOT NULL
)
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_role',
'COLUMN', N'user_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'角色ID',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_role',
'COLUMN', N'role_id'
GO

EXEC sp_addextendedproperty
'MS_Description', N'用户和角色关联表',
'SCHEMA', N'dbo',
'TABLE', N'sys_user_role'
GO


-- ----------------------------
-- 初始化-用户和角色关联表数据
-- ----------------------------
INSERT INTO [dbo].[sys_user_role]  VALUES (N'1', N'1')
GO

INSERT INTO [dbo].[sys_user_role]  VALUES (N'2', N'2')
GO



-- ----------------------------
-- Primary Key structure for table qrtz_blob_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_blob_triggers] ADD CONSTRAINT [PK_QRTZ_BLOB_TRIGGERS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [trigger_name], [trigger_group])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_calendars
-- ----------------------------
ALTER TABLE [dbo].[qrtz_calendars] ADD CONSTRAINT [PK_QRTZ_CALENDARS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [calendar_name])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_cron_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_cron_triggers] ADD CONSTRAINT [PK_QRTZ_CRON_TRIGGERS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [trigger_name], [trigger_group])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_fired_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_fired_triggers] ADD CONSTRAINT [PK_QRTZ_FIRED_TRIGGERS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [entry_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_job_details
-- ----------------------------
ALTER TABLE [dbo].[qrtz_job_details] ADD CONSTRAINT [PK_QRTZ_JOB_DETAILS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [job_name], [job_group])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_locks
-- ----------------------------
ALTER TABLE [dbo].[qrtz_locks] ADD CONSTRAINT [PK_QRTZ_LOCKS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [lock_name])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_paused_trigger_grps
-- ----------------------------
ALTER TABLE [dbo].[qrtz_paused_trigger_grps] ADD CONSTRAINT [PK_QRTZ_PAUSED_TRIGGER_GRPS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [trigger_group])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_scheduler_state
-- ----------------------------
ALTER TABLE [dbo].[qrtz_scheduler_state] ADD CONSTRAINT [PK_QRTZ_SCHEDULER_STATE_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [instance_name])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_simple_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_simple_triggers] ADD CONSTRAINT [PK_QRTZ_SIMPLE_TRIGGERS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [trigger_name], [trigger_group])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_simprop_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_simprop_triggers] ADD CONSTRAINT [PK_QRTZ_SIMPROP_TRIGGERS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [trigger_name], [trigger_group])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table qrtz_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_triggers] ADD CONSTRAINT [PK_QRTZ_TRIGGERS_sched_name] PRIMARY KEY CLUSTERED ([sched_name], [trigger_name], [trigger_group])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_config
-- ----------------------------
ALTER TABLE [dbo].[sys_config] ADD CONSTRAINT [PK_sys_config_config_id] PRIMARY KEY CLUSTERED ([config_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_dept
-- ----------------------------
ALTER TABLE [dbo].[sys_dept] ADD CONSTRAINT [PK_sys_dept_dept_id] PRIMARY KEY CLUSTERED ([dept_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_dict_data
-- ----------------------------
ALTER TABLE [dbo].[sys_dict_data] ADD CONSTRAINT [PK_sys_dict_data_dict_code] PRIMARY KEY CLUSTERED ([dict_code])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Uniques structure for table sys_dict_type
-- ----------------------------
ALTER TABLE [dbo].[sys_dict_type] ADD CONSTRAINT [sys_dict_type$dict_type] UNIQUE NONCLUSTERED ([dict_type] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_dict_type
-- ----------------------------
ALTER TABLE [dbo].[sys_dict_type] ADD CONSTRAINT [PK_sys_dict_type_dict_id] PRIMARY KEY CLUSTERED ([dict_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_job
-- ----------------------------
ALTER TABLE [dbo].[sys_job] ADD CONSTRAINT [PK_sys_job_job_id] PRIMARY KEY CLUSTERED ([job_id], [job_name], [job_group])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_job_log
-- ----------------------------
ALTER TABLE [dbo].[sys_job_log] ADD CONSTRAINT [PK_sys_job_log_job_log_id] PRIMARY KEY CLUSTERED ([job_log_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_logininfor
-- ----------------------------
ALTER TABLE [dbo].[sys_logininfor] ADD CONSTRAINT [PK_sys_logininfor_info_id] PRIMARY KEY CLUSTERED ([info_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_menu
-- ----------------------------
ALTER TABLE [dbo].[sys_menu] ADD CONSTRAINT [PK_sys_menu_menu_id] PRIMARY KEY CLUSTERED ([menu_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_notice
-- ----------------------------
ALTER TABLE [dbo].[sys_notice] ADD CONSTRAINT [PK_sys_notice_notice_id] PRIMARY KEY CLUSTERED ([notice_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_oper_log
-- ----------------------------
ALTER TABLE [dbo].[sys_oper_log] ADD CONSTRAINT [PK_sys_oper_log_oper_id] PRIMARY KEY CLUSTERED ([oper_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_post
-- ----------------------------
ALTER TABLE [dbo].[sys_post] ADD CONSTRAINT [PK_sys_post_post_id] PRIMARY KEY CLUSTERED ([post_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_role
-- ----------------------------
ALTER TABLE [dbo].[sys_role] ADD CONSTRAINT [PK_sys_role_role_id] PRIMARY KEY CLUSTERED ([role_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_role_dept
-- ----------------------------
ALTER TABLE [dbo].[sys_role_dept] ADD CONSTRAINT [PK_sys_role_dept_role_id] PRIMARY KEY CLUSTERED ([role_id], [dept_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_role_menu
-- ----------------------------
ALTER TABLE [dbo].[sys_role_menu] ADD CONSTRAINT [PK_sys_role_menu_role_id] PRIMARY KEY CLUSTERED ([role_id], [menu_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_user
-- ----------------------------
ALTER TABLE [dbo].[sys_user] ADD CONSTRAINT [PK_sys_user_user_id] PRIMARY KEY CLUSTERED ([user_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_user_online
-- ----------------------------
ALTER TABLE [dbo].[sys_user_online] ADD CONSTRAINT [PK_sys_user_online_sessionId] PRIMARY KEY CLUSTERED ([sessionId])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_user_post
-- ----------------------------
ALTER TABLE [dbo].[sys_user_post] ADD CONSTRAINT [PK_sys_user_post_user_id] PRIMARY KEY CLUSTERED ([user_id], [post_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table sys_user_role
-- ----------------------------
ALTER TABLE [dbo].[sys_user_role] ADD CONSTRAINT [PK_sys_user_role_user_id] PRIMARY KEY CLUSTERED ([user_id], [role_id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Foreign Keys structure for table qrtz_blob_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_blob_triggers] ADD CONSTRAINT [QRTZ_BLOB_TRIGGERS$QRTZ_BLOB_TRIGGERS_ibfk_1] FOREIGN KEY ([sched_name], [trigger_name], [trigger_group]) REFERENCES [QRTZ_TRIGGERS] ([sched_name], [trigger_name], [trigger_group]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO


-- ----------------------------
-- Foreign Keys structure for table qrtz_cron_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_cron_triggers] ADD CONSTRAINT [QRTZ_CRON_TRIGGERS$QRTZ_CRON_TRIGGERS_ibfk_1] FOREIGN KEY ([sched_name], [trigger_name], [trigger_group]) REFERENCES [QRTZ_TRIGGERS] ([sched_name], [trigger_name], [trigger_group]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO


-- ----------------------------
-- Foreign Keys structure for table qrtz_simple_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_simple_triggers] ADD CONSTRAINT [QRTZ_SIMPLE_TRIGGERS$QRTZ_SIMPLE_TRIGGERS_ibfk_1] FOREIGN KEY ([sched_name], [trigger_name], [trigger_group]) REFERENCES [QRTZ_TRIGGERS] ([sched_name], [trigger_name], [trigger_group]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO


-- ----------------------------
-- Foreign Keys structure for table qrtz_simprop_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_simprop_triggers] ADD CONSTRAINT [QRTZ_SIMPROP_TRIGGERS$QRTZ_SIMPROP_TRIGGERS_ibfk_1] FOREIGN KEY ([sched_name], [trigger_name], [trigger_group]) REFERENCES [QRTZ_TRIGGERS] ([sched_name], [trigger_name], [trigger_group]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO


-- ----------------------------
-- Foreign Keys structure for table qrtz_triggers
-- ----------------------------
ALTER TABLE [dbo].[qrtz_triggers] ADD CONSTRAINT [QRTZ_TRIGGERS$QRTZ_TRIGGERS_ibfk_1] FOREIGN KEY ([sched_name], [job_name], [job_group]) REFERENCES [QRTZ_JOB_DETAILS] ([sched_name], [job_name], [job_group]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO

