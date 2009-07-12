require 'i18n/locale/tag'

module I18n
  @@fallbacks = nil

  class << self
    # Returns the current fallbacks implementation. Defaults to +I18n::Locale::Fallbacks+.
    def fallbacks
      @@fallbacks ||= I18n::Locale::Fallbacks.new
    end

    # Sets the current fallbacks implementation. Use this to set a differen fallbacks implementation.
    def fallbacks=(fallbacks)
      @@fallbacks = fallbacks
    end
    
    # Locale tag factory. Uses I18n::Locale::Tag by default.
    def tag(tag)
      tags.tag(tag.to_sym)
    end
    
    def tags
      @@tags ||= I18n::Locale::Tag
    end

    def tags=(tag_class)
      @@tags = tag_class
    end
  end

  module Locale
    class Fallbacks < Hash
      def initialize(*defaults)
        @map = {}
        map defaults.pop if defaults.last.is_a?(Hash)

        defaults = [I18n.default_locale.to_sym] if defaults.empty?
        self.defaults = defaults
      end

      def defaults=(defaults)
        @defaults = defaults.map { |default| compute(default, false) }.flatten
      end
      attr_reader :defaults

      def [](locale)
        raise InvalidLocale.new(locale) if locale.nil?
        locale = locale.to_sym
        has_key?(locale) ? fetch(locale) : store(locale, compute(locale))
      end

      def map(mappings)
        mappings.each do |from, to|
          from, to = from.to_sym, Array(to)
          to.each do |to|
            @map[from] ||= []
            @map[from] << to.to_sym
          end
        end
      end

      protected

      def compute(tags, include_defaults = true)
        result = Array(tags).collect do |tag|
          tags = I18n.tag(tag).self_and_parents.map! { |t| t.to_sym }
          tags.each { |tag| tags += compute(@map[tag]) if @map[tag] }
          tags
        end.flatten
        result.push(*defaults) if include_defaults
        result.uniq
      end
    end
  end
end
