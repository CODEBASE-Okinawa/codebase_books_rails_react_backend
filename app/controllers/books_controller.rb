class BooksController < ApplicationController
  before_action :redirect_to_admin_books, only: [:index]
  before_action :logged_in_user, only: %i[index show]
  before_action :redirect_to_reservation_lending_show, only:[:show]
  def index
    @books = Book.all
    @reservations = Reservation.all
    @lendings = Lending.all
  end

  def show
    @reservations = @book.reservations.where("reservation_at >= ?", Time.now).order(reservation_at: :asc)
  end

  private

  def redirect_to_admin_books
    return unless current_user&.admin?

    redirect_to admin_books_path
  end

  def redirect_to_reservation_lending_show
    @book = Book.find(params[:id])
    if @book.reservations.where("reservation_at >= ?", Time.now).exists?(user_id: current_user.id)
      redirect_to reservation_path(@book.reservations.find_by(user_id: current_user.id))
    elsif @book.lendings.exists?(return_status: false, user_id: current_user.id)
      redirect_to lending_path(@book.lendings.find_by(return_status: false, user_id: current_user.id))
    end
  end

  def logged_in_user
    return unless current_user.nil?
    
    #現在アクセスしているページのurlを記憶
    session[:request] = nil
    session[:request] = request.original_url
    
    flash[:failed] = "ログインしてください"
    redirect_to new_user_session_path, status: :see_other
  end
end
