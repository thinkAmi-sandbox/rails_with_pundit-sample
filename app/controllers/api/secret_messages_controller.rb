class Api::SecretMessagesController < BasicAuthController
  def index
    authorize SecretMessage

    render json: SecretMessage.all
  end

  def create
    authorize SecretMessage

    SecretMessage.create(create_params)

    render status: :created
  end

  def update
    record = SecretMessage.find_by(id: params[:id])
    authorize record

    SecretMessage.update(update_params)

    render status: :no_content
  end

  private def create_params
    params.permit(:title, :description).merge(owner: current_user)
  end

  private def update_params
    params.permit(:id, :title, :description)
  end
end