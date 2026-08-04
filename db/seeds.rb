# frozen_string_literal: true

# Development-only demo data. Re-running +db:seed+ is safe (find-or-create by natural keys).
return unless Rails.env.development?

password = ENV.fetch("SEED_USER_PASSWORD", "password123")

demo_user = User.find_or_create_by!(email: "dev@payments.local") do |user|
  user.name = "Dev User"
  user.cpf = "52998224725"
  user.password = password
  user.password_confirmation = password
end

primary_merchant = demo_user.merchants.find_or_create_by!(document: "11222333000181") do |merchant|
  merchant.legal_name = "Acme Pagamentos LTDA"
end

secondary_merchant = demo_user.merchants.find_or_create_by!(document: "54550752000155") do |merchant|
  merchant.legal_name = "Dev Demo LTDA"
end

primary_merchant.account.update!(
  available_balance_cents: 150_00,
  pending_balance_cents: 25_00
)

puts "Seed complete (development)."

puts "User: dev@payments.local"
puts "Password: SEED_USER_PASSWORD env or default password123"
puts "Merchants: #{primary_merchant.legal_name}, #{secondary_merchant.legal_name}"
