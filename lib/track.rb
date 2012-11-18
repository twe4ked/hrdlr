require 'items'

class Track
  attr_reader :hurdles, :coins

  def initialize
    @hurdles = Items.new 50, 10..20
    @coins = Items.new 75, 20..50
  end
end
