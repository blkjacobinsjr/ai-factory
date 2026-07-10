# Handles every browser request about bookmarks. Each public method below
# answers one URL (see config/routes.rb). Kept deliberately thin: it fetches
# or saves records and picks what to show next — all data rules live in the
# Bookmark model, so nothing here can bypass them.
class BookmarksController < ApplicationController
  # GET / — the homepage: list every saved bookmark, newest first so a
  # just-added bookmark is visible at the top without scrolling.
  def index
    @bookmarks = Bookmark.order(created_at: :desc)
  end

  # GET /bookmarks/new — show an empty form.
  def new
    @bookmark = Bookmark.new
  end

  # POST /bookmarks — try to save what the form submitted.
  # Valid: back to the homepage where the new link now shows.
  # Invalid: redraw the form with the error messages, keeping what was typed.
  # (422 status tells Turbo/browsers "this submission failed".)
  def create
    @bookmark = Bookmark.new(bookmark_params)
    if @bookmark.save
      redirect_to root_url, notice: "Bookmark added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /bookmarks/:id/edit — form pre-filled with the existing bookmark.
  def edit
    @bookmark = Bookmark.find(params[:id])
  end

  # PATCH /bookmarks/:id — apply the edited fields.
  # Same success/failure split as create: home on success, redraw with
  # errors on invalid input (e.g. blanking the title).
  def update
    @bookmark = Bookmark.find(params[:id])
    if @bookmark.update(bookmark_params)
      redirect_to root_url, notice: "Bookmark updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Only title and url may come in from the outside. Without this whitelist,
  # a crafted request could set any column (mass assignment attack).
  def bookmark_params
    params.require(:bookmark).permit(:title, :url)
  end
end
