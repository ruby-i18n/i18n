require 'i18n/backend/base'
begin
  require 'json'
rescue LoadError => e
  puts "To use the JSON backend with i18n you need the `json` gem."
  raise e
end

module I18n
  module Backend
    module JSON

      protected

      def load_json(filename)
        ::JSON.load ::File.read(filename)
      end
    end
  end
end

