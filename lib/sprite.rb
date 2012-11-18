class Sprite
  def self.player_normal
    <<-SPRITE.gsub(/^ {4}/, '')
     o
    <|-
    / >
    SPRITE
  end

  def self.player_run
    <<-SPRITE.gsub(/^ {4}/, '')
     o
    /|~
    --\\
    SPRITE
  end

  def self.player_jump
    <<-SPRITE.gsub(/^ {4}/, '')
     o/
    /|
    ---
    SPRITE
  end

  def self.player_falling
    <<-SPRITE.gsub(/^ {4}/, '')
       o
     </_
    //
    SPRITE
  end

  def self.player_fallen
    <<-SPRITE.gsub(/^ {4}/, '')


    \\_\\_o
    SPRITE
  end

  def self.player_recover
    <<-SPRITE.gsub(/^ {4}/, '')
      o
    </-
    /|
    SPRITE
  end

  def self.player_hidden
    ''
  end

  def self.player(state)
    send "player_#{state}"
  end

  def self.hurdle
    '#'
  end

  def self.track_line(length)
    '-' * length
  end

  def self.coin(flipped)
    flipped ? '|' : 'O'
  end
end
