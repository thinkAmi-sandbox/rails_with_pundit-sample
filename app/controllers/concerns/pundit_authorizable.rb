module PunditAuthorizable
  extend ActiveSupport::Concern

  include Pundit::Authorization

  included do
    after_action :verify_authorized
  end

  # namespace付きのpolicyを探せるようにする
  def authorize(record, query = nil)
    super([:api, record], query)
  end
end
