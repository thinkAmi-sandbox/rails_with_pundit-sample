class Api::SecretMessagePolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    true
  end

  def update?
    record.owner == user
  end
end