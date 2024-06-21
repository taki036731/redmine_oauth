require_dependency 'account_controller'
require 'uri'

module RedmineOauth
    module AccountControllerPatch
        include OauthClient
        def self.included(base)
            base.class_eval do
                unloadable
                AccountController.prepend(AccountControllerPatch)
            end
        end
        
        def login
            super
            if ENV['EWS_REDMINE_DEV'] != 'True'
                redirect_to oauth_path(back_url: back_url), allow_other_host: true
            end
            # redirect_to 'https://www.google.co.jp?back_url=' + params[:back_url], allow_other_host: true
        end
        
        def logout
            uri = URI.parse(oauth_client.authorize_url)
            uri.path='/v2/logout'
            uri.query = 'client_id=' + oauth_client.id + '&returnTo=' + URI.encode_www_form_component(home_url)
            Rails.logger.debug(uri.to_s)
            Rails.logger.debug('######### Auth source ID = "' + User.current.auth_source_id.to_s + '"')
            is_system_user = User.current.auth_source_id.nil? || User.current.auth_source_id.blank?

            if User.current.anonymous?
                redirect_to home_url
            elsif request.post?
                logout_user
                if is_system_user
                    Rails.logger.debug('Redirect to ' + home_url)
                    redirect_to home_url
                else
                    Rails.logger.debug('Redirect to ' + uri.to_s)
                    redirect_to uri.to_s, allow_other_host: true
                end
            end
        end
    end
end

unless AccountController.included_modules.include? RedmineOauth::AccountControllerPatch
    AccountController.prepend(RedmineOauth::AccountControllerPatch)
end