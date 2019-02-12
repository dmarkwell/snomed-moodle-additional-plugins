DROP FUNCTION IF EXISTS `getMonthNumber`;;
CREATE FUNCTION `getMonthNumber`(`p_unixtime` bigint(10)) RETURNS int(5)
begin

return (year(FROM_UNIXTIME(p_unixtime))-2015)*12+month(FROM_UNIXTIME(p_unixtime));
end;;
