CREATE TRIGGER `borrowings_borrowed` AFTER INSERT ON `Borrowings`
 FOR EACH ROW BEGIN

    INSERT INTO BorrowingsLog(bor_id, returned_at, state) VALUES (NEW.bor_id, NULL, "borrowed");

END
