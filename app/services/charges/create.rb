module Charges
  class Create
    class MerchantInactiveError < StandardError
      def initialize
        super("merchant is not active")
      end
    end

    def self.call(merchant:, params:)
      new(merchant:, params:).call
    end

    def initialize(merchant:, params:)
      @merchant = merchant
      @params = params
    end

    def call
      raise MerchantInactiveError unless merchant.active?

      charge = nil

      ActiveRecord::Base.transaction do
        charge = merchant.charges.create!(charge_attributes)
        Payments::MockProvider.new(charge).initiate!
      end

      charge.reload
    end

    private

    attr_reader :merchant, :params

    def charge_attributes
      {
        amount_cents: params.fetch(:amount_cents),
        currency: params.fetch(:currency, "BRL"),
        payment_method: params.fetch(:payment_method),
        description: params[:description],
        customer_email: params[:customer_email],
        customer_document: params[:customer_document],
        metadata: params[:metadata].presence || {}
      }
    end
  end
end
