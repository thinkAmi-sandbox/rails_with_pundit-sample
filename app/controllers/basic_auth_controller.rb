class BasicAuthController < ApplicationController
  attr_reader :current_user

  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # APIモードで作ったのでincludeが必要
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :basic_auth

  # basic_authの後に PunditAuthorizable 内の before/after が動いてほしいので
  # この位置でinclude
  include PunditAuthorizable

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      @current_user = User.find_by(name: username, password: password)

      @current_user.present?
    end
  end

  private def user_not_authorized
    render status: :forbidden
  end
end