module I18n
  module Backend
    # Overwrites the Simple backend translate method so that it will interpolate
    # additional inflection tokens present in translations. These tokens may
    # appear in *patterns* which are contained within <tt>@{</tt> and <tt>}</tt>
    # symbols.
    # 
    # You can choose different kinds (gender, title, person, time, author, etc.)
    # of tokens to group them in a meaningful, semantical sets. That means you can
    # apply Inflector to do simple inflection by a gender or a person, when some
    # language requires it.
    # 
    # To achieve similar functionality lambdas can be used but there might be
    # some areas of appliance that including proc objects in translations
    # is prohibited.
    # If you have a troop of happy translators that shouldn't have the
    # ability to execute any code yet you need some simple inflection
    # then you can make use of this module.
    # == Usage
    #   require 'i18n'
    #   I18n::Backend::Simple.send(:include, I18n::Backend::Inflector)
    #   
    #   i18n.translate(welcome)
    #   # where welcome maps to: "Dear @{f:Madam|m:Sir}"
    #
    # == Inflection pattern
    # An example inflection pattern contained in a translation record looks like:
    #   welcome: "Dear @{f:Madam|m:Sir|n:You|All}"
    # 
    # The +f+, +m+ and +n+ are inflection *tokens* and +Madam+, +Sir+, +You+ and
    # +All+ are *values*. Only one value is going to replace the whole
    # pattern. To select which one an additional option is used. That option
    # must be passed to translate method.
    # 
    # == Configuration
    # To recognize tokens present in patterns this module uses keys grouped
    # in the scope called +inflections+ for a given locale. For instance
    # (YAML format):
    #   en:
    #     i18n:
    #       inflections:
    #         gender:
    #           f:      "female"
    #           m:      "male"
    #           n:      "neuter"
    #           woman:  @f
    #           man:    @m
    #           default: n
    # 
    # Elements in the example above are:
    # * +en+: language
    # * +i18n+: configuration scope
    # * +inflections+: inflections configuration scope
    # * +gender+: kind scope
    # * +f+, +m+, +n+: inflection tokens
    # * <tt>"male"</tt>, <tt>"female"</tt>, <tt>"neuter"</tt>: tokens' descriptions
    # * +woman+, +man+: inflection aliases
    # * <tt>@f</tt>, <tt>@m</tt>: pointers to real tokens 
    # * +default+: default token for a kind +gender+
    # 
    # === Kind
    # Note the fourth scope selector in the example above (+gender+). It's called
    # the *kind* and contains *tokens*. We have the kind
    # +gender+ to which the inflection tokens +f+, +m+ and +n+ are
    # assigned.
    # 
    # You cannot assign the same token to more than one kind.
    # Trying to do that will raise DuplicatedInflectionToken exception.
    # This is required in order to keep patterns simple and tokens interpolation
    # fast.
    # 
    # Kind is also used to instruct I18n.translate method which
    # token it should pick. This will be explained later. 
    #
    # === Aliases
    # Aliases are special tokens that point to other tokens. They cannot
    # be used in inflection patterns but they are fully recognized values
    # of options while evaluating kinds.
    # 
    # Aliases might be helpful in multilingual applications that are using
    # a fixed set of values passed through options to describe some properties
    # of messages, e.g. +masculine+ and +feminine+ for a grammatical gender.
    # Translators may then use their own tokens (like +f+ and +m+ for English)
    # to produce pretty and intuitive patterns.
    # 
    # For example: if some application uses database with gender assigned
    # to a user which may be +male+, +female+ or +none+, then a translator
    # for some language may find it useful to map impersonal token (<tt>none</tt>)
    # to the +neuter+ token, since in translations for his language the
    # neuter gender is in use.
    # 
    # Here is the example of such situation:
    # 
    #   en:
    #     i18n:
    #       inflections:
    #         gender:
    #           male:     "male"
    #           female:   "female"
    #           none:     "impersonal form"
    #           default:  none 
    #   
    #   pl:
    #     i18n:
    #       inflections:
    #         gender:
    #           k:        "female"
    #           m:        "male"
    #           n:        "neuter"
    #           male:     @k
    #           female:   @m
    #           none:     @n
    #           default:  none
    # 
    # In the case above Polish translator decided to use neuter
    # instead of impersonal form when +none+ token will be passed
    # through the option +:gender+ to the translate method. He
    # also decided that he will use +k+, +m+ or +n+ in patterns,
    # because the names are short and correspond to gender names in
    # Polish language.
    # 
    # Aliases may point to other aliases. While loading inflections they
    # will be internally shortened and they will always point to real tokens,
    # not other aliases.
    # 
    # === Default token
    # There is special token called the +default+, which points
    # to a token that should be used if translation routine cannot deduce
    # which one it should use because a proper option was not given.
    # 
    # Default tokens may point to aliases and may use aliases' syntax, e.g.:
    #   default: @man
    # 
    # === Descriptions
    # The values of keys in the example (+female+, +male+ and +neuter+)
    # are *descriptions* which are not used by interpolation routines
    # but might be helpful (e.g. in UI). For obvious reasons you cannot
    # describe aliases.
    # 
    # == Tokens
    # The token is an element of a pattern. A pattern may have many tokens
    # of the same kind separated by vertical bars. Each token used in a
    # pattern should end with colon sign. After this colon a value should
    # appear (or an empty string). This value is to be picked by interpolation
    # routine and will replace whole pattern, when it matches the value of an
    # option passed to I18n.translate method. A name of that
    # option should be the same as a *kind* of tokens used within a pattern.
    # The first token in a pattern determines the kind of all tokens used
    # in that pattern.
    # ==== Examples
    #   # welcome is "Dear @{f:Madam|m:Sir|n:You|All}"
    #   
    #   I18n.translate(welcome, :gender => :m)
    #   # => "Dear Sir"
    #   
    #   I18n.translate(welcome, :gender => :unknown)
    #   # => "Dear All"
    #   
    #   I18n.translate(welcome)
    #   # => "Dear You"
    # 
    # In the second example the <b>fallback value</b> +All+ was interpolated
    # because the routine had been unable to find the token called +:unknown+.
    # That differs from the latest example, in which there was no option given,
    # so the default token for a kind had been applied (in this case +n+).
    # 
    # == Local fallbacks (free text)
    # The fallback value will be used when any of the given tokens from
    # pattern cannot be interpolated.
    # 
    # Be aware that enabling extended error reporting makes it unable
    # to use fallback values in most cases. Local fallbacks will then be
    # applied only when a given option contains a proper value for some
    # kind but it's just not present in a pattern, for example:
    #
    #   I18n.locale = :en
    #   I18n.backend.store_translations 'en', 'welcome' => 'Dear @{n:You|All}'   
    #   I18n.backend.store_translations 'en', :i18n     => { :inflections => {
    #                                         :gender   => { :n => 'neuter', :o => 'other' }}}
    #   
    #   I18n.translate('welcome', :gender => :o, :inflector_raises => true)
    #   # => "Dear All"
    #   
    #   # since the token :o was configured but not used in the pattern
    #
    # == Unknown and empty tokens in options
    # If an option containing token is not present at all then the interpolation
    # routine will try the default token for a processed kind if the default
    # token is present in a pattern. The same thing will happend if the option
    # is present but its value is unknown, empty or +nil+.
    # If the default token is not present in a pattern or is not defined in
    # a configuration data then the processed pattern will result in an empty
    # string or in a local fallback value if there is a free text placed
    # in a pattern.
    # 
    # You can change this default behavior and force inflector
    # not to use a default token when a value of an option for a kind is unknown,
    # empty or +nil+ but only when it's not present.
    # To do that you should set option +:inflector_unknown_defaults+ to
    # +false+ and pass it to I18n.translate method. Other way is to set this
    # globally by using the method called inflector_unknown_defaults.
    # See inflector_unknown_defaults method for examples showing how the
    # translation results are changing when that switch is applied.
    # 
    # == Errors
    # By default the module will silently ignore any interpolation errors.
    # You can turn off this default behavior by passing +:inflector_raises+ option.
    # For instance:
    #
    #   I18n.locale = :en
    #   I18n.backend.store_translations 'en', 'welcome' => 'Dear @{m:Sir|f:Madam|Fallback}'
    #   I18n.backend.store_translations 'en', :i18n     =>  { :inflections => {
    #                                                           :gender   => {
    #                                                             :f => 'female',
    #                                                             :m => 'male'
    #                                                       }}}
    # 
    #   I18n.translate(welcome, :inflector_raises => true)
    #   # => I18n::InvalidOptionForKind: option :gender required
    #        by the pattern "@{m:Sir|f:Madam|Fallback}" was not found
    # 
    # Here are the exceptions that may be raised when option +:inflector_raises+
    # is set to +true+:
    # 
    # * I18n::InvalidOptionForKind
    # * I18n::InvalidInflectionToken
    # * I18n::MisplacedInflectionToken
    # 
    # There are also exceptions that are raised regardless of :+inflector_raises+
    # presence or value.
    # These are usually caused by critical errors encountered during processing
    # inflection data. Here is the list:
    # 
    # * I18n::InvalidLocale
    # * I18n::DuplicatedInflectionToken
    # * I18n::BadInflectionToken
    # * I18n::BadInflectionAlias
    #
    module Inflector

      # Contains <tt>@{</tt> string that is used to quickly fallback
      # to standard translate method if it's not found.
      FAST_MATCHER  = '@{'

      # Contains a regular expression that catches patterns.
      PATTERN       = /([^@\\])@\{([^\}]+)\}/

      # Contains a regular expression that catches tokens.
      TOKENS        = /(?:([^\:\|]+):+([^\|]+)\1?)|([^:\|]+)/ 

      # Contains a symbol that indicates an alias.
      ALIAS_MARKER  = '@'

      # When this switch is set to +true+ then inflector falls back to the default
      # token for a kind if an option passed to the translate method that describes
      # a kind is unknown or +nil+. Note that the value for a default token will be
      # interpolated only when this token is present in pattern. This switch
      # is by default set to +true+.
      # 
      # Local option +inflector_unknown_defaults+ passed to translation method
      # overrides this setting.
      # 
      # == Examples
      # 
      #   I18n.locale = :en
      #   I18n.backend.store_translations 'en', :i18n => { :inflections => {
      #                                                     :gender => {
      #                                                       :n => 'neuter',
      #                                                       :o => 'other',
      #                                                       :default => 'n' }}}
      #   
      #   I18n.backend.store_translations 'en', 'welcome'      => 'Dear @{n:You|o:Other}'
      #   I18n.backend.store_translations 'en', 'welcome_free' => 'Dear @{n:You|o:Other|Free}'
      #   
      # === Example 1
      #   
      #   # :gender option is not present,
      #   # unknown tokens in options are falling back to default
      #    
      #   I18n.t('welcome')
      #   # => "Dear You"
      #   
      #   # :gender option is not present,
      #   # unknown tokens from options are not falling back to default
      #   
      #   I18n.t('welcome', :inflector_unknown_defaults => false)
      #   # => "Dear You"
      #   
      #   # :gender option is not present, free text is present,
      #   # unknown tokens from options are not falling back to default
      #   
      #   I18n.t('welcome_free', :inflector_unknown_defaults => false)
      #   # => "Dear You"
      #   
      # === Example 2
      #   
      #   # :gender option is nil,
      #   # unknown tokens from options are falling back to default token for a kind
      #   
      #   I18n.t('welcome', :gender => nil)
      #   # => "Dear You"
      #   
      #   # :gender option is nil
      #   # unknown tokens from options are not falling back to default token for a kind
      #   
      #   I18n.t('welcome', :gender => nil, :inflector_unknown_defaults => false)
      #   # => "Dear "
      #   
      #   # :gender option is nil, free text is present
      #   # unknown tokens from options are not falling back to default token for a kind
      #   
      #   I18n.t('welcome_free', :gender => nil, :inflector_unknown_defaults => false)
      #   # => "Dear Free"
      #   
      # === Example 3
      #   
      #   # :gender option is unknown,
      #   # unknown tokens from options are falling back to default token for a kind
      #   
      #   I18n.t('welcome', :gender => :unknown_blabla)
      #   # => "Dear You"
      #   
      #   # :gender option is unknown,
      #   # unknown tokens from options are not falling back to default token for a kind
      #   
      #   I18n.t('welcome', :gender => :unknown_blabla, :inflector_unknown_defaults => false)
      #   # => "Dear "
      #   
      #   # :gender option is unknown, free text is present
      #   # unknown tokens from options are not falling back to default token for a kind
      #   
      #   I18n.t('welcome_free', :gender => :unknown_blabla, :inflector_unknown_defaults => false)
      #   # => "Dear Free"
      attr_writer :inflector_unknown_defaults

      # When this switch is set to +true+ then inflector falls back and uses the default
      # token for a kind if an option passed to the translate method matches some token
      # for that kind but that particular token is not included in a processed
      # pattern. This switch is by default set to +false+.
      # 
      # Local option +:inflector_excluded_defaults+ passed to translation method
      # overrides this setting.
      # 
      # == Example
      # 
      #   I18n.locale = :en
      #   I18n.backend.store_translations 'en', :i18n => { :inflections => {
      #                                                     :gender => {
      #                                                       :n => 'neuter',
      #                                                       :m => 'male',
      #                                                       :o => 'other',
      #                                                       :default => 'n' }}}
      #   
      #   I18n.backend.store_translations 'en', 'welcome' => 'Dear @{n:You|m:Sir}'
      #   
      #   p I18n.t('welcome', :gender => :o)
      #   # => "Dear "
      #   
      #   p I18n.t('welcome', :gender => :o, :inflector_excluded_defaults => true)
      #   # => "Dear You"
      attr_writer :inflector_excluded_defaults
      
      # This is a switch that enables extended error reporting. When it's enabled then
      # errors will be raised when unknown or empty token is present in pattern or in options.
      # This switch is by default set to +false+.
      # 
      # Local option +:inflector_raises+ passed to translation method overrides this setting.
      attr_writer :inflector_raises

      # Returns a switch that enables extended error reporting.
      # 
      # If the option is given then it returns the value of that option instead.
      def inflector_raises?(option=nil)
        option.nil? ? @inflector_raises : option
      end

      # Returns a switch that enables falling back to default token for a kind when
      # value passed in options was unknown or empty.
      # 
      # If the option is given then it returns the value of that option instead.
      def inflector_unknown_defaults?(option=nil)
        option.nil? ? @inflector_unknown_defaults : option
      end

      # Returns a switch that enables falling back to default token for a kind when
      # value passed in options was unknown or empty.
      # 
      # If the option is given then it returns the value of that option instead.
      def inflector_excluded_defaults?(option=nil)
        option.nil? ? @inflector_excluded_defaults : option
      end

      # Cleans up inflection_tokens hash.
      def reload!
        @inflection_tokens = nil
        @inflection_aliases = nil
        @inflection_defaults = nil
        super
      end

      # Sets up some configuration defaults.
      def initialize
        @inflector_excluded_defaults = false
        @inflector_unknown_defaults = true
        @inflector_raises = false
        super
      end

      # Translates given key taking care of inflections.
      def translate(locale, key, options = {})
        translated_string = super
        return translated_string if locale.to_s.empty?

        unless translated_string.include?(I18n::Backend::Inflector::FAST_MATCHER)
          return translated_string
        end

        inflection_tokens = @inflection_tokens[locale]
        if (inflection_tokens.nil? || inflection_tokens.empty?)
          return clear_inflection_patterns(translated_string)
        end

        interpolate_inflections(translated_string, locale, options.dup)
      end
      
      # Returns a default token for a given kind or +nil+.
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      def inflection_default_token(kind, locale=nil)
        locale = inflector_prep_locale(locale)
        return nil if kind.to_s.empty?
        init_translations unless initialized?
        inflections = @inflection_defaults[locale]
        return nil if inflections.nil?
        inflections[kind.to_sym]
      end
      
      # Tells if token is an alias.
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      def inflection_is_alias?(token, locale=nil)
        return false if token.to_s.empty?
        locale = inflector_prep_locale(locale)
        init_translations unless initialized?
        aliases = @inflection_aliases[locale]
        return false if aliases.nil?
        aliases.has_key?(token.to_sym)
      end

      # Returns a Hash containing available inflection tokens (token => description)
      # for a given +kind+ and +locale+ including aliases.
      # 
      # If locale is not set then I18n.locale is used.
      # If +kind+ is not given or +nil+ then it returns all available tokens for all kinds.
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      # 
      # Note that you cannot deduce where aliases are pointing to since the information
      # about a target is replaced by a description here. To get targets use the
      # inflection_raw_tokens method. To just list aliases and their targets use
      # the inflection_aliases method.
      def inflection_tokens(kind=nil, locale=nil)
        locale = inflector_prep_locale(locale)
        true_tokens = inflection_true_tokens(kind, locale)
        aliases = @inflection_aliases[locale]
        return true_tokens if aliases.nil?
        aliases = aliases.reject{|k,v| v[:kind]!=kind} unless kind.nil?
        aliases = aliases.merge(aliases){|k,v| v[:description]}
        true_tokens.merge(aliases)
      end

      # Returns a Hash containing available inflection tokens for a given +kind+ and
      # +locale+ including aliases. The values of the result may vary, depending what
      # they are describing. If the token is an alias the value is type of Symbol
      # that contains a name of a real token. BTW, an alias is always shortened and it will
      # never point to other alias, always to a real token. If the token is a real
      # token then the value contains a String with description.
      #  
      # If locale is not set then I18n.locale is used.
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      # If +kind+ is not given or +nil+ then it returns all available tokens for all kinds.
      def inflection_raw_tokens(kind=nil, locale=nil)
        true_tokens = inflection_true_tokens(kind, locale)
        aliases     = inflection_aliases(kind, locale)
        true_tokens.merge(aliases)
      end

      # Returns a Hash containing available inflection tokens (token => description)
      # for a given +kind+ and +locale+. It does not incude aliases, which means
      # that the returned token can be used in patterns.
      # 
      # If locale is not set then I18n.locale is used.
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      # 
      # # If +kind+ is not given or +nil+ then it returns all
      # true tokens for all kinds.
      def inflection_true_tokens(kind=nil, locale=nil)
        locale = inflector_prep_locale(locale)
        init_translations unless initialized?
        inflections = @inflection_tokens[locale]
        return {} if inflections.nil?
        inflections = inflections.reject{|k,v| v[:kind]!=kind} unless kind.nil?
        inflections.merge(inflections){|k,v| v[:description]}
      end

      # Returns a Hash (alias => target) containing available inflection
      # aliases for a given +kind+ and +locale+.
      # 
      # If locale is not set then I18n.locale is used.
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      # If +kind+ is not given or +nil+ then it returns all available aliases for all kinds.
      def inflection_aliases(kind=nil, locale=nil)
        locale = inflector_prep_locale(locale)
        init_translations unless initialized?
        aliases = @inflection_aliases[locale]
        return {} if aliases.nil?
        aliases = aliases.reject{|k,v| v[:kind]!=kind} unless kind.nil?
        aliases.merge(aliases){|k,v| v[:target]}
      end

      # Returns an array of Symbols containing known kinds of inflections
      # for a given +locale+.
      # 
      # If locale is not set then I18n.locale is used.
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      def available_inflection_kinds(locale=nil)
        locale = inflector_prep_locale(locale)
        subtree = inflection_subtree(locale)
        return [] if subtree.nil?
        subtree.keys
      end

      # Returns an array of locales that are inflected. If +kind+ is given it returns
      # only those locales that are inflected and support inflection by this kind. 
      def inflected_locales(kind=nil)
        init_translations unless initialized?
        inflected_locales = (@inflection_tokens.keys || [])
        return inflected_locales if kind.to_s.empty?
        kind = kind.to_sym
        inflected_locales.select do |loc|
          kinds = inflection_subtree(loc)
          kinds.respond_to?(:has_key?) && kinds.has_key?(kind)
        end
      end

      # Stores translations for the given locale in memory.
      # If inflections are changed it will regenerate proper internal
      # structures.
      # 
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      def store_translations(locale, data, options = {})
        r = super
        locale = inflector_prep_locale(locale)
        inflector_try_init
        if data.respond_to?(:has_key?)
          subdata = (data[:i18n] || data['i18n'])
          unless subdata.nil?
            subdata = (subdata[:inflections] || subdata['inflections'])
            unless subdata.nil?
              @inflection_tokens.delete(locale)
              @inflection_aliases.delete(locale)
              @inflection_defaults.delete(locale)
              load_inflection_tokens(locale)
            end
          end
        end
        r
      end
      
      # Returns the description of the given inflection token. If the token is
      # an alias it returns the description of the true token that
      # it points to.
      # 
      # It returns +nil+ when something goes wrong.
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      def inflection_token_description(token, locale=nil)
        locale = inflector_prep_locale(locale)
        return nil if token.to_s.empty?
        init_translations unless initialized?
        inflections = @inflection_tokens[locale]
        aliases     = @inflection_aliases[locale]
        return nil if (inflections.nil? || aliases.nil?)
        token = token.to_sym
        match = ( inflections[token] || aliases[token] )
        return nil if match.nil?
        match[:description]
      end

      protected

      # Processes locale given as parameter. Returns given locale if it's present
      # or default locale or +nil+.
      # 
      # It may raise I18n::InvalidLocale if a given +locale+ is invalid.
      def inflector_prep_locale(locale=nil)
        locale ||= I18n.locale
        raise I18n::InvalidLocale.new(locale) if locale.to_s.empty?
        locale.to_sym
      end

      # Interpolates inflection values into a given string
      # using kinds given in options and a matching tokens.
      def interpolate_inflections(string, locale, options = {})
        raises            = inflector_raises?             options.delete(:inflector_raises)
        unknown_defaults  = inflector_unknown_defaults?   options.delete(:inflector_unknown_defaults)
        excluded_defaults = inflector_excluded_defaults?  options.delete(:inflector_excluded_defaults)
        used_kinds        = options.except(*RESERVED_KEYS)
        inflections       = @inflection_tokens[locale]
        defaults          = @inflection_defaults[locale]
        aliases           = @inflection_aliases[locale]

        string.gsub(I18n::Backend::Inflector::PATTERN) do
          pattern_fix     = $1
          ext_pattern     = $&
          parsed_kind     = nil
          ext_value       = nil
          ext_freetext    = ''
          found           = false
          parsed_default_v= nil
          ext_pattern     = ext_pattern[1..-1] unless pattern_fix.nil?

          $2.scan(I18n::Backend::Inflector::TOKENS) do
            ext_token     = $1.to_s
            ext_value     = $2.to_s
            ext_freetext  = $3.to_s
            kind          = nil
            option        = nil

            # token not found?
            if ext_token.empty?
              # free text not found too? that should never happend.
              if ext_freetext.empty?
                raise I18n::InvalidInflectionToken.new(ext_pattern, ext_token) if raises
              end
              next
            end

            # set token and get current kind for it
            token   = ext_token.to_sym
            t_entry = inflections[token]
            
            # kind not found for a given token?
            if t_entry.nil?
              raise I18n::InvalidInflectionToken.new(ext_pattern, ext_token) if raises
              next
            end

            # set kind
            kind = t_entry[:kind]

            # set processed kind after matching first token in pattern
            if parsed_kind.nil?
              parsed_kind = kind
            elsif parsed_kind != kind
              raise I18n::MisplacedInflectionToken.new(ext_pattern, token, parsed_kind) if raises
              next
            end

            # memorize default option for further processing
            default_token = defaults[kind]

            # fetch the kind's option or fetch default if an option does not exists
            option = options.has_key?(kind) ? options[kind] : default_token

            if option.to_s.empty?
              # if option is given but is unknown, empty or nil
              # then use default option for a kind if unknown_defaults is switched on
              option = unknown_defaults ? default_token : nil
            else
              # validate option and if it's unknown try in aliases
              option = option.to_sym
              unless inflections.has_key?(option)
                option = aliases[option]
                if option.nil?
                  # if still nothing then fall back to default value
                  # for a kind in unknown_defaults switch is on
                  option = unknown_defaults ? default_token : nil
                else
                  option = option[:target]
                end
              end
            end

            # if the option is still unknown
            if option.nil?
              raise I18n::InvalidOptionForKind.new(ext_pattern, kind, ext_token, option) if raises
              next
            end

            # memorize default token's value for further processing
            # outside this block if excluded_defaults switch is on
            parsed_default_v = ext_value if (excluded_defaults && token == default_token)

            # throw the value if a given option matches the token
            next unless option == token

            # skip further evaluation of the pattern
            # since the right token has been found
            found = true
            break

          end # single token:value processing

          result = nil

          # return value of a token that matches option's value
          # given for a kind or try to return a free text
          # if it's present
          if found
            result = ext_value
          elsif (excluded_defaults && !parsed_kind.nil?)
            # if there is excluded_defaults switch turned on
            # and a correct token was found in options but
            # has not been found in a pattern then interpolate
            # the pattern with a value picked for the default
            # token for that kind if a default token was present
            # in a pattern
            kind  = nil
            token = options[parsed_kind]
            kind = inflections[token] unless token.nil?
            result = parsed_default_v unless (kind.nil? || kind[:kind].nil?)
          end

          pattern_fix + (result || ext_freetext)

        end # single pattern processing
      
      end

      # Initializes inflection_tokens hash.
      def inflector_try_init
        @inflection_tokens    ||= {}
        @inflection_aliases   ||= {}
        @inflection_defaults  ||= {}
      end

      def init_translations
        r = super
        inflector_try_init
        available_locales.each{ |locale| load_inflection_tokens(locale) }
        r
      end

      # Returns the translation with any inflection patterns removed.
      def clear_inflection_patterns(translated_string)
        translated_string.gsub(I18n::Backend::Inflector::PATTERN,'')
      end
      
      # Returns part of the translation data that
      # reflects inflections for a given locale.
      def inflection_subtree(locale)
        lookup(locale, :"i18n.inflections", [], :fallback => true, :raise => :false)
      end

      # Resolves an alias for a token if token contains an alias.
      # Takes care of aliasing loops.
      def shorten_inflection_alias(token, kind, locale, count=0)
        count += 1
        return nil if count > 64
  
        inflections = inflection_subtree(locale)
        return nil if (inflections.nil? || inflections.empty?)

        kind_subtree  = inflections[kind]
        value         = kind_subtree[token].to_s

        if value.slice(0,1) != I18n::Backend::Inflector::ALIAS_MARKER
          if kind_subtree.has_key?(token)
            return token
          else
            # that should never happend but who knows
            raise I18n::BadInflectionToken.new(locale, token, kind)
          end
        else
          orig_token = token
          token = value[1..-1]
          if token.to_s.empty?
            raise I18n::BadInflectionToken.new(locale, token, kind)
          end
          token = token.to_sym
          if kind_subtree[token].nil?
            raise BadInflectionAlias.new(locale, orig_token, kind, token)
          else
            shorten_inflection_alias(token, kind, locale, count)
          end
        end

      end

      # Uses the inflections siubtree and creates many-to-one mapping
      # to resolve genders assigned to inflection tokens.
      def load_inflection_tokens(locale=nil)
        return @inflection_tokens[locale] if @inflection_tokens.has_key?(locale)
        inflections = inflection_subtree(locale)
        return nil if (inflections.nil? || inflections.empty?)
        ivars     = @inflection_tokens[locale] = {}
        aliases   = @inflection_aliases[locale] = {}
        defaults  = @inflection_defaults[locale] = {}

        inflections.each_pair do |kind, tokens|
          tokens.each_pair do |token, description|
            
            # test for duplicate
            if ivars.has_key?(token)
              raise I18n::DuplicatedInflectionToken.new(ivars[token], kind, token)
            end

            # validate token's name
            if token.nil?
              raise I18n::BadInflectionToken.new(locale, token, kind)
            end

            # validate token's description
            if description.nil?
              raise I18n::BadInflectionToken.new(locale, token, kind, description)
            end

            # handle default token for a kind
            if token == :default
              if defaults.has_key?(kind) # should never happend unless someone is messing with @translations
                raise I18n::DuplicatedInflectionToken.new(kind, nil, token)
              end
              defaults[kind] = description.to_sym
              next
            end

            # handle alias
            if description.slice(0,1) == I18n::Backend::Inflector::ALIAS_MARKER
              real_token = shorten_inflection_alias(token, kind, locale)
              unless real_token.nil?
                real_token = real_token.to_sym
                aliases[token] = {}
                aliases[token][:kind]         = kind
                aliases[token][:target]       = real_token
                aliases[token][:description]  = inflections[kind][real_token].to_s
              end
              next
            end

            ivars[token] = {}
            ivars[token][:kind]         = kind.to_sym
            ivars[token][:description]  = description.to_s
          end
        end
        
        # validate defaults
        defaults.each_pair do |kind, pointer|
          unless ivars.has_key?(pointer)
            # default may be an alias
            target = aliases[pointer]
            target = target[:target] unless target.nil?
            real_token = (target || shorten_inflection_alias(:default, kind, locale))
            raise I18n::BadInflectionAlias.new(locale, :default, kind, pointer) if real_token.nil?
            defaults[kind] = real_token.to_sym            
          end
        end

        ivars
      end

    end
  end

  # This is raised when there is no kind given in options or the kind is +nil+. The kind
  # is determined by looking at token placed in a pattern.
  # 
  # When a default token for some kind is defined it will be tried before raising
  # this exception.
  # 
  # This exception will also be raised when a required option, describing token selected
  # for a kind, is empty or doesn't match any acceptable tokens.
  class InvalidOptionForKind < ArgumentError
    attr_reader :pattern, :kind, :token, :option
    def initialize(pattern, kind, token, option)
      @pattern, @kind, @token, @option = pattern, kind, token, option
      if option.nil?
        super "option #{kind.inspect} required by the " +
              "pattern #{pattern.inspect} was not found"
      else
        super "value #{option.inspect} of #{kind.inspect} required by the " +
              "pattern #{pattern.inspect} does not match any token"      
      end
    end
  end

  # This is raised when token given in pattern is invalid (empty or has no
  # kind assigned).
  class InvalidInflectionToken < ArgumentError
    attr_reader :pattern, :token
    def initialize(pattern, token)
      @pattern, @token = pattern, token
      super "token #{token.inspect} used in translation " + 
            "pattern #{pattern.inspect} is invalid"
    end
  end
  
  # This is raised when an inflection token used in a pattern does not match
  # an assumed kind determined by reading previous tokens from that pattern.
  class MisplacedInflectionToken < ArgumentError
    attr_reader :pattern, :token, :kind
    def initialize(pattern, token, kind)
      @pattern, @token, @kind = pattern, token, kind
      super "inflection token #{token.inspect} from pattern #{pattern.inspect} " +
            "is not of expected kind #{kind.inspect}"
    end
  end

  # This is raised when an inflection token of the same name is already defined in
  # inflections tree of translation data.
  class DuplicatedInflectionToken < ArgumentError
    attr_reader :original_kind, :kind, :token
    def initialize(original_kind, kind, token)
      @original_kind, @kind, @token = original_kind, kind, token
      and_cannot = kind.nil? ? "" : "and cannot be used with kind #{kind.inspect}"
      super "inflection token #{token.inspect} was already assigned " +
            "to kind #{original_kind}" + and_cannot
    end
  end

  # This is raised when an alias for an inflection token points to a token that
  # doesn't exists. It is also raised when default token of some kind points
  # to a non-existent token.
  class BadInflectionAlias < ArgumentError
    attr_reader :locale, :token, :kind, :pointer
    def initialize(locale, token, kind, pointer)
      @locale, @token, @kind, @pointer = locale, token, kind, pointer
      what = token == :default ? "default token" : "alias"
      super "the #{what} #{token.inspect} of kind #{kind.inspect} " +
            "for language #{locale.inspect} points to an unknown token #{pointer.inspect}"
    end
  end
  
  # This is raised when an inflection token or its description has a bad name. This
  # includes an empty name or a name containing prohibited characters.
  class BadInflectionToken < ArgumentError
    attr_reader :locale, :token, :kind, :description
    def initialize(locale, token, kind, description=nil)
      @locale, @token, @kind, @description = locale, token, kind, description
      if description.nil?
        super "Inflection token #{token.inspect} of kind #{kind.inspect} "+
              "for language #{locale.inspect} has a bad name"
      else
        super "Inflection token #{token.inspect} of kind #{kind.inspect} "+
              "for language #{locale.inspect} has a bad description #{description.inspect}"
      end
    end
  end

end
