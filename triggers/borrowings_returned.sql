CREATE TRIGGER `borrowings_returned` AFTER UPDATE ON `Borrowings`
 FOR EACH ROW BEGIN

	IF NEW.returned = 1 THEN
    	INSERT INTO BorrowingsLog(bor_id, returned_at) VALUES (OLD.bor_id, NOW());
    END IF;

END
