ALTER TABLE Books
ADD FULLTEXT INDEX book_name_ft (name);
