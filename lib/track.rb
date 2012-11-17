class Track
  attr_reader :initial, :step

  def initialize(initial, step)
    @initial = initial
    @step = step
  end

  def get_hurdles(range)
    from = range.min - ((range.min - self.initial) % step)
    to = range.max
    (from..to).step(self.step).select { |x| x >= self.initial && x >= range.min }
  end
end
