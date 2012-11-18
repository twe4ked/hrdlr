require 'items'

class Track
  attr_reader :hurdles, :coins, :dino_ups

  def initialize
    @hurdles = Items.new 50, 10..20
    @coins = Items.new 75, 20..50
    @dino_ups = Items.new 500, 500..1000
  end
end
