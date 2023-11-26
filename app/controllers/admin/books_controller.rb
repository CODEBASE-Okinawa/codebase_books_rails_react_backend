class Admin::BooksController < ApplicationController
  before_action :check_admin
  helper_method :registered_book?

  def index
    @books = Book.eager_load(:lending).with_attached_image.order(:id)
    render json: @books
  end

  def new
    @book = Book.new
    render json: @book
  end

  def create
    @book = Book.new(book_params)
    @book.image.attach(params[:book][:image])
    if @book.save
      # redirect_to admin_books_path
      render json: { status: "SUCCESS", message: '本を登録しました', data: @book }
    else
      # render 'new', status: :unprocessable_entity
      render json: { status: :unprocessable_entity, data: @book.errors }
    end
  end

  def search
    @result = GoogleBooksApi.search_by_isbn(params[:isbn])
    if @result["totalItems"] == 0
      # redirect_to new_admin_book_path
      render json: { status: 'SUCCESS', message: '本が見つかりませんでした', data: @result }
    else
      @result
      # render 'new'
      render json: @result
    end
  end

  def search_registration
    Book.create!(
      title: params[:title],
      isbn: params[:isbn],
      image_url: params[:image_url]
    )
    flash[:success] = "本を登録しました"
    # redirect_to admin_books_path
    render json: { status: 'SUCCESS', message: '本を登録しました' }
  end

  private

  def book_params
    params.require(:book).permit(:title, :image)
  end

  def registered_book?
    Book.exists?(isbn: @result["items"][0]["volumeInfo"]["industryIdentifiers"][1]["identifier"].to_i)
  end
end
