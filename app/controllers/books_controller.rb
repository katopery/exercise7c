class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_book, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    
    # DM機能用
    @current_entry = Entry.where(user_id: current_user.id)
    @another_entry = Entry.where(user_id: @book.user.id)
    
    unless @book.user.id == current_user.id
      @current_entry.each do |current|
        @another_entry.each do |another|
          if current.room_id == another.room_id
            @is_room = true
            @room_id = current.room_id
          end
        end
      end
      unless @is_room == true 
        @room = Room.new
        @entry = Entry.new
      end
    end
    
    read_count = ReadCount.new(book_id: @book.id, user_id: current_user.id)
    read_count.save
  end

  def index
    @book = Book.new
    current_time = Time.current.at_end_of_day
    past_time = (current_time - 6.day).at_beginning_of_day
    @books = Book.includes(:favorited_users)
               .sort_by { |book|
                book.favorited_users.includes(:favorites)
                                      .where(created_at: past_time...current_time)
                                      .size
               }.reverse
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
  
  def ensure_correct_book
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end
end
