from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, VARCHAR, SMALLINT
from sqlalchemy import Table
from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.orm import Session
from sqlalchemy import select, insert, update, delete

engine = create_engine('mysql+mysqlconnector://root:toor@127.0.0.1:3306/library')
Base = declarative_base()

class Author(Base):
    __tablename__ = 'Authors'

    author_id = Column(Integer, primary_key=True)
    name = Column(VARCHAR(64), nullable=False)
    born = Column(SMALLINT, nullable=False)
    died = Column(SMALLINT, nullable=True)

    books = relationship("Book", back_populates="authors", secondary="BooksAuthors")

class Book(Base):
    __tablename__ = 'Books'

    book_id = Column(Integer, primary_key=True)
    lang_id = Column(ForeignKey("Languages.lang_id"), nullable=False)
    name = Column(VARCHAR(128), nullable=False)
    released = Column(SMALLINT, nullable=True)

    authors = relationship("Author", back_populates="books", secondary="BooksAuthors")
    genres = relationship("Genre", back_populates="books", secondary="BooksGenres")
    language = relationship("Language", back_populates="books")


bookaut = Table(
    "BooksAuthors",
    Base.metadata,
    Column("author_id", ForeignKey("Authors.author_id"), primary_key=True),
    Column("book_id", ForeignKey("Books.book_id"), primary_key=True),
)

class Genre(Base):
    __tablename__ = 'Genres'

    genre_id = Column(Integer, primary_key=True)
    genre = Column(VARCHAR(64), nullable=False)

    books = relationship("Book", back_populates="genres", secondary="BooksGenres")

bookgen = Table(
    "BooksGenres",
    Base.metadata,
    Column("genre_id", ForeignKey("Genres.genre_id"), primary_key=True),
    Column("book_id", ForeignKey("Books.book_id"), primary_key=True),
)

class Language(Base):
    __tablename__ = 'Languages'

    lang_id = Column(Integer, primary_key=True)
    lang = Column(VARCHAR(64), nullable=False)

    books = relationship("Book", back_populates="language")

if __name__ == "__main__":
    with Session(engine) as sess:
        # Insert
        autor = sess.get(Author, 1)
        lang = sess.get(Language, 1)
        book = Book(name="Pán prstenů Vol. X", language=lang)
        book.authors.append(autor)
        sess.commit()

        # Select
        sql = select(Book)
        books = sess.execute(sql).scalars()
        for book in books:
            print(book.name)
            print(book.language.lang)
            for aut in book.authors:
                print(aut.name)
            for gen in book.genres:
                print(gen.genre)
            print("-------------------")



