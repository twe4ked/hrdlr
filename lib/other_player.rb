class OtherPlayer
  attr_reader :timestamp
  attr_reader :hostname, :score, :high_score

  def initialize(data)
    @timestamp = Time.now
    @hostname = data[:hostname]
    @score = data[:score]
    @high_score = data[:high_score]
  end

  def me?
    hostname == Game.hostname
  end

  def max_score
    [self.score, self.high_score].max
  end
end
