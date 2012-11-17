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
      if @jump_pos < 4
        @jump_pos += 1
      else
        @jump_pos = nil
        @y = 0
      end
    end

    @state = case
    when @jump_pos
      'jump'
    else
      %w[normal normal run run][self.x % 4]
    end
  end

  def jump
    unless @jump_pos
      @jump_pos = 0
      @y = 1
    end
  end
end
