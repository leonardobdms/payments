class MerchantSerializer < ApplicationSerializer
  attributes :id, :legal_name, :document, :status

  one :account, resource: AccountSerializer
end
