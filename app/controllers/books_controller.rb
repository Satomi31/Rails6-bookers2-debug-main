class BooksController < ApplicationController
  before_action :authenticate_user!
  impressionist :actions=> [:show]

  def show
    @book = Book.find(params[:id])
    impressionist(@book, nil, unique: [:session_hash])
    @book_new = Book.new
    @book_comment = BookComment.new
    @user = @book.user
    @followings = @user.followings
    @followers = @user.followers
  end

  def index
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    @books = Book.includes(:favorites).
      sort_by {|x|
        x.favorites.includes(:favorites).where(created_at: from...to).size
      }.reverse
    @book = Book.new
    @followings = current_user.followings
    @followers = current_user.followers
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
    if @book.user == current_user
      render "edit"
    else
      redirect_to books_path
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end

end
