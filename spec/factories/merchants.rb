FactoryBot.define do
  factory :merchant do
    user
    legal_name { Faker::Company.name }
    document { user.cpf.gsub(/\D/, "") }

    trait :with_balances do
      after(:create) do |merchant|
        merchant.account.update!(
          available_balance_cents: 10_00,
          pending_balance_cents: 5_00
        )
      end
    end
  end
end
