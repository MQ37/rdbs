CREATE TRIGGER `borrowings_returned` AFTER UPDATE ON `Borrowings`
 FOR EACH ROW BEGIN

	IF NEW.returned = 1 THEN
    	INSERT INTO BorrowingsLog(bor_id, returned_at, state) VALUES (OLD.bor_id, NOW(), "returned");
    END IF;

END
