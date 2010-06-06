require 'cgi'
require 'json'

module Ci
  class Server < Sinatra::Application
    attr_reader :repository, :targets

    def initialize(repository, targets)
      @repository = repository
      @targets    = targets
      super()
    end

    set :views, File.expand_path('../../views', __FILE__)

    get '/' do
      @builds = Build.all
      erb :builds
    end

    post '/' do
      result = build_all
      Rack::Response.new(result.to_json, 200).finish
    end

    protected

      def build_all
        payload = map_from_github(params[:payload])
        targets.inject({}) do |result, target|
          result.merge(target => build_remote(target, payload))
        end
      end

      def build_remote(target, payload)
        # should probably spawn a process per target here
        build = `curl -sd payload=#{CGI.escape(payload.to_json)} #{target} 2>&1`
        finished(target, build)
        build
      end

      def finished(target, build)
        attributes = JSON.parse(build).merge(:target => target, :created_at => Time.now)
        Build.new(attributes).save
      end

      # thanks, Bobette
      def map_from_github(payload)
        payload = JSON.parse(payload)
        payload.delete("before")
        payload["scm"]    = "git"
        payload["uri"]    = git_uri(payload.delete("repository"))
        payload["branch"] = payload.delete("ref").split("/").last
        payload["commit"] = payload.delete("after")
        payload
      end

      def git_uri(repository)
        URI(repository["url"]).tap { |u| u.scheme = "git" }.to_s
      end
  end
end