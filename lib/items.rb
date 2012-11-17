class Items
  attr_reader :initial, :step_range

  def initialize(initial, step_range)
    @initial = initial
    @step_range = step_range
    @items = [self.initial]
  end

  def get(range)
    return [] if range.min.nil?
    while @items.last < range.max
      @items << @items.last + rand(self.step_range)
    end
    if @items.size > 1000
      @items = @items[-1000..-1]
    end
    @items.select { |x| range.cover?(x) }
  end
end
