require_dependency 'settings_controller'

module RedmineOauth
    module SettingsControllerPatch
        def self.prepended(base)
            base.class_eval do
                unloadable
            end
            # SettingsController.prepend(SettingsControllerPatch)
        end
        
        def edit
            super
            if Redmine.is_dev
                @tabs = view_context.administration_settings_tabs
            else
                @tabs = customize
            end
            # render :action => 'customize'
        end

        private

        def customize
            customized_tabs = [
            {:name => 'general', :partial => 'settings/general', :label => :label_general},
            {:name => 'display', :partial => 'settings/display', :label => :label_display},
            {:name => 'projects', :partial => 'settings/projects', :label => :label_project_plural},
            {:name => 'users', :partial => 'settings/users', :label => :label_user_plural},
            {:name => 'issues', :partial => 'settings/issues', :label => :label_issue_tracking},
            {:name => 'timelog', :partial => 'settings/timelog', :label => :label_time_tracking},
            {:name => 'attachments', :partial => 'settings/attachments',
            :label => :label_attachment_plural},
            ]
        end
    end
end

unless SettingsController.ancestors.include? RedmineOauth::SettingsControllerPatch
    SettingsController.prepend(RedmineOauth::SettingsControllerPatch)
end