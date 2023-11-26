class SearchesController < ApplicationController
    def index
        @result = nil
        render json: @result
    end
end
