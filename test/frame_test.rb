require 'test_helper'
require 'frame'

class FrameTest < MiniTest::Unit::TestCase
  def test_draw_in_range
    frame = Frame.new 5, 1
    frame.draw 1, 0, 'foo'
    assert_equal [' foo '], frame.rows
  end

  def test_draw_overlap_left
    frame = Frame.new 5, 1
    frame.draw -1, 0, 'foo'
    assert_equal ['oo   '], frame.rows
  end

  def test_draw_overlap_right
    frame = Frame.new 5, 1
    frame.draw 3, 0, 'foo'
    assert_equal ['   fo'], frame.rows
  end

  def test_draw_overlap_both
    frame = Frame.new 3, 1
    frame.draw -3, 0, 'abcdefghi'
    assert_equal ['def'], frame.rows
  end

  def test_draw_hidden_left
    frame = Frame.new 5, 1
    frame.draw -5, 0, 'foo'
    assert_equal ['     '], frame.rows
  end

  def test_draw_hidden_right
    frame = Frame.new 5, 1
    frame.draw 10, 0, 'foo'
    assert_equal ['     '], frame.rows
  end

  def test_draw_left_edge
    frame = Frame.new 5, 1
    frame.draw -1, 0, 'f'
    assert_equal ['     '], frame.rows
  end

  def test_draw_right_edge
    frame = Frame.new 5, 1
    frame.draw 5, 0, 'f'
    assert_equal ['     '], frame.rows
  end
end
