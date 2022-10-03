class Api::SecretMessagePolicy < ApplicationPolicy
  def index?
    chief_retainer?
  end

  def create?
    chief_retainer?
  end

  def update?
    chief_retainer? && record.owner == user
  end

  private def chief_retainer?
    user.has_role? :chief_retainer
  end
end