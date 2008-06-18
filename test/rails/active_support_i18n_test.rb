$:.unshift 'lib/i18n/lib'

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'active_support'

require 'i18n'
require 'patch/active_support'
require 'patch/translations'

class ArrayExtToSentenceTests < Test::Unit::TestCase
  def test_array_to_sentence_given_a_connector_does_not_translate_sentence_connector
    I18n.expects(:translate).never
    assert_equal "one and also two", ['one', 'two'].to_sentence(:connector => 'and also')
  end

  def test_array_to_sentence_given_no_connector_translates_sentence_connector
    I18n.expects(:translate).with(:'support.array.sentence_connector', 'en-US').returns('and')
    assert_equal "one and two", ['one', 'two'].to_sentence(:locale => 'en-US')
  end
end