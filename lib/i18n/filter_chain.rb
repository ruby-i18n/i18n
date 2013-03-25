module I18n
  class FilterChain
    attr_accessor :before_lookup, :after_lookup

    def initialize(options={})
      @before_lookup = options[:before_lookup] || []
      @after_lookup  = options[:after_lookup]  || []
    end

    def apply(filter_list, translation)
      apply_filters(filter_list == :before_lookup ? before_lookup : after_lookup, translation)
    end

  protected

    # Passes the translation to all defined filters where applies? returns true
    # Returns a Translation instance
    def apply_filters(filters, translation)
      filters.each do |filter_class|
        filter = filter_class.new(translation)
        if filter.applies?
          filter.call
          translation = filter.translation
        end
      end
      translation
    end
  end
end