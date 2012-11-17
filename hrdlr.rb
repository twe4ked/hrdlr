$: << File.dirname(__FILE__) + '/lib'

require 'sprite'
require 'player'
require 'track'
require 'frame'

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
