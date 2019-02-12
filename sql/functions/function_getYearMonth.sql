DELIMITER ;;
DROP FUNCTION IF EXISTS `getYearMonth`;;
CREATE FUNCTION `getYearMonth`(`p_monthnumber` int(5)) RETURNS char(6) CHARSET latin1
begin
return CONCAT(TRUNCATE((p_monthnumber-1)/12,0)+2015,LPAD(1+(p_monthnumber-1)%12,2,'0'));
end;;
