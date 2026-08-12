class ChargeSerializer < ApplicationSerializer
  attributes :public_id,
    :amount_cents,
    :currency,
    :status,
    :payment_method,
    :provider,
    :provider_ref,
    :description,
    :customer_email,
    :customer_document,
    :metadata,
    :succeeded_at,
    :failed_at,
    :canceled_at,
    :created_at
end
