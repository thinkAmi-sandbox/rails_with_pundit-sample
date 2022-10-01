class Api::SecretMessagesController < ApplicationController
  def index
    render json: SecretMessage.all
  end

  def create
    SecretMessage.create(create_params)
  end

  private def create_params
    params.permit(:title, :description)
  end
end