require "rack/offline"

module Rails
  class Offline < ::Rack::Offline
    def self.call(env)
      @app ||= new
      @app.call(env)
    end

    def initialize(options = {}, app = Rails.application, &block)
      config = app.config
      root   = config.paths['public'].first
      block  = cache_block(Pathname.new(root)) unless block_given?

      opts = {
        :cache  => config.cache_classes,
        :root   => root,
        :logger => Rails.logger
      }.merge(options)

      super(opts, &block)
    end

  private

    def cache_block(root)
      Proc.new do
        
        manifest_path = File.join(
          [Rails.public_path, Rails.configuration.assets.manifest, 'manifest.yml'].compact
        )

        assets_root = [
          Rails.configuration.action_controller.asset_host, 
          Rails.configuration.assets.prefix
        ].join('')
        
        YAML.load_file(manifest_path).values.each do |file|
          cache [assets_root, file].join('/')
        end

        network "*"
      end
    end
  end
end