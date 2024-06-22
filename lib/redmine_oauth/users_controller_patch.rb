module RedmineOauth
    module UsersControllerPatch
        def self.prepended(base)
            base.class_eval do
                unloadable
            end
        end
        
        def edit
            if can_update
                super
            else
                render_403
            end
        end

        def update
            if can_update
                super
            else
                render_403
            end
        end

        def destroy
            if can_update
                super
            else
                render_403
            end
        end

        def bulk_destroy
            unless params[:ids].include?("1")
                super
            else
                render_403
            end
        end

        private

        def can_update
            return Redmine.is_dev || User.current.id == 1 || params[:id] != "1"
        end
    end
end

unless UsersController.ancestors.include? RedmineOauth::UsersControllerPatch
    UsersController.prepend(RedmineOauth::UsersControllerPatch)
end