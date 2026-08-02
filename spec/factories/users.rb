FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    cpf { Faker::IdNumber.brazilian_cpf }
    name { Faker::Name.name }
    password { Faker::Internet.password(min_length: 8) }
    password_confirmation { password }
  end
end
