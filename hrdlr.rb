require 'io/console'

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

class Track
  def get_hurdles(range)
    [20, 30, 40, 55]
  end
end

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

class Frame
  attr_reader :rows

  def initialize(width, height)
    @rows = height.times.map { ' ' * width }
  end

  def draw(x, y, sprite)
    lines = sprite.split("\n")

    # overlap left
    if x < 0
      lines.map! do |line|
        if line.size >= -x
          line[-x..-1]
        else
          ' ' * line.size
        end
      end
      x = 0
    end

    # overlap right
    lines.map! do |line|
      line[0..@rows.first.size-x-1]
    end

    lines.each_with_index do |line, i|
      if line.size > 0 && x+line.size <= @rows.first.size
        @rows[y+i][x..x+line.size-1] = line
      end
    end
  end

  def render
    @rows.each_with_index do |row, i|
      Frame.move_cursor 0, i
      print row
    end
  end

  def self.move_cursor(x, y)
    print "\033[#{y+1};#{x+1}H"
  end

  def self.clear_screen
    print "\033[2J"
  end

  def self.setup
    clear_screen

    $stdin.raw!
    at_exit do
      puts "\r"
      $stdin.cooked!
    end
  end
end

if $0 == __FILE__
  Frame.setup

  player = Player.new
  track = Track.new

  while true do
    player.tick

    frame = Frame.new 80, 6
    frame.draw 0, 0, Sprite.track_line
    frame.draw 0, 5, Sprite.track_line
    frame.draw 4, 2-player.y, Sprite.player(player.state)
    track.get_hurdles(0..80).each do |position|
      frame.draw position-player.x, 4, Sprite.hurdle
    end
    frame.render

    sleep 0.5
    begin
      key = $stdin.read_nonblock(1).ord
      case key
      when 27 # escape
        exit
      when 32 # space
        player.jump
      end
    rescue Errno::EAGAIN
    end
  end
end
