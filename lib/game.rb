require 'sprite'
require 'player'
require 'track'
require 'frame'

class Game
  attr_reader :track, :player, :tick_count

  def initialize
    @track = Track.new(50, 17)
    @player = Player.new track
    @tick_count = 0
  end

  def tick
    @tick_count += 1
    player.tick
  end

  def render
    frame = Frame.new 80, 6

    draw_track(frame)
    draw_player(frame)
    draw_hurdles(frame)
    draw_title(frame)
    draw_score(frame)

    frame.render
  end

  def draw_track(frame)
    frame.draw 0, 0, Sprite.track_line
    frame.draw 0, 5, Sprite.track_line
  end

  def draw_player(frame)
    frame.draw player.x-viewport_x, 2-player.y, Sprite.player(player.state)
  end

  def draw_hurdles(frame)
    track.get_hurdles(viewport_x...viewport_x+80).each do |hurdle_x|
      frame.draw hurdle_x-viewport_x, 4, Sprite.hurdle
    end
  end

  def draw_title(frame)
    if (0...32).cover?(tick_count)
      frame.draw_center 1, 'HURDLURR!!!'
      if tick_count % 8 >= 4
        frame.draw_center 2, 'Press <Space> to jump!'
      end
    end
  end

  def draw_score(frame)
    frame.draw_right 74, 1, 'High score:'
    frame.draw_right 79, 1, player.high_score.to_s
    frame.draw_right 74, 2, 'Score:'
    frame.draw_right 79, 2, player.score.to_s
  end

  def viewport_x
    player.x - 4
  end

  def joystick
    begin
      loop do
        key = $stdin.read_nonblock(1).ord
        case key
        when 'q'.ord, 27, 3 # escape, ctrl-c
          exit
        when 32 # space
          player.jump
        end
      end
    rescue Errno::EAGAIN
    end
  end

  def insert_coin
    Frame.setup

    while true do
      tick
      render
      sleep 0.1
      joystick
    end
  end
end
