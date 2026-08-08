# frozen_string_literal: true

MoneyRails.configure do |config|
  config.default_currency = :brl
end

Money.default_currency = Money::Currency.new(:brl)
