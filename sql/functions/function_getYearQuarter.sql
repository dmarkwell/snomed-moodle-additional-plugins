DELIMITER ;;
DROP FUNCTION IF EXISTS `getYearQuarter`;;
CREATE FUNCTION `getYearQuarter`(`p_unixtime` bigint(10)) RETURNS char(6) CHARSET latin1
begin
  return CONCAT(DATE_FORMAT(FROM_UNIXTIME(`p_unixtime`),'%Y'),'q',CAST(TRUNCATE((MONTH(FROM_UNIXTIME(`p_unixtime`))+2)/3,0) AS CHAR CHARACTER SET utf8));
end;;
