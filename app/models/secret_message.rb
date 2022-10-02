# == Schema Information
#
# Table name: secret_messages
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :integer
#
class SecretMessage < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
end
