class Api::SecretMessagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.has_role? :chief_retainer
        return scope.all
      end

      # 一つ目のwhere: 自分がauthor
      # or以降: 同じ派閥の家老がauthor
      scope.joins(authors: [user: :faction])
           .where(authors: {users: user})
           .or(scope.joins(authors: [user: :faction]).where(
             authors: {
              users: {
                id: User.with_role(:chief_retainer).select(:id),
                factions: {
                  id: user.faction.id
                }
              }
            }
           ))
           .distinct # 1つのsecret_messagesに対しfactionが等しいauthorが複数いる時のためdistinctする

      # => to_sqlした結果
      # SELECT
      #     DISTINCT "secret_messages".*
      # FROM
      #     "secret_messages"
      #     INNER JOIN "authors" ON "authors"."secret_message_id" = "secret_messages"."id"
      #     INNER JOIN "users" ON "users"."id" = "authors"."user_id"
      #     INNER JOIN "factions" ON "factions"."id" = "users"."faction_id"
      # WHERE
      #     (
      #         "authors"."user_id" = 1
      #         OR "users"."id" IN (
      #             SELECT
      #                 "users"."id"
      #             FROM
      #                 "users"
      #                 INNER JOIN "users_roles" ON "users_roles"."user_id" = "users"."id"
      #                 INNER JOIN "roles" ON "roles"."id" = "users_roles"."role_id"
      #             WHERE
      #                 (
      #                     (
      #                         (roles.name = 'chief_retainer')
      #                         AND (roles.resource_type IS NULL)
      #                         AND (roles.resource_id IS NULL)
      #                     )
      #                 )
      #         )
      #         AND "factions"."id" = 1
      #     )
    end
  end

  def index?
    chief_retainer? || magistrate? || belonging_to_faction?
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

  private def magistrate_author?
    # 直接&&するとfalseが返ってくるので、一時変数に入れて&&する
    x = user.has_role? :magistrate
    y = record.joins(authors: [:user]).exists?(authors: { users: { id: user.id } })

    x && y
  end

  private def belonging_to_faction?
    user.faction.present?
  end
end
