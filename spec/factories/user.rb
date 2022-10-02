FactoryBot.define do
  factory :user, aliases: [:owner] do
    name { 'foo' }
    password { 'password' }
  end
end