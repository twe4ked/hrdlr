class OtherPlayer
  attr_reader :hostname, :score, :high_score

  def initialize(data)
    @hostname = data[:hostname]
    @score = data[:score]
    @high_score = data[:high_score]
  end

  def me?
    hostname == Game.hostname
  end

  def to_s
    "#{me? ? '***' : '   '} #{hostname}: #{score} (high score: #{high_score})"
  end
end
