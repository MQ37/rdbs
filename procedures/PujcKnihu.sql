DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `PujcKnihu`(IN shelfbookId INT, IN userId INT)
BEGIN
  START TRANSACTION;

  SELECT COUNT(*)
  INTO @shelfbookExists
  FROM ShelfBooks
  WHERE shelfbook_id = shelfbookId;

  IF @shelfbookExists = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Kniha neexistuje';
  END IF;

  SELECT COUNT(*)
  INTO @shelfbookBorrowed
  FROM Borrowings
  WHERE shelfbook_id = shelfbookId;

  IF @shelfbookBorrowed > 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Kniha už byla zapůjčena';
  END IF;

  INSERT INTO Borrowings (bor_id, user_id, shelfbook_id, borrowed_at)
  VALUES (NULL, userId, shelfbookId, CURRENT_TIMESTAMP());

  COMMIT;
END$$
DELIMITER ;
