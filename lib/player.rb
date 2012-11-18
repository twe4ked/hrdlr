class Player
  attr_reader :track, :x, :y, :state
  attr_reader :score, :high_score
  attr_reader :multi_coin, :coin_count, :coin_multiplier
  attr_reader :dino_count

  def initialize(track)
    @track = track
    @x = 0
    @y = 0
    @state = 'normal'
    @score = 0
    @high_score = 0
    @score_start = 0
    @coin_count = 0
    @dino_count = nil
    @coin_multiplier = 1
  end

  def tick
    tick_jump_pos
    tick_dino_rampage
    tick_hurdles
    tick_multi_coin
    tick_x_pos
    tick_state
    tick_score
  end

  def tick_multi_coin
    @multi_coin = false
    coins = self.current_coins
    unless coins.empty?
      if jumping? || @dino_count
        track.coins.delete *coins
        @coin_count += coins.size
        if @coin_count % 5 == 0
          @score += coins.size*5
          Sound.play('multi_coin')
          @multi_coin = true
          @coin_multiplier += 1
        else
          @score += coins.size * @coin_multiplier
          Sound.play('coin_get')
        end
      else
        @coin_count = 0
      end
    end
  end

  def tick_state
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
    when @dino_count && @dino_count > 80
      %w[normal hidden run hidden][@dino_count/2 % 4]
    else
      %w[normal normal run run][self.x % 4]
    end

    if @dino_fire
      @state = "#{@state}_fire"
      @dino_fire = nil
    end
  end

  def tick_dino_rampage
    dino_ups = self.current_dino_ups
    if (jumping? || @dino_count) && !dino_ups.empty?
      track.dino_ups.delete *dino_ups
      @dino_count = 0
      @jump_pos = nil
      Sound.play('dino_rampage')
    end
    if @dino_count
      if (0..100).cover?(@dino_count.to_i)
        @dino_count += 1
      else
        @dino_count = nil
        @dino_fire = nil
      end
    end
  end

  def tick_hurdles
    hurdles = current_hurdles
    case
    when @falling_pos && @falling_pos < 16
      @falling_pos += 1
      @x += 1 if @falling_pos < 5
    when !@falling_pos && !jumping? && !hurdles.empty?
      if @dino_count
        track.hurdles.delete *hurdles
        @score += 1
      else
        @falling_pos = 0
        @x += 1
        @high_score = [@high_score, @score].max
        @score = 0
        @coin_count = 0
        @coin_multiplier = 1
        Sound.play('splat')
      end
    else
      @falling_pos = nil
      @score_end = @x
    end
  end

  def jump
    if @dino_count
      @dino_fire = true
      @jump_pos = nil
      @y = 0
    else
      unless @jump_pos || @falling_pos
        Sound.play('jump')
        @jump_pos = 0
        @y = 1
      end
    end
  end

  def tick_x_pos
    @x += 1 unless @falling_pos
    @x += 1 if @dino_count
  end

  def tick_jump_pos
    if @jump_pos && @jump_pos < 4
      @jump_pos += 1
    else
      @jump_pos = nil
      @y = 0
    end
  end

  def jumping?
    !!@jump_pos
  end

  def width
    @@width ||= Sprite.player_run.split("\n").last.size
  end

  def dino_width_head
    @@dino_width_head ||= Sprite.dino_normal.split("\n").first.size
  end

  def dino_width_feet
    @@dino_width_feet ||= Sprite.dino_normal.split("\n").last.size
  end

  def hit_range
    self.x+1...self.x+self.width
  end

  def current_hurdles
    range = if @dino_count
      self.x+2..self.x+self.dino_width_feet
    else
      self.x+2..self.x+self.width
    end
    track.hurdles.get(range)
  end

  def current_coins
    range = if @dino_count
      self.x+1..self.x+1+self.dino_width_head
    else
      self.x+1..self.x+1
    end
    track.coins.get(range)
  end

  def current_dino_ups
    range = self.x+1..self.x+1
    track.dino_ups.get(range)
  end

  def tick_score
    old_score = @score
    @score += self.track.hurdles.get(@score_start..@score_end).size
    @score_start = @x
    if @score == @high_score + 1 && @high_score != 0 && @score != old_score
      Sound.play('high_score')
    end
  end
end
