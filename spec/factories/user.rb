FactoryBot.define do
  factory :user, aliases: [:owner] do
    name { 'foo' }
    password { 'password' }

    factory :chief_retainer do
      after(:create) {|user| user.add_role(:chief_retainer)}
    end

    factory :magistrate do
      after(:create) {|user| user.add_role(:magistrate)}
    end
  end
end