require "test_helper"

class QuantityFormatTest < ActiveSupport::TestCase
  test "quantities and dates are formatted once, on the server" do
    assert_equal "4,000 kg", QuantityFormat.amount(BigDecimal("4000"), "kg")
    assert_equal "8.05 km/h", QuantityFormat.amount(BigDecimal("8.05"), "km/h")
    assert_equal "90°", QuantityFormat.amount(BigDecimal("90.0"), "°")
    assert_equal "11,359 J", QuantityFormat.amount(11_359, "J")
    assert_equal "1,234,567.5 kg", QuantityFormat.amount(BigDecimal("1234567.50"), "kg")
    assert_equal "21 Nov 2026", QuantityFormat.date(Date.new(2026, 11, 21))
  end
end
