class Player
  attr_reader :track, :x, :y, :state
  attr_reader :score, :high_score

  def initialize(track)
    @track = track
    @x = 0
    @y = 0
    @state = 'normal'
    @score = 0
    @high_score = 0
    @score_start = 0
  end

  def tick
    if @jump_pos
      if @jump_pos < 4
        @jump_pos += 1
      else
        @jump_pos = nil
        @y = 0
      end
    end

    case
    when @falling_pos && @falling_pos < 16
      @falling_pos += 1
      @x += 1 if @falling_pos < 5
    when !@falling_pos && will_collide?
      @falling_pos = 0
      @x += 1
      @score_start = @x+self.width
      @high_score = [@high_score, @score].max
      @score = 0
      Sound.play('splat')
    else
      @falling_pos = nil
    end

    unless @falling_pos
      @x += 1
    end

    @state = case
    when @jump_pos
      'jump'
    when @falling_pos == 0
      'falling'
    when @falling_pos && @falling_pos > 12
      %w[normal hidden][@falling_pos % 2]
    when @falling_pos && @falling_pos > 8
      %w[recover hidden][@falling_pos % 2]
    when @falling_pos
      'fallen'
    else
      %w[normal normal run run][self.x % 4]
    end

    update_score
  end

  def jump
    unless @jump_pos || @falling_pos
      Sound.play('jump')
      @jump_pos = 0
      @y = 1
    end
  end

  def jumping?
    !!@jump_pos
  end

  def width
    @@width ||= Sprite.player_run.split("\n").last.size
  end

  def hit_range
    self.x+1...self.x+self.width
  end

  def will_collide?
    range = self.x+2..self.x+self.width
    !jumping? && !track.get_hurdles(range).empty?
  end

  def update_score
    old_score = @score
    @score = self.track.get_hurdles(@score_start..@x).size
    if @score == @high_score + 1 && @high_score != 0 && @score != old_score
      Sound.play('high_score')
    end
  end
end
