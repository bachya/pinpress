require 'test_helper'

require File.join(File.dirname(__FILE__), '..', 'lib/pinpress/templates/template')
require File.join(File.dirname(__FILE__), '..', 'lib/pinpress/templates/pin_template')

class TestPinTemplate < Test::Unit::TestCase
  def test_initialization
    parameters = {
      closer: '</ul>',
      item: '<li></li>',
      name: 'default',
      opener: '</ul>',
    }

    t = PinPress::PinTemplate.new(parameters)
    assert_equal(t.closer, parameters[:closer])
    assert_equal(t.item, parameters[:item])
    assert_equal(t.name, parameters[:name])
    assert_equal(t.opener, parameters[:opener])
  end
end
