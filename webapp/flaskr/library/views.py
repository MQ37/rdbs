from flask import (
    render_template,
    request,
    redirect,
    url_for,
)

from webapp.flaskr.library import bp
from webapp.flaskr.db import db

from .models import Book, Author, Genre, ShelfBook, Borrowing


@bp.route("/")
def index_view():
    books = db.session.execute(db.select(Book)).scalars()

    return render_template("library/index.html", books=books)


@bp.route("/books/")
def books_view():
    books = db.session.execute(db.select(Book).order_by(Book.name)).scalars()

    return render_template("library/books.html", books=books)


@bp.route("/books/<pk>")
def books_detail_view(pk):
    if not pk or not pk.isdigit():
        return redirect(url_for("library.books_view"))

    book = db.session.get(Book, pk)

    return render_template("library/books_detail.html", book=book)


@bp.route("/authors/")
def authors_view():
    authors = db.session.execute(db.select(Author).order_by(
        Author.name)).scalars()

    return render_template("library/authors.html", authors=authors)


@bp.route("/authors/<pk>")
def authors_detail_view(pk):
    if not pk or not pk.isdigit():
        return redirect(url_for("library.authors_view"))

    author = db.session.get(Author, pk)
    books = author.books

    return render_template("library/authors_detail.html",
                           author=author,
                           books=books)


@bp.route("/genres/")
def genres_view():
    genres = db.session.execute(db.select(Genre).order_by(
        Genre.genre)).scalars()

    return render_template("library/genres.html", genres=genres)


@bp.route("/genres/<pk>")
def genres_detail_view(pk):
    if not pk or not pk.isdigit():
        return redirect(url_for("library.genres_view"))

    genre = db.session.get(Genre, pk)
    books = genre.books

    return render_template("library/genres_detail.html",
                           genre=genre,
                           books=books)


@bp.route("/search")
def search_view():
    q = request.args.get("q")
    books = None
    if q:
        sql = db.select(Book).where(Book.name.ilike("%%%s%%" % q)).order_by(
            Book.name)
        books = db.session.execute(sql).scalars()

    return render_template("library/search.html", books=books)


@bp.route("/shelfbooks/")
def shelfbooks_view():
    sba = db.orm.aliased(ShelfBook)
    borrowed = db.select(Borrowing.shelfbook_id).where(Borrowing.returned == 0)
    sql = db.select(Book.book_id, Book.name, db.func.count(sba.book_id))\
            .select_from(Book)\
            .join(sba, db.and_(
                sba.shelfbook_id.not_in(borrowed),
                sba.book_id == Book.book_id
                ), isouter=True)\
            .group_by(Book.book_id)\
            .order_by(Book.name)

    shelfbooks = db.session.execute(sql)
    return render_template("library/shelfbooks.html", shelfbooks=shelfbooks)


@bp.route("/borrowings/")
def borrowings_view():
    sbb = db.orm.aliased(ShelfBook)
    borrowed = db.select(Borrowing.shelfbook_id).where(Borrowing.returned == 0)
    sql = db.select(Book.book_id, Book.name, db.func.count(sbb.book_id))\
            .select_from(Book)\
            .join(sbb, db.and_(
                sbb.shelfbook_id.in_(borrowed),
                sbb.book_id == Book.book_id
                ), isouter=True)\
            .group_by(Book.book_id)\
            .order_by(Book.name)

    borrowings = db.session.execute(sql)
    return render_template("library/borrowings.html", borrowings=borrowings)
