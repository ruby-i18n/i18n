def bundle_check
  `bundle check` == "Resolving dependencies...\nThe Gemfile's dependencies are satisfied\n"
end

command  = 'bundle exec ruby -w -Ilib -Itest test/all.rb'
gemfiles = %w(Gemfile) + Dir['gemfiles/Gemfile*'].reject { |f| f.end_with?('.lock') }

results = gemfiles.map do |gemfile|
  puts "BUNDLE_GEMFILE=#{gemfile}"
  ENV['BUNDLE_GEMFILE'] = File.expand_path("../../#{gemfile}", __FILE__)

  unless bundle_check
    puts "bundle install"
    system('bundle install')
  end

  puts command
  system command
end

exit(results.inject(true) { |a, b| a && b })
