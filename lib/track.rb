class Track
  attr_reader :initial, :step_range

  def initialize(initial, step_range)
    @initial = initial
    @step_range = step_range
    @hurdles = [self.initial]
  end

  def get_hurdles(range)
    return [] if range.min.nil?
    while @hurdles.last < range.max
      @hurdles << @hurdles.last + rand(self.step_range)
    end
    if @hurdles.size > 100
      @hurdles = @hurdles[-100..-1]
    end
    @hurdles.select { |x| range.cover?(x) }
  end
end
