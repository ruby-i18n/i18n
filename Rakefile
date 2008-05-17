require 'rubygems'
gem 'echoe', '>=2.7.7'
require 'echoe'

# Run 'rake -T' to see list of generated tasks (from gem root directory)
echoe = Echoe.new('i18n') do |p| # what ppl will type to install your gem
  p.author = ['Sven Fuchs','Matt Aimonetti', 'Stephan Soller', 'Saimon Moore']
  p.email = "rails-patch-i18n@googlegroups.com"
  p.summary = "Add Internationalization to your Ruby app"
  p.url = 'http://i18n.rubyforge.org'
  # p.docs_host = "l10n.rubyforge.org:~/www/files/doc/"
  p.rdoc_pattern = ['README', 'LICENSE', 'CHANGELOG', 'lib/**/*.rb', 'doc/**/*.rdoc']
  p.ignore_pattern = /^(pkg|site|projects|doc|log)|CVS|.svn|.git|\.log/
  p.ruby_version = '>=1.8.4'
  #p.dependencies = ['gem_plugin >=0.2.3']
  p.extension_pattern = nil
  p.clean_pattern |= ['**/.*.sw?', '*.gem', '.config', '**/.DS_Store']  #An array of file patterns to delete on clean.
  p.test_pattern = ["spec/**/*_spec.rb"]
  p.rdoc_options = ['--quiet', '--title', 'l10n documentation', "--opname", "index.html",
                    "--line-numbers", "--main", "README", "--inline-source"]
end

Dir['tasks/**/*.rake'].each { |rake| load rake }