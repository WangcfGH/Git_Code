/*
Navicat MySQL Data Transfer

Source Server         : jianglimk
Source Server Version : 50640
Source Host           : mysql9.tcy365.org:3306
Source Database       : chunk283db

Target Server Type    : MYSQL
Target Server Version : 50640
File Encoding         : 65001

Date: 2018-09-28 14:53:11
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for tbl_agent_room_info
-- ----------------------------
DROP TABLE IF EXISTS `tbl_agent_room_info`;
CREATE TABLE `tbl_agent_room_info` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `business_order_code` varchar(44) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `room_num` int(11) DEFAULT NULL,
  `room_type` int(11) DEFAULT NULL,
  `create_time` int(11) DEFAULT NULL,
  `time_out` int(11) DEFAULT NULL,
  `pay_count` int(11) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `bout` int(11) DEFAULT NULL,
  `dissolved_user_id` int(11) DEFAULT NULL,
  `player_info_json` text,
  `rule_json` text,
  `pay_user_id` int(11) DEFAULT NULL,
  `sub_state` int(11) DEFAULT NULL,
  `lap_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `IDX_USERID_ID` (`user_id`,`create_time`,`ID`) USING BTREE,
  KEY `IDX_STATE` (`state`) USING BTREE,
  KEY `IDX_SUBSTATE` (`sub_state`) USING BTREE,
  KEY `IDX_BUSINESSORDERCODE` (`business_order_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for tbl_flaunt_share
-- ----------------------------
DROP TABLE IF EXISTS `tbl_flaunt_share`;
CREATE TABLE `tbl_flaunt_share` (
  `user_id` bigint(20) NOT NULL,
  `repeatwin_count` int(11) DEFAULT '0',
  `repeatlose_count` int(11) DEFAULT '0',
  KEY `PX_tbl_flaunt_share_UserID` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for tbl_life_task_data
-- ----------------------------
DROP TABLE IF EXISTS `tbl_life_task_data`;
CREATE TABLE `tbl_life_task_data` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `task_id` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`task_id`),
  KEY `index_userid` (`user_id`) USING BTREE,
  KEY `index_userid_taskid` (`user_id`,`task_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for tbl_life_task_data_classic
-- ----------------------------
DROP TABLE IF EXISTS `tbl_life_task_data_classic`;
CREATE TABLE `tbl_life_task_data_classic` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `task_id` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`task_id`),
  KEY `index_userid` (`user_id`) USING BTREE,
  KEY `index_userid_taskid` (`user_id`,`task_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for tbl_life_task_param
-- ----------------------------
DROP TABLE IF EXISTS `tbl_life_task_param`;
CREATE TABLE `tbl_life_task_param` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `type` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`type`),
  KEY `index_userid` (`user_id`) USING BTREE,
  KEY `index_userid_type` (`user_id`,`type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for tbl_life_task_param_classic
-- ----------------------------
DROP TABLE IF EXISTS `tbl_life_task_param_classic`;
CREATE TABLE `tbl_life_task_param_classic` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `type` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`type`),
  KEY `index_userid` (`user_id`) USING BTREE,
  KEY `index_userid_type` (`user_id`,`type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for tbl_lottery_count_info
-- ----------------------------
DROP TABLE IF EXISTS `tbl_lottery_count_info`;
CREATE TABLE `tbl_lottery_count_info` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `date` int(11) NOT NULL DEFAULT '0',
  `type_id` int(11) NOT NULL DEFAULT '0',
  `count` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `index_userid_date_type` (`user_id`,`date`,`type_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3713 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for tbl_lottery_record
-- ----------------------------
DROP TABLE IF EXISTS `tbl_lottery_record`;
CREATE TABLE `tbl_lottery_record` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `draw_time` varchar(32) DEFAULT NULL,
  `phone_num` varchar(32) DEFAULT NULL,
  `hard_id` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1496 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for tbl_total_thumb
-- ----------------------------
DROP TABLE IF EXISTS `tbl_total_thumb`;
CREATE TABLE `tbl_total_thumb` (
  `user_id` bigint(20) NOT NULL,
  `thumb_count` int(11) DEFAULT '0',
  KEY `PX_tbl_total_thumb_UserID` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for test
-- ----------------------------
DROP TABLE IF EXISTS `test`;
CREATE TABLE `test` (
  `c1` int(11) DEFAULT NULL,
  `c2` int(11) DEFAULT NULL,
  `c3` int(11) DEFAULT NULL,
  `c4` int(11) DEFAULT NULL,
  KEY `idx_c1_c2` (`c1`,`c2`,`c3`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- ----------------------------
-- Procedure structure for usp_add_flaunt_share
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_add_flaunt_share`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_add_flaunt_share`(IN `nUserID` bigint,IN `bWin` int)
BEGIN
	IF ISNULL((SELECT user_id FROM tbl_flaunt_share WHERE user_id = nUserID)) THEN
		IF bWin = 1 THEN
			INSERT INTO tbl_flaunt_share(user_id, repeatwin_count, repeatlose_count) VALUES(nUserID, 1, 0);
		ELSE
			INSERT INTO tbl_flaunt_share(user_id, repeatwin_count, repeatlose_count) VALUES(nUserID, 0, 1);
		END IF;
	ELSE
		IF bWin = 1 THEN
			UPDATE tbl_flaunt_share SET repeatwin_count = tbl_flaunt_share.repeatwin_count + 1 , repeatlose_count = 0 WHERE user_id = nUserID;
		ELSE
			UPDATE tbl_flaunt_share SET repeatlose_count = tbl_flaunt_share.repeatlose_count + 1, repeatwin_count = 0 WHERE user_id = nUserID;
		END IF;
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_add_thumb_totalcount
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_add_thumb_totalcount`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_add_thumb_totalcount`(IN `nUserID` bigint,IN `nThumbCount` int)
BEGIN
	IF ISNULL((SELECT user_id FROM tbl_total_thumb WHERE user_id = nUserID)) THEN
		INSERT INTO tbl_total_thumb(user_id, thumb_count) VALUES(nUserID, nThumbCount);
	ELSE
		UPDATE tbl_total_thumb SET thumb_count = tbl_total_thumb.thumb_count + 1 WHERE user_id = nUserID;
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_append_agent_room
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_append_agent_room`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_append_agent_room`(IN `p_business_order_code` varchar(44), IN `p_user_id` int,IN `p_room_num` int,IN `p_room_type` int,IN `p_create_time` int,IN `p_time_out` int,IN `p_pay_count` int,IN `p_state` int,IN `p_bout` int,IN `p_dissolved_user_id` int,IN `p_player_info_json` text,IN `p_rule_json` text,IN `p_pay_user_id` int,IN `p_sub_state` int,IN `p_lap_count` int)
BEGIN
	#Routine body goes here...
	INSERT INTO tbl_agent_room_info 
  (business_order_code, user_id, room_num, room_type, create_time, time_out, pay_count, state, bout, lap_count, dissolved_user_id, player_info_json, rule_json, pay_user_id, sub_state) 
  VALUES 
  (p_business_order_code,p_user_id,p_room_num,p_room_type,p_create_time,p_time_out,p_pay_count,p_state,p_bout,p_lap_count,p_dissolved_user_id,p_player_info_json,p_rule_json,p_pay_user_id,p_sub_state);
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_change_agent_roomInfo_state_a_2_state_b
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_change_agent_roomInfo_state_a_2_state_b`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_change_agent_roomInfo_state_a_2_state_b`(IN `p_user_id` int,IN `p_state_a` int,IN `p_state_b` int)
BEGIN
	#Routine body goes here...
	UPDATE tbl_agent_room_info SET state = p_state_b WHERE user_id = p_user_id AND state = p_state_a;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_change_sub_agent_roomInfo_state_a_2_state_b
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_change_sub_agent_roomInfo_state_a_2_state_b`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_change_sub_agent_roomInfo_state_a_2_state_b`(IN `p_user_id` int,IN `p_sub_state_a` int,IN `p_sub_state_b` int)
BEGIN
	#Routine body goes here...
	UPDATE tbl_agent_room_info SET sub_state = p_sub_state_b WHERE user_id = p_user_id AND sub_state = p_sub_state_a;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_modify_agent_room_state
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_modify_agent_room_state`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_modify_agent_room_state`(IN `p_business_order_code` varchar(44),IN `p_state` int)
BEGIN
	#Routine body goes here...
	DECLARE cur_state INT;
	DECLARE retrun_value INT;
	SET cur_state = (SELECT state FROM tbl_agent_room_info WHERE business_order_code = p_business_order_code);
	IF p_state > cur_state THEN
		UPDATE tbl_agent_room_info SET state = p_state WHERE business_order_code = p_business_order_code;
		SET retrun_value = 1;
	ELSE
		SET retrun_value = 0;
	END IF;
	SELECT retrun_value;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_modify_sub_agent_room_state
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_modify_sub_agent_room_state`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_modify_sub_agent_room_state`(IN `p_business_order_code` varchar(44),IN `p_sub_state` int)
BEGIN
	#Routine body goes here...
	DECLARE cur_state INT;
	DECLARE retrun_value INT;
	SET cur_state = (SELECT sub_state FROM tbl_agent_room_info WHERE business_order_code = p_business_order_code);
	IF p_sub_state > cur_state THEN
		UPDATE tbl_agent_room_info SET sub_state = p_sub_state WHERE business_order_code = p_business_order_code;
		SET retrun_value = 1;
	ELSE
		SET retrun_value = 0;
	END IF;
	SELECT retrun_value;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_agent_room_infos
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_agent_room_infos`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_agent_room_infos`(IN `p_user_id` int,IN `p_page_size` int,IN `p_page_index` int,INOUT `p_max_id` int, OUT `p_un_confirm` int)
BEGIN
	#Routine body goes here...
	DECLARE index_size INT;
	set index_size = (p_page_index-1)*p_page_size;
	IF p_max_id=0 THEN
		SELECT business_order_code, room_num, room_type, create_time, time_out, pay_count, state, bout, lap_count, dissolved_user_id, player_info_json, rule_json, pay_user_id, sub_state
		FROM tbl_agent_room_info WHERE user_id = p_user_id AND state<>3 ORDER BY create_time DESC, id DESC LIMIT index_size, p_page_size;

		SET p_max_id = (SELECT id FROM tbl_agent_room_info WHERE user_id = p_user_id AND state<>3 ORDER BY id DESC LIMIT 1);
	ELSE
		SELECT business_order_code, room_num, room_type, create_time, time_out, pay_count, state, bout, lap_count, dissolved_user_id, player_info_json, rule_json, pay_user_id, sub_state
		FROM tbl_agent_room_info WHERE user_id = p_user_id AND state<>3 AND id <= p_max_id ORDER BY create_time DESC, id DESC LIMIT index_size, p_page_size;
	END IF;

	SET p_un_confirm = (SELECT COUNT(id) FROM tbl_agent_room_info WHERE user_id = p_user_id AND state=1 AND id <= p_max_id);
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_flaunt_share
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_flaunt_share`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_flaunt_share`(
	IN `nUserID` bigint
)
BEGIN
	SELECT repeatwin_count, repeatlose_count FROM tbl_flaunt_share WHERE user_id = nUserID;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_lottery_count_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_lottery_count_info`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_lottery_count_info`(IN `p_date` int,IN `p_user_id` int,IN `p_max_type_count` int)
BEGIN
	#Routine body goes here...
	SELECT type_id,count FROM tbl_lottery_count_info WHERE date = p_date AND user_id = p_user_id AND type_id > 0 AND type_id < p_max_type_count;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_ltask_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_ltask_data`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_ltask_data`(IN `p_user_id` int)
BEGIN
	SELECT task_id, status FROM tbl_life_task_data WHERE user_id=p_user_id;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_ltask_data_classic
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_ltask_data_classic`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_ltask_data_classic`(IN `p_user_id` int)
BEGIN
	SELECT task_id, status FROM tbl_life_task_data_classic WHERE user_id=p_user_id;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_ltask_data_ex
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_ltask_data_ex`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_ltask_data_ex`(IN `p_user_id` int,IN `p_task_id` int)
BEGIN
	#Routine body goes here...
	SELECT task_id, status FROM tbl_life_task_data WHERE user_id=p_user_id AND task_id=p_task_id;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_ltask_data_ex_classic
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_ltask_data_ex_classic`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_ltask_data_ex_classic`(IN `p_user_id` int,IN `p_task_id` int)
BEGIN
	#Routine body goes here...
	SELECT task_id, status FROM tbl_life_task_data_classic WHERE user_id=p_user_id AND task_id=p_task_id;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_ltask_param
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_ltask_param`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_ltask_param`(IN `p_user_id` int)
BEGIN
	#Routine body goes here...
	SELECT count, type FROM tbl_life_task_param WHERE user_id=p_user_id;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_ltask_param_classic
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_ltask_param_classic`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_ltask_param_classic`(IN `p_user_id` int)
BEGIN
	#Routine body goes here...
	SELECT count, type FROM tbl_life_task_param_classic WHERE user_id=p_user_id;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_ltask_param_ex
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_ltask_param_ex`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_ltask_param_ex`(IN `p_user_id` int,IN `p_type` int)
BEGIN
	#Routine body goes here...
	SELECT count FROM tbl_life_task_param WHERE user_id=p_user_id AND type=p_type;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_ltask_param_ex_classic
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_ltask_param_ex_classic`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_ltask_param_ex_classic`(IN `p_user_id` int,IN `p_type` int)
BEGIN
	#Routine body goes here...
	SELECT count FROM tbl_life_task_param_classic WHERE user_id=p_user_id AND type=p_type;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_sub_agent_room_infos
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_sub_agent_room_infos`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_sub_agent_room_infos`(IN `p_user_id` int,IN `p_page_size` int,IN `p_page_index` int,INOUT `p_max_id` int, OUT `p_un_confirm` int)
BEGIN
	#Routine body goes here...
	DECLARE index_size INT;
	set index_size = (p_page_index-1)*p_page_size;
	IF p_max_id=0 THEN
		SELECT business_order_code, room_num, room_type, create_time, time_out, pay_count, state, bout, lap_count, dissolved_user_id, player_info_json, rule_json, pay_user_id, sub_state
		FROM tbl_agent_room_info WHERE user_id = p_user_id AND sub_state<>3 ORDER BY create_time DESC, id DESC LIMIT index_size, p_page_size;

		SET p_max_id = (SELECT id FROM tbl_agent_room_info WHERE user_id = p_user_id AND sub_state<>3 ORDER BY id DESC LIMIT 1);
	ELSE
		SELECT business_order_code, room_num, room_type, create_time, time_out, pay_count, state, bout, lap_count, dissolved_user_id, player_info_json, rule_json, pay_user_id, sub_state
		FROM tbl_agent_room_info WHERE user_id = p_user_id AND sub_state<>3 AND id <= p_max_id ORDER BY create_time DESC, id DESC LIMIT index_size, p_page_size;
	END IF;

	SET p_un_confirm = (SELECT COUNT(id) FROM tbl_agent_room_info WHERE user_id = p_user_id AND sub_state=1 AND id <= p_max_id);
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_query_thumb_count
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_query_thumb_count`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_query_thumb_count`(
	IN `nUserID` bigint, OUT `nCount` int
)
BEGIN
	SET nCount =(SELECT thumb_count FROM tbl_total_thumb WHERE user_id = nUserID);
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_update_lottery_count_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_update_lottery_count_info`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_update_lottery_count_info`(IN `p_date` int,IN `p_user_id` int,IN `p_type_id` int,IN `p_count` int)
BEGIN
	#Routine body goes here...
	IF(EXISTS(SELECT * FROM tbl_lottery_count_info WHERE user_id=p_user_id AND date=p_date AND type_id=p_type_id)) THEN
		 UPDATE tbl_lottery_count_info SET count=(count+p_count) WHERE user_id=p_user_id AND date=p_date AND type_id = p_type_id;
	ELSE
		 INSERT INTO tbl_lottery_count_info(user_id,date,type_id,count) VALUES(p_user_id,p_date,p_type_id,p_count);
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_update_lottery_record
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_update_lottery_record`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_update_lottery_record`(IN `p_date` int,IN `p_user_id` int,IN `p_type_id` int,IN `p_count` int,IN `p_time` varchar(64),IN `p_phone_num` varchar(64),IN `p_hard_id` varchar(128))
BEGIN
	#Routine body goes here...
	#SQLEXCEPTION 异常捕获 1205加锁超时
	DECLARE t_error INTEGER DEFAULT 0;
	DECLARE time_out_error INTEGER DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
	DECLARE CONTINUE HANDLER FOR 1205 SET time_out_error=1;

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

	REPEAT
		START TRANSACTION;
		INSERT INTO tbl_lottery_record(user_id,type_id,count,draw_time,phone_num,hard_id) VALUES(p_user_id,p_type_id,p_count,p_time,p_phone_num,p_hard_id);

		IF(EXISTS(SELECT * FROM tbl_lottery_count_info WHERE user_id=p_user_id AND date=p_date AND type_id=0)) THEN
			UPDATE tbl_lottery_count_info SET count=count+1 WHERE user_id=p_user_id AND date=p_date AND type_id=0;
		ELSE
			INSERT INTO tbl_lottery_count_info(user_id,date,type_id,count) VALUES(p_user_id,p_date,0,1);
		END IF;

		IF p_type_id = 2 THEN
			IF(EXISTS(SELECT * FROM tbl_lottery_count_info WHERE user_id=p_user_id AND date=p_date AND type_id=1)) THEN
				UPDATE tbl_lottery_count_info SET count=count+1 WHERE user_id=p_user_id AND date=p_date AND type_id=1;
			ELSE
				INSERT INTO tbl_lottery_count_info (user_id,date,type_id,count) VALUES(p_user_id,p_date,1,1);
			END IF;
		END IF;

		IF t_error = 1 THEN
			ROLLBACK;
		ELSE
			COMMIT;
		END IF;
	UNTIL time_out_error = 0
	END REPEAT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_update_ltask_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_update_ltask_data`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_update_ltask_data`(IN `p_user_id` int,IN `p_task_id` int,IN `p_status` int)
BEGIN
	#Routine body goes here...
	#SQLEXCEPTION 异常捕获 1205加锁超时
	DECLARE t_error INTEGER DEFAULT 0;
	DECLARE time_out_error INTEGER DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
	DECLARE CONTINUE HANDLER FOR 1205 SET time_out_error=1;

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

	REPEAT
		START TRANSACTION;
		IF EXISTS(SELECT * FROM tbl_life_task_data WHERE user_id=p_user_id AND task_id=p_task_id) THEN
			UPDATE tbl_life_task_data SET status=p_status WHERE user_id=p_user_id AND task_id=p_task_id;
		ELSE
			INSERT INTO tbl_life_task_data (user_id,task_id,status) VALUES(p_user_id,p_task_id,p_status);
		END IF;
		IF t_error = 1 THEN
			ROLLBACK;
		ELSE
			COMMIT;
		END IF;
	UNTIL time_out_error = 0
	END REPEAT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_update_ltask_data_classic
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_update_ltask_data_classic`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_update_ltask_data_classic`(IN `p_user_id` int,IN `p_task_id` int,IN `p_status` int)
BEGIN
	#Routine body goes here...
	#SQLEXCEPTION 异常捕获 1205加锁超时
	DECLARE t_error INTEGER DEFAULT 0;
	DECLARE time_out_error INTEGER DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
	DECLARE CONTINUE HANDLER FOR 1205 SET time_out_error=1;

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

	REPEAT
		START TRANSACTION;
		IF EXISTS(SELECT * FROM tbl_life_task_data_classic WHERE user_id=p_user_id AND task_id=p_task_id) THEN
			UPDATE tbl_life_task_data_classic SET status=p_status WHERE user_id=p_user_id AND task_id=p_task_id;
		ELSE
			INSERT INTO tbl_life_task_data_classic (user_id,task_id,status) VALUES(p_user_id,p_task_id,p_status);
		END IF;
		IF t_error = 1 THEN
			ROLLBACK;
		ELSE
			COMMIT;
		END IF;
	UNTIL time_out_error = 0
	END REPEAT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_update_ltask_param
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_update_ltask_param`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_update_ltask_param`(IN `p_user_id` int,IN `p_task_type` int,IN `p_add_count` int)
BEGIN
	#Routine body goes here...
	#SQLEXCEPTION 异常捕获 1205加锁超时
	DECLARE t_error INTEGER DEFAULT 0;
	DECLARE time_out_error INTEGER DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
	DECLARE CONTINUE HANDLER FOR 1205 SET time_out_error=1;

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	REPEAT
		START TRANSACTION;
		IF EXISTS(SELECT * FROM tbl_life_task_param WHERE user_id=p_user_id AND type=p_task_type) THEN
			UPDATE tbl_life_task_param SET count=(p_add_count + count) WHERE user_id=p_user_id AND type=p_task_type;
		ELSE
			INSERT INTO tbl_life_task_param (user_id,type,count) VALUES(p_user_id,p_task_type,p_add_count);
		END IF;
		IF t_error = 1 THEN
			ROLLBACK;
		ELSE
			COMMIT;
		END IF;
	UNTIL time_out_error = 0
	END REPEAT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_update_ltask_param_classic
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_update_ltask_param_classic`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_update_ltask_param_classic`(IN `p_user_id` int,IN `p_task_type` int,IN `p_add_count` int)
BEGIN
	#Routine body goes here...
	#SQLEXCEPTION 异常捕获 1205加锁超时
	DECLARE t_error INTEGER DEFAULT 0;
	DECLARE time_out_error INTEGER DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
	DECLARE CONTINUE HANDLER FOR 1205 SET time_out_error=1;

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	REPEAT
		START TRANSACTION;
		IF EXISTS(SELECT * FROM tbl_life_task_param_classic WHERE user_id=p_user_id AND type=p_task_type) THEN
			UPDATE tbl_life_task_param_classic SET count=(p_add_count + count) WHERE user_id=p_user_id AND type=p_task_type;
		ELSE
			INSERT INTO tbl_life_task_param_classic (user_id,type,count) VALUES(p_user_id,p_task_type,p_add_count);
		END IF;
		IF t_error = 1 THEN
			ROLLBACK;
		ELSE
			COMMIT;
		END IF;
	UNTIL time_out_error = 0
	END REPEAT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for usp_update_player_infos_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `usp_update_player_infos_data`;
DELIMITER ;;
CREATE DEFINER=`chunk283`@`%` PROCEDURE `usp_update_player_infos_data`(IN `p_user_id` int,IN `p_task_id` int,IN `p_status` int)
BEGIN
	#Routine body goes here...
	#SQLEXCEPTION 异常捕获 1205加锁超时
	DECLARE t_error INTEGER DEFAULT 0;
	DECLARE time_out_error INTEGER DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
	DECLARE CONTINUE HANDLER FOR 1205 SET time_out_error=1;

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

	REPEAT
		START TRANSACTION;
		IF EXISTS(SELECT * FROM tbl_life_task_data WHERE user_id=p_user_id AND task_id=p_task_id) THEN
			UPDATE tbl_life_task_data SET status=p_status WHERE user_id=p_user_id AND task_id=p_task_id;
		ELSE
			INSERT INTO tbl_life_task_data (user_id,task_id,status) VALUES(p_user_id,p_task_id,p_status);
		END IF;
		IF t_error = 1 THEN
			ROLLBACK;
		ELSE
			COMMIT;
		END IF;
	UNTIL time_out_error = 0
	END REPEAT;
END
;;
DELIMITER ;
