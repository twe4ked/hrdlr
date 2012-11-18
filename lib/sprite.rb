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

  def self.dino_up
    'D'
  end

  def self.multi_coin
    '** M U L T I - C O I N **'
  end

  def self.dino_run
    <<-SPRITE.gsub(/^ {4}/, '')
                __
        .-^^^-/ '_)
     __/       /
    <__.\\_\\-\\_\\
    SPRITE
  end

  def self.dino_normal
    <<-SPRITE.gsub(/^ {4}/, '')
                __
        .-^^^-/ '_)
     __/       /
    <__.|_|-|_|
    SPRITE
  end

  def self.dino_hidden
    ''
  end

  def self.dino_normal_fire
    <<-SPRITE.gsub(/^ {4}/, '')
                __
        .-^^^-/ '_)~=~
     __/       /
    <__.|_|-|_|
    SPRITE
  end

  def self.dino_run_fire
    <<-SPRITE.gsub(/^ {4}/, '')
                __
        .-^^^-/ '_)=~
     __/       /
    <__.\\_\\-\\_\\
    SPRITE
  end

  def self.dino_hidden_fire
    ''
  end

  def self.dino(state)
    send "dino_#{state}"
  end

  def self.dino_rampage
    <<-SPRITE.gsub(/^ {4}/, '')
    **    D I N O    **
    ** R A M P A G E **
    SPRITE
  end
end
