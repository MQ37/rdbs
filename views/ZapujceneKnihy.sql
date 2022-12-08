CREATE VIEW ZapujceneKnihy AS
SELECT bk.name AS "Název knihy", b.shelfbook_id AS "ID knihy", b.borrowed_at AS "Zapůjčeno", u.first_name AS "Jméno", u.last_name AS "Přijmení", u.user_id AS "ID uživatele"
FROM Borrowings b
INNER JOIN ShelfBooks sb
ON b.shelfbook_id = sb.shelfbook_id
INNER JOIN Books bk
ON sb.book_id = bk.book_id
INNER JOIN Users u
ON b.user_id = u.user_id
WHERE b.returned = 0;
