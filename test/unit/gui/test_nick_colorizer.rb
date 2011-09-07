require 'helper'

class UnitTests::TestNickColorizer < Test::Unit::TestCase
  test "colors the same nick the same color" do
    c = Smirch::GUI::NickColorizer.new
    expected = c.color_for('dude')
    assert_equal expected, c.color_for('dude')
  end
end
