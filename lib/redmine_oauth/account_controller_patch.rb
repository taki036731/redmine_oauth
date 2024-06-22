require_dependency 'account_controller'
require 'uri'

module RedmineOauth
    module AccountControllerPatch
        include OauthClient
        def self.prepended(base)
            base.class_eval do
                unloadable
            end
        end
        
        def login
            super
            unless Redmine.is_dev
                redirect_to oauth_path(back_url: back_url), allow_other_host: true
            end
        end
        
        def logout
            uri = URI.parse(oauth_client.authorize_url)
            uri.path='/v2/logout'
            uri.query = 'client_id=' + oauth_client.id + '&returnTo=' + URI.encode_www_form_component(home_url)
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

unless AccountController.ancestors.include? RedmineOauth::AccountControllerPatch
    AccountController.prepend(RedmineOauth::AccountControllerPatch)
end