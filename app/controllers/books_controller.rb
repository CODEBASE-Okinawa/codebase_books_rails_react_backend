class BooksController < ApplicationController
  before_action :redirect_to_admin_books, only: [:index]
  before_action :authenticate_user!, only: [:show]
  
  def index
    books = Book.eager_load(:reservation_active, :lend_active).with_attached_image.order(:id)
    render json: books
  end

  def show
    @book = Book.find(params[:id])
    lending = @book.lendings.where(return_status: false, user_id: current_user.id).first
    # redirect_to lending
    return render json: lending if lending
    reservation = @book.reservations.where("reservation_at >= ?", Time.now).where(user_id: current_user.id).first
    # redirect_to reservation_path(reservation)
    return render json: reservation if reservation

    @reservations = @book.reservations.where("reservation_at >= ?", Time.now).order(reservation_at: :asc)
    render json: {
      "book" => @book,
      "reservations" => @reservations
    }
  end

  private

  def redirect_to_admin_books
    return unless current_user&.admin?

    redirect_to admin_books_path
  end

end
