# frozen_string_literal: true

require 'digest/sha2'

module I18n
  module Backend
    # Backend for a key-value store that automatically loads
    # its contents from Ruby or YAML files on the I18n load path.
    # Since the same source translation files are used, this backend is a
    # fully compatible drop-in replacement for the Simple backend.
    #
    # Compared to the Simple backend, this backend can reduce memory usage,
    # since translations are loaded to a key-value store instead of a Hash.
    #
    # It can also reduce startup time, since source translation files are
    # only reloaded when the file contents change.
    class FileKeyValue < KeyValue
      def initialize(store, subtrees = true, path_roots = nil)
        super(store, subtrees)
        @path_roots = path_roots
      end

      def load_translations(*filenames)
        translations = buffer { super }
        return if translations.empty?
        with_transaction do
          translations.each do |locale, data|
            backend_store_translations(locale, data)
          end
        end
      end

      alias reload! load_translations
      alias init_translations load_translations

      alias backend_store_translations store_translations

      # Store translations to buffer if available.
      def store_translations(locale, data, options = EMPTY_HASH)
        if @buffer
          @buffer.store_translations(locale, data, options)
        else
          super
        end
      end

      protected

      # Track loaded translation files in the `i18n.load_file` scope,
      # and skip loading the file if its contents are still up-to-date.
      def load_file(filename)
        key = escape_default_separator(normalized_path(filename))
        old_mtime, old_digest = lookup(:i18n, key, :load_file)
        return if (mtime = File.mtime(filename).to_i) == old_mtime ||
                  (digest = Digest::SHA2.file(filename).hexdigest) == old_digest
        super
        store_translations(:i18n, load_file: { key => [mtime, digest] })
      end

      # Translate absolute filename to relative path for i18n key
      # to make the cached i18n data portable across environments.
      def normalized_path(file)
        return file unless @path_roots
        path = @path_roots.find(&file.method(:start_with?)) ||
               raise(InvalidLocaleData.new(file, 'outside expected path roots'))
        file.sub(path, @path_roots.index(path).to_s)
      end

      # Buffer all translations loaded within the provided block,
      # using an in-memory hash from a Backend::Simple instance.
      def buffer
        @buffer = I18n::Backend::Simple.new
        yield if block_given?
        @buffer.send(:translations)
      ensure
        @buffer = nil
      end

      # Call block with store#transaction if available.
      def with_transaction(&block)
        store.respond_to?(:transaction) ? store.transaction(&block) : yield
      end
    end
  end
end
