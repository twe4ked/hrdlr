class Player
  attr_reader :x, :y, :state

  def initialize
    @x = 0
    @y = 0
    @state = 'normal'
  end

  def tick
    @x += 1
    if @jump_pos
      @jump_pos += 1
      @state = 'jump'
      if @jump_pos >= 4
        @jump_pos = nil
        @y = 0
        @state = %w[normal run][self.x % 2]
      end
    else
      @state = %w[normal run][self.x % 2]
    end
  end

  def jump
    unless @jump_pos
      @jump_pos = 0
      @y = 1
    end
  end
end
