class AccountSerializer < ApplicationSerializer
  attributes :currency, :available_balance_cents, :pending_balance_cents
end
