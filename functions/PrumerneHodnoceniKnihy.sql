DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `PrumerneHodnoceniKnihy`(bookId INT) RETURNS decimal(10,2)
BEGIN
  RETURN (SELECT AVG(r.rating) FROM RatingsBooks AS r WHERE r.book_id = bookId);
END$$
DELIMITER ;
