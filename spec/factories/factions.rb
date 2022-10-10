# == Schema Information
#
# Table name: factions
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :faction do
    name { "MyString" }
  end
end
