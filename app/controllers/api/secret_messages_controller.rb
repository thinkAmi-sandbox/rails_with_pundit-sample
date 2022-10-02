class Api::SecretMessagesController < BasicAuthController
  def index
    skip_authorization # 認証OKなら誰でも見れる
    render json: SecretMessage.all
  end

  def create
    skip_authorization # 認証OKなら誰でも作れる
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