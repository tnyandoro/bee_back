module Api
    module V1
      class SessionsController < ApplicationController
        def create
          # Authentication logic here
          render json: { message: 'Logged in successfully' }, status: :ok
        end
  
        def destroy
          # Logout logic here
          render json: { message: 'Logged out successfully' }, status: :ok
        end
      end
    end
end 
