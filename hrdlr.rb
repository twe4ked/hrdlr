$: << File.dirname(__FILE__) + '/lib'

require 'sprite'
require 'player'
require 'track'
require 'frame'

Frame.setup

track = Track.new(30, 15)
player = Player.new track

while true do
  player.tick

  frame = Frame.new 80, 6
  viewport_x = player.x - 4
  frame.draw 0, 0, Sprite.track_line
  frame.draw 0, 5, Sprite.track_line
  frame.draw player.x-viewport_x, 2-player.y, Sprite.player(player.state)
  track.get_hurdles(viewport_x...viewport_x+80).each do |hurdle_x|
    frame.draw hurdle_x-viewport_x, 4, Sprite.hurdle
  end
  frame.render

  sleep 0.1

  begin
    loop do
      key = $stdin.read_nonblock(1).ord
      case key
      when 'q'.ord, 27 # escape
        exit
      when 32 # space
        player.jump
      end
    end
  rescue Errno::EAGAIN
  end
end
