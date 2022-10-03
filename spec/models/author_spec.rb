# == Schema Information
#
# Table name: authors
#
#  id                :integer          not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  secret_message_id :integer          not null
#  user_id           :integer
#
# Indexes
#
#  index_authors_on_secret_message_id  (secret_message_id)
#  index_authors_on_user_id            (user_id)
#
# Foreign Keys
#
#  secret_message_id  (secret_message_id => secret_messages.id)
#  user_id            (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Author, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
