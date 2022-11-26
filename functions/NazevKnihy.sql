DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `NazevKnihy`(b_id INT) RETURNS varchar(128) CHARSET utf8
RETURN
  (SELECT name FROM Books WHERE book_id=b_id)$$
DELIMITER ;
