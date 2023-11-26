class RequestBooksController < ApplicationController
    # include Book
    def search
        word = URI.encode_www_form_component(params[:word])
        @result = GoogleBooksApi.search_by_word(word)
        
        if @result["totalItems"] == 0
            # redirect_to searches_path
            render json: { status: 'SUCCESS', message: '本が見つかりませんでした', data: @result }
        else
            @books = []
            @result["items"].each do |item|
                if item["volumeInfo"].include?("industryIdentifiers")
                    @books.push(item)
                end
            end
            @items = RequestBook.new
            @requests = RequestBook.all
            @have_books = Book.eager_load(:lending)
            @request_now = RequestBook.where(status: "true")
            #template: "searches/index"
            render json: { status: 'SUCCESS', message: '本が見つかりました', 
                data: {
                    @books,
                    @requests,
                    @hove_books,
                    @result
                    } }
        end
    end

    def create
        @items = RequestBook.new(book_params)
        
        if @items.save
            flash[:success] = "#{@items["title"]}をリクエストしました"
            # redirect_to searches_path
            render json: { status: 'SUCCESS', message: '本をリクエストしました。', data: @items }
        else
            # render template: "searches/index"
            render json: { status: :unprocessable_entity, message: 'リクエストに失敗しました。', data: @items.errors }
        end
    end

    def update
        render json: @request
    end

    private

    def book_params
        params.permit(:title, :author, :image, :isbn)
    end

end
