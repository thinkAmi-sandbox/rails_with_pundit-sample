class Api::SecretMessagePolicy < ApplicationPolicy
  def index?
    chief_retainer?
  end

  def create?
    chief_retainer?
  end

  def update?
    author?
  end

  private def chief_retainer?
    user.has_role? :chief_retainer
  end

  private def author?
    chief_retainer? && record.authors.exists?(user: user)
  end
end