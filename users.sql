-- Admin
CREATE USER 'libradmin'@'%' IDENTIFIED BY 'heslojeveslo';
GRANT ALL PRIVILEGES ON library.* TO 'libradmin'@'%';

-- Knihovnice
CREATE USER 'knihovnice'@'%' IDENTIFIED BY 'heslojeveslo';
GRANT SELECT ON library.* TO 'knihovnice'@'%';

-- Spravce knih
CREATE ROLE spravceknihrole;
GRANT INSERT, UPDATE, DELETE, SELECT ON library.Books TO spravceknihrole;
GRANT INSERT, UPDATE, DELETE, SELECT ON library.ShelfBooks TO spravceknihrole;
GRANT INSERT, UPDATE, DELETE, SELECT ON library.Authors TO spravceknihrole;
GRANT INSERT, UPDATE, DELETE, SELECT ON library.BooksAuthors TO spravceknihrole;
GRANT INSERT, UPDATE, DELETE, SELECT ON library.BooksGenres TO spravceknihrole;
GRANT INSERT, UPDATE, DELETE, SELECT ON library.Genres TO spravceknihrole;
GRANT INSERT, UPDATE, DELETE, SELECT ON library.Languages TO spravceknihrole;
CREATE USER 'spravceknih'@'%' IDENTIFIED BY 'heslojeveslo';
GRANT spravceknihrole TO 'spravceknih'@'%';
