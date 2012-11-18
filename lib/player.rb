class Player
  attr_reader :track, :x, :y, :state
  attr_reader :score, :high_score
  attr_reader :multi_coin, :coin_count

  def initialize(track)
    @track = track
    @x = 0
    @y = 0
    @state = 'normal'
    @score = 0
    @high_score = 0
    @score_start = 0
    @coin_count = 0
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
      @high_score = [@high_score, @score].max
      @score = 0
      @coin_count = 0
      Sound.play('splat')
    else
      @falling_pos = nil
      @score_end = @x
    end

    @multi_coin = false
    coins = self.current_coins
    unless coins.empty?
      if jumping?
        track.coins.delete *coins
        @coin_count += coins.size
        if @coin_count % 5 == 0
          @score += coins.size*5
          Sound.play('multi_coin')
          @multi_coin = true
        else
          @score += coins.size
          Sound.play('coin_get')
        end
      else
        @coin_count = 0
      end
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
    !jumping? && !track.hurdles.get(range).empty?
  end

  def current_coins
    range = self.x+1..self.x+1
    track.coins.get(range)
  end

  def update_score
    old_score = @score
    @score += self.track.hurdles.get(@score_start..@score_end).size
    @score_start = @x
    if @score == @high_score + 1 && @high_score != 0 && @score != old_score
      Sound.play('high_score')
    end
  end
end
