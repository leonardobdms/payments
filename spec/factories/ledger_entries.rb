FactoryBot.define do
  factory :ledger_entry do
    account { association(:merchant).account }
    charge
    entry_type { "charge_credit" }
    direction { "credit" }
    amount_cents { 10_00 }
    currency { "BRL" }
    balance_bucket { "available" }
    description { "Charge credit" }
  end
end
