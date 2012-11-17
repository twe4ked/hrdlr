require 'items'

class Track
  attr_reader :hurdles

  def initialize
    @hurdles = Items.new 50, 10..20
  end
end
