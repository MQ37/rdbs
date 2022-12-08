DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `PrumerneHodnoceniAutora`(authorId INT) RETURNS decimal(10,2)
BEGIN
  RETURN (SELECT AVG(r.rating)
  FROM RatingsAuthors r
  WHERE r.author_id = authorId);
END$$
DELIMITER ;
