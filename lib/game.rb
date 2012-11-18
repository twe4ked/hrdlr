require 'socket'
require 'yaml'
require 'sprite'
require 'player'
require 'track'
require 'frame'
require 'other_player'
require 'sound'

class Game
  attr_reader :track, :player, :tick_count
  attr_reader :others

  def initialize
    @track = Track.new
    @player = Player.new track
    @tick_count = 0
    @others = {}
  end

  def tick
    @tick_count += 1
    player.tick
  end

  def render
    rows, columns = $stdin.winsize
    @frame = Frame.new columns, 20

    draw_track
    draw_hurdles
    draw_coins
    draw_player
    draw_title
    draw_score
    draw_other_scores

    @frame.render
  end

  def draw_track
    @frame.draw 0, 0, Sprite.track_line(@frame.width)
    @frame.draw 0, 5, Sprite.track_line(@frame.width)
  end

  def draw_player
    @frame.draw player.x-viewport_x, 2-player.y, Sprite.player(player.state)
  end

  def draw_hurdles
    track.hurdles.get(viewport_x...viewport_x+@frame.width).each do |hurdle_x|
      @frame.draw hurdle_x-viewport_x, 4, Sprite.hurdle
    end
  end

  def draw_coins
    track.coins.get(viewport_x...viewport_x+@frame.width).each_with_index do |coin_x, i|
      @frame.draw coin_x-viewport_x, 1, Sprite.coin(tick_count/4 % 2 == 0)
    end
  end

  def draw_title
    if (0...32).cover?(tick_count)
      @frame.draw_center 1, 'HURDLURR!!!'
      if tick_count % 8 >= 4
        @frame.draw_center 2, 'Press <Space> to jump!'
      end
    end
  end

  def draw_score
    @frame.draw_right @frame.width-1, 1, ' High score:      '
    @frame.draw_right @frame.width-2, 1, player.high_score.to_s
    @frame.draw_right @frame.width-1, 2, ' Score:           '
    @frame.draw_right @frame.width-2, 2, player.score.to_s
  end

  def draw_other_scores
    top_ten = @others.values.sort_by(&:score).reverse.first(10)
    top_ten.each_with_index do |other, index|
      @frame.draw 0, 7+index, " #{index+1}. #{other}"
    end
  end

  def viewport_x
    player.x - 4
  end

  def open_socket
    @socket = UDPSocket.new
    @socket.bind '0.0.0.0', 47357
    @socket.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true
    @socket.setsockopt Socket::SOL_SOCKET, Socket::SO_BROADCAST, true
  rescue Errno::EADDRINUSE
    $stderr.puts "Game is already running."
    exit 1
  end

  def receive_updates
    loop do
      begin
        data, addr = @socket.recvfrom_nonblock 8192
        data = YAML.load(data)
        @others[addr] = OtherPlayer.new(data)
      rescue Psych::SyntaxError
      end
    end
  rescue Errno::EAGAIN
  end

  def hostname
    @@hostname ||= `hostname -s`.strip
  end

  def send_update
    data = {
      hostname: self.hostname,
      score: self.player.score,
      high_score: self.player.high_score
    }
    @socket.send data.to_yaml, 0, '255.255.255.255', 47357
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
    open_socket
    Frame.setup

    while true do
      tick

      Sound.play('intro') if tick_count == 1

      render
      sleep 0.1
      joystick
      send_update if tick_count % 10 == 0
      receive_updates
    end
  end
end
