# encoding: utf-8

module I18n
  module Backend
    module Fast
      SEPARATOR_ESCAPE_CHAR = "\001"

      def reset_flattened_translations!
        @flattened_translations = nil
      end

      def flattened_translations
        @flattened_translations ||= flatten_translations(translations)
      end

      def merge_translations(locale, data)
        super
        reset_flattened_translations!
      end

      def init_translations
        super
        reset_flattened_translations!
      end

      protected
        # flatten_hash({:a=>'a', :b=>{:c=>'c', :d=>'d', :f=>{:x=>'x'}}}) 
        # # => {:a=>'a', :b=>{:c=>'c', :d=>'d', :f=>{:x=>'x'}}, :"b.f" => {:x=>"x"}, :"b.c"=>"c", :"b.f.x"=>"x", :"b.d"=>"d"}
        def flatten_hash(h, nested_stack = [], flattened_h = {})
          h.each_pair do |k, v|
            new_nested_stack = nested_stack + [escape_default_separator(k)]
            flattened_h[nested_stack_to_flat_key(new_nested_stack)] = v
            flatten_hash(v, new_nested_stack, flattened_h) if v.kind_of?(Hash)
          end

          flattened_h
        end

        def escape_default_separator(key)
          key.to_s.tr(I18n.default_separator, SEPARATOR_ESCAPE_CHAR)
        end

        def nested_stack_to_flat_key(nested_stack)
          nested_stack.join(I18n.default_separator).to_sym
        end

        def flatten_translations(translations)
          # don't flatten locale roots
          translations.inject({}) do |flattened_h, (locale_name, locale_translations)|
            flattened_h[locale_name] = flatten_hash(locale_translations)
            flattened_h
          end
        end

        def lookup(locale, key, scope = nil, separator = nil)
          init_translations unless @initialized
          if separator
            key   = cleanup_non_standard_separator(key, separator)
            scope = Array(scope).map{|k| cleanup_non_standard_separator(k, separator)} if scope
          end
          flattened_translations[locale.to_sym][(scope ? (Array(scope) + [key]).join(I18n.default_separator) : key).to_sym] rescue nil
        end

        def cleanup_non_standard_separator(key, user_separator)
          escape_default_separator(key).tr(user_separator, I18n.default_separator)
        end
    end
  end
end