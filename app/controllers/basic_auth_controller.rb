class BasicAuthController < ApplicationController
  # APIモードで作ったのでincludeが必要
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :basic_auth

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      User.exists?(name: username, password: password)
    end
  end
end