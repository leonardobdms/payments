module Payments
  class MockProvider
    PROVIDER_NAME = "mock"

    def initialize(charge)
      @charge = charge
    end

    def initiate!
      charge.mark_processing!(provider_ref: provider_ref)
      charge.update!(metadata: charge.metadata.merge(provider_payload))

      succeed_card_charge! if charge.card?
      charge
    end

    private

    attr_reader :charge

    def provider_ref
      "mock_#{charge.public_id}"
    end

    def provider_payload
      if charge.pix?
        {
          "mock_pix" => {
            "copy_paste" => "00020126580014BR.GOV.BCB.PIX0136#{SecureRandom.hex(12)}",
            "expires_in" => 3600
          }
        }
      else
        {
          "mock_card" => {
            "authorization_code" => SecureRandom.hex(4).upcase
          }
        }
      end
    end

    def succeed_card_charge!
      charge.succeed!
    end
  end
end
