module Charges
  class Confirm
    class NotConfirmableError < StandardError; end

    def self.call(charge:)
      new(charge:).call
    end

    def initialize(charge:)
      @charge = charge
    end

    def call
      raise NotConfirmableError unless charge.confirmable?

      charge.succeed!
      charge.reload
    end

    private

    attr_reader :charge
  end
end
