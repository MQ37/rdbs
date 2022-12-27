from flask import Blueprint

bp = Blueprint('library',
               __name__,
               template_folder="templates",
               url_prefix='/library')

# Register views
from . import views
