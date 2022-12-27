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
