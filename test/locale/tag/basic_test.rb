require File.dirname(__FILE__) + '/../../test_helper.rb'
require 'i18n/locale/tag'
require 'i18n/locale/tag/basic'

# Tag for the locale 'DE-latn-de'

class I18nLocaleTagSubtagsTest < Test::Unit::TestCase
  include I18n::Locale
  
  def setup
    subtags = %w(de Latn DE)
    @tag = Tag::Basic.new *subtags
  end

  test "returns 'de' as the language subtag in lowercase" do
    assert_equal %w(de Latn DE), @tag.subtags
  end

  # test "returns 'Latn' as the script subtag in titlecase" do
  #   assert_equal 'Latn', @tag.script
  # end
  # 
  # test "returns 'DE' as the region subtag in uppercase" do
  #   assert_equal 'DE', @tag.region
  # end
  # 
  # test "returns 'variant' as the variant subtag in lowercase" do
  #   assert_equal 'variant', @tag.variant
  # end
  # 
  # test "returns 'a-ext' as the extension subtag" do
  #   assert_equal 'a-ext', @tag.extension
  # end
  # 
  # test "returns 'x-phonebk' as the privateuse subtag" do
  #   assert_equal 'x-phonebk', @tag.privateuse
  # end
  # 
  # test "returns 'i-klingon' as the grandfathered subtag" do
  #   assert_equal 'i-klingon', @tag.grandfathered
  # end
  # 
  # test "returns a formatted tag string from #to_s" do
  #   assert_equal 'de-Latn-DE-variant-a-ext-x-phonebk-i-klingon', @tag.to_s
  # end
  # 
  # test "returns an array containing the formatted subtags from #to_a" do
  #   assert_equal %w(de Latn DE variant a-ext x-phonebk i-klingon), @tag.to_a
  # end
end

# # Tag inheritance
# 
# class I18nLocaleTagSubtagsTest < Test::Unit::TestCase
#   test "#parent returns 'de-Latn-DE-variant-a-ext-x-phonebk' as the parent of 'de-Latn-DE-variant-a-ext-x-phonebk-i-klingon'" do
#     tag = Tag::Basic.new *%w(de Latn DE variant a-ext x-phonebk i-klingon)
#     assert_equal 'de-Latn-DE-variant-a-ext-x-phonebk', tag.parent.to_s
#   end
# 
#   test "#parent returns 'de-Latn-DE-variant-a-ext' as the parent of 'de-Latn-DE-variant-a-ext-x-phonebk'" do
#     tag = Tag::Basic.new *%w(de Latn DE variant a-ext x-phonebk)
#     assert_equal 'de-Latn-DE-variant-a-ext', tag.parent.to_s
#   end
# 
#   test "#parent returns 'de-Latn-DE-variant' as the parent of 'de-Latn-DE-variant-a-ext'" do
#     tag = Tag::Basic.new *%w(de Latn DE variant a-ext)
#     assert_equal 'de-Latn-DE-variant', tag.parent.to_s
#   end
# 
#   test "#parent returns 'de-Latn-DE' as the parent of 'de-Latn-DE-variant'" do
#     tag = Tag::Basic.new *%w(de Latn DE variant)
#     assert_equal 'de-Latn-DE', tag.parent.to_s
#   end
# 
#   test "#parent returns 'de-Latn' as the parent of 'de-Latn-DE'" do
#     tag = Tag::Basic.new *%w(de Latn DE)
#     assert_equal 'de-Latn', tag.parent.to_s
#   end
# 
#   test "#parent returns 'de' as the parent of 'de-Latn'" do
#     tag = Tag::Basic.new *%w(de Latn)
#     assert_equal 'de', tag.parent.to_s
#   end
# 
#   # TODO RFC4647 says: "If no language tag matches the request, the "default" value is returned."
#   # where should we set the default language?
#   # test "#parent returns '' as the parent of 'de'" do
#   #   tag = Tag::Basic.new *%w(de)
#   #   assert_equal '', tag.parent.to_s
#   # end
# 
#   test "#parent returns an array of 5 parents for 'de-Latn-DE-variant-a-ext-x-phonebk-i-klingon'" do
#     parents = %w(de-Latn-DE-variant-a-ext-x-phonebk-i-klingon
#                  de-Latn-DE-variant-a-ext-x-phonebk
#                  de-Latn-DE-variant-a-ext
#                  de-Latn-DE-variant
#                  de-Latn-DE
#                  de-Latn
#                  de)
#     tag = Tag::Basic.new *%w(de Latn DE variant a-ext x-phonebk i-klingon)
#     assert_equal parents, tag.self_and_parents.map{|tag| tag.to_s}
#   end
# 
#   test "returns an array of 5 parents for 'de-Latn-DE-variant-a-ext-x-phonebk-i-klingon'" do
#     parents = %w(de-Latn-DE-variant-a-ext-x-phonebk-i-klingon
#                  de-Latn-DE-variant-a-ext-x-phonebk
#                  de-Latn-DE-variant-a-ext
#                  de-Latn-DE-variant
#                  de-Latn-DE
#                  de-Latn
#                  de)
#     tag = Tag::Basic.new *%w(de Latn DE variant a-ext x-phonebk i-klingon)
#     assert_equal parents, tag.self_and_parents.map{|tag| tag.to_s}
#   end
# end