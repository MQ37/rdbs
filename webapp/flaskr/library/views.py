from flask import (
    render_template,
    request,
    redirect,
    url_for,
)

from webapp.flaskr.library import bp
from webapp.flaskr.db import db

from .models import Book, Author, Genre


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
