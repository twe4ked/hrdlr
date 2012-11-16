class Sprite
  def self.player_normal
    <<-SPRITE.gsub(/^ {4}/, '')
     o
    <|-
    / >
    SPRITE
  end

  def self.hurdle
    '#'
  end

  def self.track_line
    '-' * 80
  end
end

class Frame
  def initialize(width, height)
    @rows = height.times.map { ' ' * width }
  end

  def draw(x, y, sprite)
    lines = sprite.split("\n")
    lines.each_with_index do |line, i|
      @rows[y+i][x..x+line.size-1] = line
    end
  end

  def render
    print "\033[0;0H"
    @rows.each do |row|
      puts row
    end
  end
end

print "\033[2J"

frame = Frame.new 80, 6
frame.draw 0, 0, Sprite.track_line
frame.draw 0, 5, Sprite.track_line
frame.draw 4, 2, Sprite.player_normal
frame.draw 10, 4, Sprite.hurdle
frame.render
