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
    @multi_coin = 0 if player.multi_coin
  end

  def render
    rows, columns = $stdin.winsize
    @frame = Frame.new columns, 20

    draw_track
    draw_hurdles
    draw_coins
    draw_dino_ups
    draw_player
    draw_title
    draw_score
    draw_other_scores
    draw_multi_coin
    draw_dino_rampage

    @frame.render
  end

  def draw_track
    @frame.draw 0, 0, Sprite.track_line(@frame.width)
    @frame.draw 0, 5, Sprite.track_line(@frame.width)
  end

  def draw_multi_coin
    if @multi_coin
      if tick_count % 8 >= 4
        @frame.draw_center 2, Sprite.multi_coin
        @frame.draw_center 3, "** #{player.coin_count} coins **"
      end
      @multi_coin += 1
      @multi_coin = nil if @multi_coin >= 32
    end
  end

  def draw_dino_rampage
    if player.dino_count && player.dino_count <= 32 && tick_count % 8 >= 4
      @frame.draw_center 2, Sprite.dino_rampage
    end
  end

  def draw_player
    if player.dino_count
      @frame.draw player.x-viewport_x, 1, Sprite.dino(player.state)
    else
      @frame.draw player.x-viewport_x, 2-player.y, Sprite.player(player.state)
    end
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

  def draw_dino_ups
    track.dino_ups.get(viewport_x...viewport_x+@frame.width).each_with_index do |dino_up_x, i|
      @frame.draw dino_up_x-viewport_x, 1, Sprite.dino_up
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
    if player.coin_multiplier > 1 && tick_count % 8 >= 4
      @frame.draw_right @frame.width-2, 4, "coins x#{player.coin_multiplier}"
    end
  end

  def display_coins(coin_multiplier)
    "(coins x#{coin_multiplier})" if coin_multiplier && coin_multiplier > 1
  end

  def draw_other_scores
    @frame.draw 1, 7, 'Players'
    oldest_timestamp = Time.now - 5
    top_ten = @others.values.select { |other| other.timestamp >= oldest_timestamp }.sort_by { |other| [other.score, other.high_score] }.reverse.first(10)
    top_ten.each_with_index do |other, index|
      @frame.draw 1, 9+index, "#{index+1}. #{other.me? ? '***' : '   '} #{other.hostname}: #{other.score} #{display_coins(other.coin_multiplier)}"
    end

    @frame.draw @frame.width/2, 7, 'Leaderboard'
    high_scores = @others.values.select { |other| other.max_score > 0 }.sort_by(&:max_score).reverse.first(10)
    high_scores.each_with_index do |other, index|
      @frame.draw @frame.width/2, 9+index, "#{index+1}. #{other.me? ? '***' : '   '} #{other.hostname}: #{other.max_score}"
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
        other = OtherPlayer.new(data)
        @others[other.hostname] = other
      rescue Psych::SyntaxError
      end
    end
  rescue Errno::EAGAIN
  end

  def self.hostname
    @@hostname ||= `hostname -s`.strip
  end

  def send_update
    data = {
      hostname: self.class.hostname,
      score: self.player.score,
      high_score: self.player.high_score,
      coin_multiplier: self.player.coin_multiplier
    }

    begin
      @socket.send data.to_yaml, 0, '255.255.255.255', 47357
    rescue Errno::EHOSTUNREACH
    end
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
