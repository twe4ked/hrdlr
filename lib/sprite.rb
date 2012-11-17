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
    /|-
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

  def self.player(state)
    send "player_#{state}"
  end

  def self.hurdle
    '#'
  end

  def self.track_line
    '-' * 80
  end
end