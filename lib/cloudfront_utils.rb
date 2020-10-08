module CloudfrontUtils
  def create_invalidation(subdomain, paths)
    Client.instance.create_invalidation(subdomain, paths)
  end

  class Client
    include Singleton

    # paths must begin with a slash and are case-sensitive
    def create_invalidation(subdomain, paths)
      begin
        client.create_invalidation({
          distribution_id: distribution_id(subdomain),
          invalidation_batch: {
            paths: { # required
              quantity: paths.count,
              items: paths,
            },
            caller_reference: caller_reference,
          },
        })
      rescue StandardError => e
        Honeybadger.notify(e, context: {subdomain: subdomain, paths: paths})
      end
    end

    private

    # A unique string that identifies the request
    def caller_reference
      Time.current.to_s(:underscored_iso_date_then_time)
    end

    def distribution_id(subdomain)
      mapping = YAML.load_file(File.join(Rails.root, FileSystemPathManager.cloudfront_subdomain_distribution_id_mappings))
      mapping.fetch(subdomain)
    end

    def client
      Aws::CloudFront::Client.new(
        region: 'us-east-1',
        credentials: credentials,
      )
    end

    def credentials
      Aws::Credentials.new(
        Rails.application.secrets[:aws][:cloudfront_access_key_id],
        Rails.application.secrets[:aws][:cloudfront_secret_access_key]
      )
    end

  end

end
