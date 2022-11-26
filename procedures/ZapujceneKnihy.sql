DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `ZapujceneKnihy`()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE vsb_id INT;
DECLARE vb_id INT;
DECLARE vnazev VARCHAR(128);

DECLARE cur CURSOR FOR SELECT shelfbook_id, book_id FROM ShelfBooks;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

CREATE TEMPORARY TABLE TempZapujcene (
shelfbook_id INT PRIMARY KEY,
nazev VARCHAR(128)
);

OPEN cur;

  read_loop: LOOP
    FETCH cur INTO vsb_id, vb_id;
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    IF (SELECT vsb_id IN (SELECT shelfbook_id FROM Borrowings WHERE returned = 0)) THEN
       SELECT NazevKnihy(vb_id) INTO vnazev;
       INSERT INTO TempZapujcene VALUES (vsb_id, vnazev);
    END IF;
    
  END LOOP;

  CLOSE cur;

  SELECT COUNT(*) AS "Zapůjčené knihy" FROM TempZapujcene;
  SELECT * FROM TempZapujcene;

END$$
DELIMITER ;
