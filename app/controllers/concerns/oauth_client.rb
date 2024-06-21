module OauthClient
  extend ActiveSupport::Concern

  def oauth_client
    return @client if @client

    site = Setting.plugin_redmine_oauth[:site]&.chomp('/')
    raise StandardError, l(:oauth_invalid_provider) unless site

    @client =
      case Setting.plugin_redmine_oauth[:oauth_name]
      when 'Azure AD'
        OAuth2::Client.new(
          Setting.plugin_redmine_oauth[:client_id],
          Setting.plugin_redmine_oauth[:client_secret],
          site: site,
          authorize_url: "/#{Setting.plugin_redmine_oauth[:tenant_id]}/oauth2/authorize",
          token_url: "/#{Setting.plugin_redmine_oauth[:tenant_id]}/oauth2/token"
        )
      when 'GitLab'
        OAuth2::Client.new(
          Setting.plugin_redmine_oauth[:client_id],
          Setting.plugin_redmine_oauth[:client_secret],
          site: site,
          authorize_url: '/oauth/authorize',
          token_url: '/oauth/token'
        )
      when 'Google'
        OAuth2::Client.new(
          Setting.plugin_redmine_oauth[:client_id],
          Setting.plugin_redmine_oauth[:client_secret],
          site: site,
          authorize_url: '/o/oauth2/v2/auth',
          token_url: 'https://oauth2.googleapis.com/token'
        )
      when 'Keycloak'
        OAuth2::Client.new(
          Setting.plugin_redmine_oauth[:client_id],
          Setting.plugin_redmine_oauth[:client_secret],
          site: site,
          authorize_url: "/realms/#{Setting.plugin_redmine_oauth[:tenant_id]}/protocol/openid-connect/auth",
          token_url: "/realms/#{Setting.plugin_redmine_oauth[:tenant_id]}/protocol/openid-connect/token"
        )
      when 'Okta'
        OAuth2::Client.new(
          Setting.plugin_redmine_oauth[:client_id],
          Setting.plugin_redmine_oauth[:client_secret],
          site: site,
          authorize_url: "/oauth2/#{Setting.plugin_redmine_oauth[:tenant_id]}/v1/authorize",
          token_url: "/oauth2/#{Setting.plugin_redmine_oauth[:tenant_id]}/v1/token"
        )
      when 'Custom'
        OAuth2::Client.new(
          Setting.plugin_redmine_oauth[:client_id],
          Setting.plugin_redmine_oauth[:client_secret],
          site: site,
          authorize_url: Setting.plugin_redmine_oauth[:custom_auth_endpoint],
          token_url: Setting.plugin_redmine_oauth[:custom_token_endpoint]
        )
      else
        raise StandardError, l(:oauth_invalid_provider)
      end
  end
end