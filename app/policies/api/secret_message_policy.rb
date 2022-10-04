class Api::SecretMessagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # 外側の Api::SecretMessagePolicy の chief_retainer? は参照できない
      if user.has_role? :chief_retainer
        scope.all
      else
        scope.joins(:authors).where(authors: {user: user})
      end
    end
  end

  def index?
    chief_retainer? || magistrate?
  end

  def create?
    chief_retainer?
  end

  def update?
    author? && (chief_retainer? || magistrate?)
  end

  private def chief_retainer?
    user.has_role? :chief_retainer
  end

  private def magistrate?
    user.has_role? :magistrate
  end

  private def author?
    record.authors.exists?(user: user)
  end
end