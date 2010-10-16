module Test
  class << self
    def setup_rufus_tokyo
      require 'rubygems'
      require 'rufus/tokyo'
    rescue LoadError => e
      puts "can't use KeyValue backend because: #{e.message}"
    end
  end
end
