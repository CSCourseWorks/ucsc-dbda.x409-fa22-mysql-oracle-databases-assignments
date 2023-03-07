# @_CREATE_TRIGGER_
# Track changes in the information_schema.key_column_usage table.
DELIMITER $
DROP TABLE IF EXISTS CONSTRAINT_AUDIT$
DROP TRIGGER IF EXISTS CONSTRAINT_TRIGGER_DELETE$

CREATE TABLE CONSTRAINT_AUDIT AS 
	SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, 
		REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
	FROM information_schema.key_column_usage 
	WHERE 1=2$ # Create an empty table with required columns.

ALTER TABLE CONSTRAINT_AUDIT ADD COLUMN MODE VARCHAR(10)$
ALTER TABLE CONSTRAINT_AUDIT ADD COLUMN HISTORY_DATE TIMESTAMP$
ALTER TABLE CONSTRAINT_AUDIT ADD COLUMN USER_NAME VARCHAR(100)$

CREATE TRIGGER CONSTRAINT_TRIGGER_DELETE 
AFTER DELETE ON information_schema.key_column_usage FOR EACH ROW
BEGIN
	INSERT INTO CONSTRAINT_AUDIT(TABLE_NAME,
								 COLUMN_NAME,
								 CONSTRAINT_NAME,
                                 REFERENCED_TABLE_NAME,
                                 REFERENCED_COLUMN_NAME,
                                 MODE,
                                 HISTORY_DATE,
                                 user_name)
	VALUES(OLD.TABLE_NAME,
		   OLD.COLUMN_NAME,
		   OLD.CONSTRAINT_NAME,
           OLD.REFERENCED_TABLE_NAME,
           OLD.REFERENCED_COLUMN_NAME,
           'DELETE',
           current_timestamp(),
           user());
END$
DELIMITER ;