from webapp.flaskr.db import db


class Author(db.Model):
    __tablename__ = 'Authors'

    author_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), nullable=False)
    born = db.Column(db.Integer, nullable=False)
    died = db.Column(db.Integer, nullable=True)

    books = db.relationship("Book",
                            back_populates="authors",
                            secondary="BooksAuthors")


class Book(db.Model):
    __tablename__ = 'Books'

    book_id = db.Column(db.Integer, primary_key=True)
    lang_id = db.Column(db.ForeignKey("Languages.lang_id"), nullable=False)
    name = db.Column(db.String(128), nullable=False)
    released = db.Column(db.Integer, nullable=True)

    authors = db.relationship("Author",
                              back_populates="books",
                              secondary="BooksAuthors")
    genres = db.relationship("Genre",
                             back_populates="books",
                             secondary="BooksGenres")
    language = db.relationship("Language", back_populates="books")
    shelfbooks = db.relationship("ShelfBook", back_populates="book")


bookaut = db.Table(
    "BooksAuthors",
    db.Column("author_id",
              db.ForeignKey("Authors.author_id"),
              primary_key=True),
    db.Column("book_id", db.ForeignKey("Books.book_id"), primary_key=True),
)


class Genre(db.Model):
    __tablename__ = 'Genres'

    genre_id = db.Column(db.Integer, primary_key=True)
    genre = db.Column(db.String(64), nullable=False)

    books = db.relationship("Book",
                            back_populates="genres",
                            secondary="BooksGenres")


bookgen = db.Table(
    "BooksGenres",
    db.Column("genre_id", db.ForeignKey("Genres.genre_id"), primary_key=True),
    db.Column("book_id", db.ForeignKey("Books.book_id"), primary_key=True),
)


class Language(db.Model):
    __tablename__ = 'Languages'

    lang_id = db.Column(db.Integer, primary_key=True)
    lang = db.Column(db.String(64), nullable=False)

    books = db.relationship("Book", back_populates="language")


class ShelfBook(db.Model):
    __tablename__ = 'ShelfBooks'

    shelfbook_id = db.Column(db.Integer, primary_key=True)
    book_id = db.Column(db.ForeignKey("Books.book_id"), nullable=False)
    stocked_at = db.Column(db.Date, nullable=False)

    book = db.relationship("Book", back_populates="shelfbooks")
    borrowings = db.relationship("Borrowing", back_populates="shelfbook")


class User(db.Model):
    __tablename__ = 'Users'

    user_id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(32), nullable=False)
    last_name = db.Column(db.String(32), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False)

    borrowings = db.relationship("Borrowing", back_populates="user")


class Borrowing(db.Model):
    __tablename__ = 'Borrowings'

    bor_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.ForeignKey("Users.user_id"), nullable=False)
    shelfbook_id = db.Column(db.ForeignKey("ShelfBooks.book_id"),
                             nullable=False)
    borrowed_at = db.Column(db.Date, nullable=False)
    returned = db.Column(db.Integer, nullable=False)

    shelfbook = db.relationship("ShelfBook", back_populates="borrowings")
    user = db.relationship("User", back_populates="borrowings")
