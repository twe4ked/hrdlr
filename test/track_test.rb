require 'test_helper'
require 'track'

class TrackTest < MiniTest::Unit::TestCase
  def test_hurdle_beginning
    track = Track.new 3, 2
    hurdles = track.get_hurdles 0..10
    assert_equal [3, 5, 7, 9], hurdles
  end

  def test_hurdle_beginning2
    track = Track.new 4, 2
    hurdles = track.get_hurdles 0..10
    assert_equal [4, 6, 8, 10], hurdles
  end

  def test_hurdle_offset
    track = Track.new 3, 2
    hurdles = track.get_hurdles 6..16
    assert_equal [7, 9, 11, 13, 15], hurdles
  end

  def test_hurdle_offset2
    track = Track.new 3, 2
    hurdles = track.get_hurdles 7..17
    assert_equal [7, 9, 11, 13, 15, 17], hurdles
  end

  def test_hurdle_larger_step
    track = Track.new 10, 10
    hurdles = track.get_hurdles 900..950
    assert_equal [900, 910, 920, 930, 940, 950], hurdles
  end
end
