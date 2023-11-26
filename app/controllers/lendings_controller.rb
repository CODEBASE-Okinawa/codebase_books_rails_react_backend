class LendingsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]
  before_action :redirect_lendings, only: :show

  def index
    lendings = current_user&.lendings.not_yet_returned
    render json: lendings
  end

  def show
    @lending = Lending.find(params[:id])
    render json: @lending
  end

  def update
    lending = Lending.find(params[:id])

    if lending.update(return_status: true)
      # redirect_to book_path(lending.book)
      render json: { status: 'SUCCESS', message: '返却が完了しました', data: lending }
    else
      # render "show", status: :unprocessable_entity
      render json: { status: :unprocessable_entity, message: '返却に失敗しました', data: lending.errors }
    end
  end

  def create
    @lending = Book.find(params[:book_id]).lendings.build(lending_params(params))
    return unless @lending.save

    # redirect_to lendings_path
    render json: { status: :created, message: '貸出が完了しました', date: @lending }
  end

  private

  def lending_params(data)
    @lending_params = { book_id: data[:book_id],
                        user_id: current_user&.id,
                        return_at: data[:return_at] }
  end

  # サインインしているユーザーが借りていない本だったら、貸出一覧ページへリダイレクト
  def redirect_lendings
    if current_user&.lendings.find_by(id: params[:id]).blank?
      redirect_to lendings_path
      render json: { status: :unprocessable_entity, message: "この本は借りていません", daga: @lendings.errors }
    end
  end
end
