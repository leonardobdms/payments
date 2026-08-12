FactoryBot.define do
  factory :charge do
    merchant
    amount_cents { 10_00 }
    currency { "BRL" }
    status { "pending" }
    payment_method { "pix" }
    provider { "mock" }
    metadata { {} }

    trait :processing do
      status { "processing" }
      provider_ref { "mock_#{SecureRandom.hex(8)}" }
    end

    trait :succeeded do
      status { "succeeded" }
      provider_ref { "mock_#{SecureRandom.hex(8)}" }
      succeeded_at { Time.current }
    end

    trait :card do
      payment_method { "card" }
    end
  end
end
