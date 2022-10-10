# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string
#  password   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  faction_id :integer
#
# Indexes
#
#  index_users_on_faction_id  (faction_id)
#
# Foreign Keys
#
#  faction_id  (faction_id => factions.id)
#
class User < ApplicationRecord
  rolify

  has_many :authors
  belongs_to :faction, optional: true
end
