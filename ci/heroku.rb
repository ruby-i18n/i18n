class Heroku
  STACKS = {
    '186' => 'aspen-mri-1.8.6',
    '187' => 'bamboo-ree-1.8.7',
    '191' => 'bamboo-mri-1.9.1'
  }

  class << self
    def each_stack(&block)
      Heroku::STACKS.keys.each(&block)
    end

    def server(name, stack = '187')
      new('server', name, stack).setup
    end

    def client(name, stack = '187')
      new('client', name, stack).setup
    end
  end

  attr_reader :type, :name, :version

  def initialize(type, name, version)
    @type, @name, @version = type, name, version
  end

  def setup
    create_app unless app_exists?
    add_remote unless remote_exists?
    branch
    push
  end

  def app
    "ci-#{name}" + (type == 'client' ? "-#{type}-#{version}" : '' )
  end

  def url
    "http://#{app}.heroku.com"
  end

  def app_exists?
    apps.include?(app)
  end

  def remote_exists?
    remotes.include?(app)
  end

  def create_app
    puts "creating #{app} ..."
    `heroku create #{app} --stack #{STACKS[version]}`
  end

  def add_remote
    puts "adding git remote"
    `git remote add #{app} git@heroku.com:#{app}.git`
  end

  def push
    puts "pushing ci-#{type} to #{app} ..."
    `git push #{app} ci-#{type}:master --force`
    `git co master`
    `git branch -D ci-#{type}`
    `rm -f Gemfile config.ru > /dev/null`
  end

  def branch
    puts "setting up ci-#{type} branch ..."
    `git co -b ci-#{type}`
    `cp ci/#{type}.ru config.ru`
    `cp ci/Gemfile Gemfile`
    `git add config.ru Gemfile`
    `git commit -m 'ci #{type}'`
  end

  def apps
    puts "check for #{app} ..."
    @apps ||= `heroku list`.split("\n").map { |name| name.split(/\s/).first }
  end

  def remotes
    @remotes ||= `git remote`.split("\n")
  end
end