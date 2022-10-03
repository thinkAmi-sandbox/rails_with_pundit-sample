# == Schema Information
#
# Table name: secret_messages
#
#  id          :integer          not null, primary key
#  description :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :integer
#
# Indexes
#
#  index_secret_messages_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  owner_id  (owner_id => users.id)
#
require "test_helper"

class SecretMessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
