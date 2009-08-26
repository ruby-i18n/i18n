# encoding: utf-8

module I18n
  module Helpers
    # Implements classical Gettext style accessors. To use this include the
    # module to the global namespace or wherever you want to use it.
    #
    #   include I18n::Helpers::Gettext
    module Gettext
      def _(msgid, options = {})
        I18n.t(msgid, { :default => msgid, :separator => '|' }.merge(options))
      end

      def sgettext(msgid, separator = '|')
        scope, msgid = I18n::Gettext.extract_scope(msgid, separator)
        I18n.t(msgid, :scope => scope, :default => msgid)
      end

      def pgettext(msgctxt, msgid, separator = I18n::Gettext::CONTEXT_SEPARATOR)
        sgettext([msgctxt, msgid].join(separator), separator)
      end

      def ngettext(msgid, msgid_plural, n = 1)
        nsgettext(msgid, msgid_plural, n, nil)
      end

      def nsgettext(msgid, msgid_plural, n = 1, separator = nil)
        scope, msgid = I18n::Gettext.extract_scope(msgid, separator)
        default = { :one => msgid, :other => msgid_plural }
        msgid = [msgid, I18n::Gettext::PLURAL_SEPARATOR, msgid_plural].join
        I18n.t(msgid, :default => default, :count => n, :scope => scope)
      end
    end
  end
end
