-- Zapůjčené knihy
SELECT sb.shelfbook_id AS "id knihy", b.name AS "název" FROM ShelfBooks as sb JOIN Books as b on b.book_id=sb.book_id WHERE sb.shelfbook_id IN (SELECT bor.shelfbook_id FROM Borrowings as bor WHERE bor.returned=0); 

-- Nepůjčené knihy
SELECT sb.shelfbook_id AS "id knihy", b.name AS "název" FROM ShelfBooks as sb JOIN Books as b on b.book_id=sb.book_id WHERE sb.shelfbook_id NOT IN (SELECT bor.shelfbook_id FROM Borrowings as bor WHERE bor.returned=0); 

-- Počet knih podle žánru
SELECT g.genre AS "žánr", COUNT(bg.book_id) AS "počet knih" FROM BooksGenres AS bg JOIN Books AS b on b.book_id=bg.book_id JOIN Genres AS g ON g.genre_id=bg.genre_id GROUP BY g.genre_id ORDER BY COUNT(bg.book_id) DESC; 

-- Počet knih podle autora s alespoň 2 knihami
SELECT a.name AS "autor", COUNT(ba.book_id) AS "počet knih" FROM BooksAuthors AS ba JOIN Books AS b on b.book_id=ba.book_id JOIN Authors AS a ON a.author_id=ba.author_id GROUP BY a.author_id HAVING COUNT(ba.book_id) > 1 ORDER BY COUNT(ba.book_id) DESC; 

-- Kniha a její průměrné hodnocení pro všechny nadprůměrně hodnocené knihy
SELECT b.name AS "kniha", AVG(rb.rating) AS "průměrné hodnodení" FROM RatingsBooks AS rb JOIN Books AS b on b.book_id=rb.book_id GROUP BY rb.book_id HAVING AVG(rb.rating) > (SELECT AVG(rating) FROM RatingsBooks) ORDER BY AVG(rb.rating) DESC; 

-- Knihy bez hodnocení
SELECT b.book_id, b.name FROM Books AS b WHERE b.book_id NOT IN (SELECT rb.book_id FROM RatingsBooks AS rb); 

-- Průměrný počet záznamů
SELECT AVG(table_rows.trows) AS "Průměrný počet záznamů" FROM (SELECT t.table_name, t.table_rows AS trows
FROM information_schema.tables t
WHERE t.table_schema = 'library'
AND t.table_type = 'BASE TABLE'
GROUP BY t.table_name) AS table_rows;
