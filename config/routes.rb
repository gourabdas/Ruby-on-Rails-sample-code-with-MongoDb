TestApp::Application.routes.draw do
  constraints(AdminSubdomain) do
    authenticated :admin do
      as :admin do
        root :to => 'admins/homes#index'
        match '/getstate'  => 'client/registrations#get_state', :as => :get_state

        get 'change-password'                        => 'admins/homes#change_password',                  :as => :change_password
        put 'password-changed'                       => 'admins/homes#password_changed',                 :as => :password_changed
        match 'get/asset/show'                       => 'admins/master_data#get_asset_rate_and_hour',    :as => :get_asset_rate_and_hour
        delete 'admins/asset/:id'                    => 'admins/master_data#delete_asset',               :as => :admin_delete_asset
        get 'admins/:id/asset/:type'                 => 'admins/master_data#block_unblock_assets',       :as => :block_unblock_assets, :type => /Block|Unblock/
        match 'master/data/'                         => 'admins/master_data#index',                      :as => :master_data
        get   'benchmark/data/:type'                 => 'admins/master_data#list_all_benchmark_data',    :as => :list_all_benchmark_data
        get   'benchmark/data/:type/:filter'         => 'admins/master_data#list_all_benchmark_data'
        get   'benchmark/new/:type'                  => 'admins/master_data#new_benchmark_data',         :as => :new_benchmark_data
        
        get 'benchmark-data/:type/edit/:_id'         => 'admins/master_data#edit_benchmark_data',        :as => :edit_benchmark_data

        delete 'benchmark-salary/:id/delete'         => 'admins/master_data#remove_benchmark_salary',    :as => :remove_benchmark_salary
        match 'benchmark/data/add/:type'             => 'admins/master_data#add_update_benchmark_data',  :as => :add_update_benchmark_data
        match 'benchmark/data/asset/:type'           => 'admins/master_data#add_update_asset',           :as => :add_update_asset
        match 'benchmark/data/market/:type'          => 'admins/master_data#add_update_market',          :as => :add_update_market
        match 'benchmark/data/department/:type'      => 'admins/master_data#add_update_department',      :as => :add_update_department
        match 'benchmark/data/job/:type'             => 'admins/master_data#add_update_job',             :as => :add_update_job
        match 'benchmark/data/discipline/:type'      => 'admins/master_data#add_update_discipline',      :as => :add_update_discipline
        match 'benchmark/data/metric/:type'          => 'admins/master_data#add_update_metric',          :as => :add_update_metric
        match 'benchmark/data/asset_hour/:type'      => 'admins/master_data#add_update_asset_hour',      :as => :add_update_asset_hour
        match 'benchmark/data/asset_rate/:type'      => 'admins/master_data#add_update_asset_rate',      :as => :add_update_asset_rate
        match 'benchmark/data/salary/:type'          => 'admins/master_data#add_update_benchmark_salary',:as => :add_update_benchmark_salary
        match 'benchmark/metric/:type'               => 'admins/master_data#add_update_benchmark_metric',:as => :add_update_benchmark_metric

        match 'select/asset/'                        => 'admins/master_data#select_asset_type',          :as => :select_asset_type
        match 'get/job/titles'                       => 'admins/master_data#get_jobtitles',              :as => :get_jobtitles

        delete "admins/job_titles/:id/delete"        => 'admins/master_data#delete_job_titles',          :as => :admin_delete_job_titles
        
        get 'clients/data/:type'                     => 'admins/manage_clients#index',                   :as => :manage_clients
        match 'my/account/:type'                     => 'admins/manage_clients#my_account',              :as => :my_account
        match 'get/client/data'                      => 'admins/manage_clients#get_clients_data',        :as => :get_clients_data
        match 'client/update'                        => 'admins/manage_clients#client_add_update_delete',:as => :client_add_update_delete
        match 'user/update'                          => 'admins/manage_clients#user_add_update_delete',  :as => :user_add_update_delete
        post "client/notification"                   => "admins/manage_clients#client_notification",     :as => :client_notification
                
        get "client/:id/users"                      => 'admins/manage_clients#company_users',            :as => :company_users_list
        get "client/:id/user/new"                   => 'admins/manage_clients#company_user_new',         :as => :company_user_new
        post "client/:id/user/create"               => 'admins/manage_clients#company_user_create',      :as => :company_user_create
        get "client/:id/user/:uid/edit"             => 'admins/manage_clients#company_user_edit',        :as => :company_user_edit
        put "client/:id/user/:uid/update"           => 'admins/manage_clients#company_user_update',      :as => :company_user_update
        delete "client/:id/user/:uid/delete"        => 'admins/manage_clients#company_user_delete',      :as => :company_user_delete
        get "client/:id/user/:uid/privilege"        => 'admins/manage_clients#company_user_privilege',   :as => :company_user_privilege

        match 'user/is_blocked'                      => 'admins/manage_clients#is_blocked_user',         :as => :is_blocked_user
        match 'user/permission'                      => 'admins/manage_clients#user_permission',         :as => :user_permission
        match 'user/send-notification'               => 'admins/manage_clients#send_notification',       :as => :send_notification

        match 'user-details'                         => 'admins/manage_clients#user_details',            :as => :user_details
        match 'register-user'                        => 'admins/manage_clients#create_user',             :as => :create_user
        delete 'delete-user'                         => 'admins/manage_clients#delete_user',             :as => :delete_user        
        match 'client-confirmation'                  => 'admins/manage_clients#client_confirmation',     :as => :client_confirmation

        match 'admin/report/:oper'                   => 'admins/reports#index',                          :as => :admin_reprots
        match 'get/brand'                            => 'admins/reports#get_brand_name',                 :as => :get_brand_name

        ### for importing/exporting benchmark data
        match 'export/assets'                  => 'admins/data_modifications#export_assets',            :as => :export_assets
        match 'import/assets'                  => 'admins/data_modifications#import_assets',            :as => :import_assets

        match 'export/benchmark-metrics'       => 'admins/data_modifications#export_benchmark_metrics', :as => :export_benchmark_metrics
        match 'import/benchmark-metrics'       => 'admins/data_modifications#import_benchmark_metrics', :as => :import_benchmark_metrics

        match 'export/markets'       => 'admins/data_modifications#export_markets',            :as => :export_markets
        match 'import/markets'       => 'admins/data_modifications#import_markets',            :as => :import_markets

        match 'export/departments'       => 'admins/data_modifications#export_departments',            :as => :export_departments
        match 'import/departments'       => 'admins/data_modifications#import_departments',            :as => :import_departments

        match 'export/job_titles'       => 'admins/data_modifications#export_job_titles',            :as => :export_job_titles
        match 'import/job_titles'       => 'admins/data_modifications#import_job_titles',            :as => :import_job_titles

        match 'export/disciplines'       => 'admins/data_modifications#export_discipline',            :as => :export_discipline
        match 'import/disciplines'       => 'admins/data_modifications#import_discipline',            :as => :import_discipline

        match 'export/metrics'       => 'admins/data_modifications#export_metrics',            :as => :export_metrics
        match 'import/metrics'       => 'admins/data_modifications#import_metrics',            :as => :import_metrics

        match 'export/asset_hours'       => 'admins/data_modifications#export_asset_hours',            :as => :export_asset_hours
        match 'import/asset_hours'       => 'admins/data_modifications#import_asset_hours',            :as => :import_asset_hours

        match 'export/benchmark_salaries'       => 'admins/data_modifications#export_benchmark_salaries',            :as => :export_benchmark_salaries
        match 'import/benchmark_salariess'       => 'admins/data_modifications#import_benchmark_salaries',            :as => :import_benchmark_salaries

        get "admins/:cid/client-settings" => "admins/manage_clients#client_settings", :as => :admins_client_settings
        put "admins/:cid/client-settings" => "admins/manage_clients#save_client_settings", :as => :admins_save_client_settings
        
        namespace :admins do
          get "notify-agencies" => "resources#notify_agencies", :as => :notify_agencies
          resources :resources do
            member do
              get "download"
            end
          end
          get "view-log/:type" => "resources#view_log", :as => :view_log
          post "user/resend-confirmation-instructions" => "manage_clients#resend_confirmation_instructions", :as => :resend_confirmation_instructions

          resources :supports, :except => :show do
            member do
              get "block"
              get "unblock"
            end
            post "notifications", :on => :collection
          end

          get "contents/:type" => "contents#new", :as => :contents, :type => /about-us|contact-us|privacy-policy|home/
          post "contents/:type" => "contents#create_or_update", :as => :contents, :type => /about-us|contact-us|privacy-policy|home/
          put "contents/:type" => "contents#create_or_update", :as => :contents, :type => /about-us|contact-us|privacy-policy|home/
          delete "content/:type" => "contents#destroy", :as => :content, :type => /about-us|contact-us|privacy-policy|home/
        end
        get "admins/:id/block" => "admins/manage_clients#block_unblock", :as => :admins_block
        get "admins/:id/unblock" => "admins/manage_clients#block_unblock", :as => :admins_unblock
        get "admins/:id/login-as-a-super-admin" => "admins/manage_clients#login_as_a_super_admin", :as => :login_as_a_super_admin
        delete "admins/:id/delete-metric" => "admins/master_data#delete_metric", :as => :admins_delete_metric
        post "checking-subdomain-status" => "admins/manage_clients#subdomain_status", :as => :subdomain_status

        get "client/:id/pending-registration" => "admins/manage_clients#pending_registration", :as => :pending_registration
        post "client/:id/complete-pending-registration" => "admins/manage_clients#complete_pending_registration", :as => :complete_pending_registration
      end
    end

    unauthenticated :admin do
      as :admin do
        root :to => 'admins/sessions#new'
      end
    end

    devise_for :admins, :skip => :registrations, :path_names => { :sign_in => 'login', :sign_out => 'logout' }, :controllers => { :sessions => "admins/sessions", :passwords => "admins/passwords", :unlocks => "admins/unlocks" }
    devise_scope :admins do
      get 'switch-user/:token/:subdomain' => 'admins/homes#switch_user', :as => :switch_user, :subdomain => /[A-Za-z0-9-]+/
      post 'changed-status' => 'admins/homes#changed_status', :as => :changed_status
    end
  end

  constraints(ClintSubdomain) do
    authenticated :user do
      root :to => 'client/setups#index'
      as :user do
        match 'company/profile'  => 'profiles#index', :as => :company_profile
        namespace :client do
          resources :vendors
          #resources :agencies
          resources :tickets, :except => [:index] do
            member do
              get "close"
              get "reopen"
            end
          end
          get "ticket-list"  => "tickets#index", :as => :ticket_list
          get "ticket-list/:type"  => "tickets#index", :type => /active|close/
          
          resources :brands do
            collection do
              get 'update_by_grid'
            end
          end
          
          put "comment/:tid" => "tickets#add_comment", :as => :add_comment
          put ":tid/comment/:id" => "tickets#edit_comment", :as => :edit_comment
          delete ":tid/comment/:id" => "tickets#delete_comment", :as => :delete_comment

          post 'help/post-issue' => 'download_resources#post_issue', :as => :post_issue
          
          get 'help' => 'download_resources#help', :as => :help_manual
          get 'help/user-manual' => 'download_resources#user_manual', :as => :user_manual
          get 'help/brand-manual' => 'download_resources#brand_manual', :as => :brand_manual
          get 'help/vendor-manual' => 'download_resources#vendor_manual', :as => :vendor_manual
          get 'help/plan-manual' => 'download_resources#plan_manual', :as => :plan_manual
          get 'help/track-manual' => 'download_resources#track_manual', :as => :track_manual
          get 'help/report-manual' => 'download_resources#report_manual', :as => :report_manual
          get 'help/change-password-manual' => 'download_resources#change_password_manual', :as => :change_password_manual
          
          get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
          put 'users' => 'devise/registrations#update', :as => 'user_registration' 
          resources :scope_of_works, :path => "scope-of-works", :only => [:index]
          resources :budgets, :only => [:index]
          resources :staffings, :only => [:index]

          get 'vendor/:vid/setup-contract-metrics' => 'vendors#setup_contract_metrics', :as => :setup_contract_metrics
          match 'vendor/add/contract/metrics' => 'vendors#add_contract_metrics', :as => :add_contract_metrics
          
          get 'vendor/asset/:aid' => 'vendors#get_asset_description'
          get "vendor/custom-asset/:caid" => "vendors#get_custom_asset_description"
          get 'vendor/job-title/:jtid' => 'vendors#get_job_title_description'
          match 'vendor/:country_id/get-states-and-markets' => 'vendors#get_states_markets', :as => :get_states_markets
          get ":vid/reset-vendor-hourly-rates" => "vendors#reset_job_rates", :as => :reset_job_rates
          get ":vid/reset-assets-price" => "vendors#reset_assets_price", :as => :reset_assets_price
          delete ":vid/reset-custom-assets-price" => "vendors#reset_custom_assets_price", :as => :reset_custom_assets_price
          
          resources :tracks, :only => [:index]
          get "tracks/:page" => "tracks#index"

          get ":plan_id/export-plan" => "plans#export_plan", :as => :export_plan
          post "import-plan" => "plans#import_plan", :as => :import_plan

          # For budgets
          get 'budgets/new' => 'plans#new', :as => :new_plan_budgets
          post 'budgets' => 'plans#create', :as => :create_plan_budgets
          get 'get-currency/:id' => 'plans#get_currency', :as => :get_currency
          get ':plan_id/budgets/edit' => 'budgets#edit', :as => :edit_budgets
          put ':plan_id/budgets/update' => 'budgets#update', :as => :update_budgets
          delete ':plan_id/budgets/delete' => 'budgets#destroy', :as => :delete_budgets
          match 'goto/sow/:plan_id' => 'budgets#goto_sow', :as => :goto_sow
          post "destroy/budgets" => "budgets#destroy_budgets", :as => :destroy_budgets
          post "approve/budgets" => "budgets#approve_budgets", :as => :approve_budgets
          post "budgets/:plan_id/upload-attachments" => "budgets#upload_attachments", :as => :budget_upload_attachments
          get "budgets/:plan_id/copy" => "budgets#copy_budget", :as => :copy_budget
          get "budgets/:plan_id/download-attachments" => "budgets#download_attachments", :as => :budget_download_attachments

          # For scope of works
          get 'sow/new' => 'plans#new_sow', :as => :new_plan_sow
          post 'sows' => 'plans#create_sow', :as => :create_plan_sow
          delete ':plan_id/sow/delete' => 'scope_of_works#destroy', :as => :delete_scope_of_works
          get ':plan_id/sow/edit' => 'scope_of_works#edit', :as => :edit_scope_of_work
          put ':plan_id/sow/update' => 'scope_of_works#update', :as => :update_scope_of_work
          get 'sow' => 'scope_of_works#index', :as => :list_scope_of_works
          get "scope-of-works/:page" => "scope_of_works#index"
          match 'get/all/sow' => 'scope_of_works#get_scope_of_works', :as => :get_scope_of_works
          match 'get/bechmark/price' => 'scope_of_works#get_benchmark_price', :as => :get_benchmark_price
          match ':plan_id/sow/step-2' => 'scope_of_works#sow_step_2', :as => :sow_step_2
          post ":plan_id/sow/add" => "scope_of_works#add_duplicate_sow_assets"
          match ':plan_id/sow/assets' => 'scope_of_works#add_sow_assets', :as => :add_sow_assets
          match ':plan_id/sow/step-3' => 'scope_of_works#sow_step_3', :as => :sow_step_3
          match ':plan_id/sow/assets-price' => 'scope_of_works#add_sow_assets_price', :as => :add_sow_assets_price
          match 'go/to/staffing/:plan_id' => 'scope_of_works#go_to_staffing', :as => :go_to_staffing
          get ":plan_id/refresh-staffing" => 'scope_of_works#refresh_staffing', :as => :refresh_staffing
          match 'sow/tv/asset' => 'scope_of_works#list_tv_asset', :as => :list_tv_asset
          post "destroy/scope-of-works" => "scope_of_works#destroy_sows", :as => :destroy_scope_of_works
          post "approve/scope-of-works" => "scope_of_works#approve_sows", :as => :approve_scope_of_works
          post "sow/:plan_id/upload-attachments" => "scope_of_works#upload_attachments", :as => :sow_upload_attachments
          get "sow/:plan_id/download-attachments" => "scope_of_works#download_attachments", :as => :sow_download_attachments
          get "sow/:plan_id/copy" => "scope_of_works#copy_sow", :as => :copy_sow
          
          # For staffing
          get 'staffings/new' => 'plans#new_staffing', :as => :new_plan_staffings
          post 'staffings' => 'plans#create_staffing', :as => :create_plan_staffing
          post "staffings/:plan_id/upload-attachments" => "staffings#upload_attachments", :as => :staffing_upload_attachments
          get "staffings/:plan_id/download-attachments" => "staffings#download_attachments", :as => :staffing_download_attachments
          delete ':plan_id/staffing-details/delete-all' => 'staffings#delete_all_staff_details', :as => :delete_all_staff_details
          post "destroy/staffings" => "staffings#destroy_staffings", :as => :destroy_staffings
          post "approve/staffings" => "staffings#approve_staffings", :as => :approve_staffings
          get ':plan_id/staffing-details/:index' => 'staffings#staffing_details', :index => /[0-9]+/
          post 'priorities/:index' => 'staffings#get_priorities', :index => /[0-9]+/
          post 'department/:index' => 'staffings#get_department', :index => /[0-9]+/
          post 'job-title/:index' => 'staffings#job_title', :index => /[0-9]+/
          get ':plan_id/staffings/benchmark-comp' => 'staffings#edit_benchmark_comp', :as => :edit_benchmark_comp_staffing
          put ':plan_id/staffings/benchmark-comp-update' => 'staffings#update_benchmark_comp', :as => :update_benchmark_comp_staffing
          get ':plan_id/staffings/goto-staffing' => 'staffings#goto_staffing', :as => :goto_staffing
          get ':plan_id/staffings/compensation-methodology-and-metrics' => 'staffings#compensation_methodology', :as => :compensation_methodology_staffings
          put ':plan_id/staffings/compensation-methodology-and-metrics' => 'staffings#save_compensation_methodology', :as => :save_compensation_methodology_staffings
          get ":plan_id/reset-staffing-hourly-rates" => "staffings#reset_job_rates", :as => :reset_staffing_job_rates
          get ':plan_id/staffings/create-staffing-plan' => 'staffings#add_staff', :as => :add_staff
          put ':plan_id/staffings/create-staffing-plan' => 'staffings#create_staff', :as => :create_staff
          put ':plan_id/staffings/import-staff' => 'staffings#import_staff', :as => :import_staff
          get ':plan_id/staffings/direct-base-salary-by-department' => 'staffings#direct_base_salary', :as => :direct_base_salary
          put ':plan_id/staffings/direct-base-salary-by-department' => 'staffings#add_department_direct_base_salary', :as => :add_department_direct_base_salary
          get ':plan_id/staffings/overhead-costs-estimation' => 'staffings#overhead_costs_estimation', :as => :overhead_costs_estimation
          put ':plan_id/staffings/overhead-costs-estimation' => 'staffings#save_overhead_costs_estimation', :as => :save_overhead_costs_estimation
          get ':plan_id/staffings/benchmark-assesment' => 'staffings#benchmark_assesment', :as => :benchmark_assesment
          get ':plan_id/staffings/benchmark-assesment/:compare' => 'staffings#benchmark_assesment', :compare => /Benchmark|Hybrid/, :as => :compare_benchmark_assesment
          put ':plan_id/staffings/benchmark-assesment' => 'staffings#save_benchmark_assesment', :as => :save_benchmark_assesment
          get ':plan_id/staffings/benchmark-compare/:type' => 'staffings#compare_benchmark', :type => /Benchmark|Hybrid/
          get ':plan_id/staffings/benchmark-compare/:type/:fte' => 'staffings#compare_benchmark', :type => /Benchmark|Hybrid/
          get ':plan_id/staffings/imported-staffs' => 'staffings#edit_imported_staff', :as => :edit_imported_staff
          put ':plan_id/staffings/imported-staffs' => 'staffings#update_imported_staff', :as => :update_imported_staff
          get ':plan_id/staffings/copy' => 'staffings#copy_staffing', :as => :copy_staffing
          get ':plan_id/staffings/staff-list' => 'staffings#staff_list', :as => :staff_list
          post 'get-dependent-list/:index' => 'staffings#get_dependent_list', :as => :get_dependent_list
          get ':plan_id/staffings/preview-client-data' => 'staffings#preview_client_data', :as => :preview_client_data
          post 'correct-department' => 'staffings#get_correct_department'
          post 'correct-job-title' => 'staffings#get_correct_job_title'
          delete ':plan_id/staffings/clear-imported-staffs' => 'staffings#destroy_imported_staff', :as => :clear_imported_staff
          post 'staffing-correct-department' => 'staffings#get_correct_department_staffing'
          post 'staffing-correct-job-title' => 'staffings#get_correct_job_title_staffing'

          ### for track staffing    ########################################################################
          get ':plan_id/track-staffing/update-progress' => 'tracks#track_staffing', :as => :track_staffing_update_progress
          get ':s_id/track-staffing/:tsid/compensation-methodology' => 'tracks#compensation_methodology', :as => :compensation_methodology_track
          put ':s_id/track-staffing/:tsid/compensation-methodology' => 'tracks#save_compensation_methodology', :as => :save_compensation_methodology_track
          delete ':plan_id/track-staffing-details/:tsid/delete-all' => 'tracks#delete_all_staff_details_track', :as => :delete_all_staff_details_track
          get ':s_id/track-staffings/:tsid/create-staffing-plan' => 'tracks#add_staff', :as => :add_staff_track
          put ':s_id/track-staffings/:tsid/create-staffing-plan' => 'tracks#create_staff', :as => :create_staff_track
          put ':plan_id/track-staffings/:tsid/import-staff' => 'tracks#import_staff', :as => :import_staff_track
          get ':ts_id/track-staffings/staff-list' => 'tracks#staff_list', :as => :track_staff_list
          post 'track-staffings/get-dependent-list/:index' => 'tracks#get_dependent_list'
          post 'track-staffing/priorities/:index' => 'tracks#get_priorities', :index => /[0-9]+/
          post 'track-staffing/department/:index' => 'tracks#get_department', :index => /[0-9]+/
          post 'track-staffing/job-title/:index' => 'tracks#job_title', :index => /[0-9]+/
          get ':plan_id/track-staffing-details/:index' => 'tracks#staffing_details', :index => /[0-9]+/
          get ':s_id/track-staffings/:tsid/direct-base-salary-by-department' => 'tracks#direct_base_salary', :as => :direct_base_salary_track
          put ':s_id/track-staffings/:tsid/directbase-salary-by-department' => 'tracks#add_department_direct_base_salary', :as => :add_department_direct_base_salary_track
          get ':s_id/track-staffings/:tsid/overhead-costs-estimation' => 'tracks#overhead_costs_estimation', :as => :overhead_costs_estimation_track
          put ':s_id/track-staffings/:tsid/overhead-costs-estimation' => 'tracks#save_overhead_costs_estimation', :as => :save_overhead_costs_estimation_track
          get ':s_id/track-staffings/:tsid/benchmark-assesment' => 'tracks#benchmark_assesment', :as => :benchmark_assesment_track
          get ':s_id/track-staffings/:tsid/benchmark-assesment/:compare' => 'tracks#benchmark_assesment', :compare => /Benchmark|Hybrid/, :as => :compare_benchmark_assesment_track
          put ':s_id/track-staffings/:tsid/benchmark-assesment' => 'tracks#save_benchmark_assesment', :as => :save_benchmark_assesment_track
          get ':s_id/track-staffings/:tsid/benchmark-compare/:type' => 'tracks#compare_benchmark', :type => /Benchmark|Hybrid/
          get ':s_id/track-staffings/:tsid/benchmark-compare/:type/:fte' => 'tracks#compare_benchmark', :type => /Benchmark|Hybrid/
          get ':plan_id/track-staffings/:tsid/imported-staffs' => 'tracks#edit_imported_staff', :as => :edit_imported_staff_track
          put ':plan_id/track-staffings/:tsid/imported-staffs' => 'tracks#update_imported_staff', :as => :update_imported_staff_track
          delete ':plan_id/track-staffings/:tsid/clear-imported-staffs' => 'tracks#destroy_imported_staff', :as => :clear_imported_staff_track
          get ':s_id/confirm/:tsid/change-order' => 'tracks#confirm_change_order', :as => :confirm_change_order
          get ':s_id/finalize/:tsid/change-order/:confirmation' => "tracks#finalize_changes", :as => :finalize_changes
          delete ':s_id/track-staffing/:tsid/delete' => 'tracks#delete_staffing_track', :as => :delete_staffing_track



          ## Track Scope of Works
          get ':plan_id/change-order/cancel'                => 'track_scope_of_works#cancel_change_order',                :as => :cancel_change_order
          get ':plan_id/tsow/edit'                          => 'track_scope_of_works#edit',                               :as => :edit_track_scope_of_work
          put ':plan_id/tsow/update'                        => 'track_scope_of_works#update',                             :as => :update_track_scope_of_work
          get ':plan_id/tsow/step-2'                        => 'track_scope_of_works#sow_step_2',                         :as => :track_sow_step_2
          post ':plan_id/tsow/assets'                       => 'track_scope_of_works#add_sow_assets',                     :as => :track_add_sow_assets
          get ':plan_id/tsow/step3'                         => 'track_scope_of_works#sow_step_3',                         :as => :track_sow_step_3
          post ':plan_id/tsow/assets-price'                 => 'track_scope_of_works#add_sow_assets_price',               :as => :track_add_sow_assets_price
          post ':sow_id/add-duplicate-sow-assets/:tsow_id'  => 'track_scope_of_works#add_duplicate_sow_assets',           :as => :add_duplicate_assets
          post ':plan_id/track/import-plan'                 => 'track_scope_of_works#import_plan',                        :as => :track_import_plan
          
          ## Tracks
          match 'track/plan/progress/'                  => 'tracks#track_progress',           :as => :track_progress
          match 'track/sow/progress/'                   => 'tracks#track_sow',                :as => :track_sow
          get ":plan_id/track-staffing/history"         => "tracks#track_history",            :as => :track_history
          get ":plan_id/track-staffing/:tsid/preview"   => 'tracks#preview_track_history',    :as => :preview_track_history
          get ":plan_id/track-staffing/change-order"    => "tracks#change_order",             :as => :track_staffing_change_order
          post ":plan_id/track-staffing/track-change"   => "tracks#create_track_change",      :as => :create_track_change
          match 'track/plan/change'                     => 'tracks#track_change',             :as => :track_change
          match 'show-change-order/:plan_id'            => 'tracks#show_change_order',        :as => :show_change_order
          post ":plan_id/track-staffing/import-plan"    => 'tracks#import_plan',              :as => :update_progress_import_plan
          
          ## Setups
          get 'company/setup' => 'setups#company_edit', :as => :company_setup
          put 'company/update' => 'setups#company_update', :as => :company_update
          get 'company/user' => 'setups#company_user', :as => :company_user
          get 'company/user/:page' => 'setups#company_user'
          get 'company/user-edit/:id' => 'setups#company_user_edit', :as => :company_user_edit
          put 'company/user-update/:id' => 'setups#company_user_update', :as => :company_user_update
          delete 'company/user-delete/:id' => 'setups#company_user_delete', :as => :company_user_delete
          get 'company/new-user' => 'setups#new_user', :as => :company_new_user
          post 'company/create-user' => 'setups#create_user', :as => :company_create_user
          get "user/:id/manage-status" => 'setups#block_unblock_user', :as => :block_unblock_user
          match 'user'      => 'setups#user_add_update_delete',            :as => :user_add_update_delete
          match 'track/budget/progress/'   => 'track_budgets#track_budget',   :as => :track_budget
          match 'track/budget/create/:plan_id'   => 'track_budgets#create_track_budget',   :as => :create_track_budget
          delete ":plan_id/track-staffing/close-job" => "tracks#close_job", :as => :close_job
          delete ":plan_id/track-staffing/delete" => "tracks#destroy", :as => :destroy_job
          
          ### for reports ########################################################################
          get "admin-reports" => "reports#index", :as => :admin_reports
          post "admin-report" => "reports#admin_report", :as => :admin_report
          post "export-admin-report" => "reports#export_admin_report", :as => :export_admin_report
          get "brand-reports" => "reports#brand", :as => :brand_reports
          post "get-organized-by-details" => "reports#get_organized_by_details", :as => :get_organized_by_details
          post "brand-report" => "reports#brand_report", :as => :brand_report
          post "export-brand-report" => "reports#export_brand_report", :as => :export_brand_report
          get "agency-reports" => "reports#agency", :as => :agency_reports
          post "agency-report" => "reports#agency_report", :as => :agency_report
          post "export-agency-report" => "reports#export_agency_report", :as => :export_agency_report
          get "asset-reports" => "reports#asset", :as => :asset_reports
          post "asset-report" => "reports#asset_report", :as => :asset_report
          post "export-asset-report" => "reports#export_asset_report", :as => :export_asset_report
          
          match 'Find_plan'      => 'reports#find_plan',            :as => :report_find_plan_by_plan_no
          match 'Find-plan-by-brand'      => 'reports#find_plan_by_brand',            :as => :report_find_plan_by_brand
          match 'show-plan-by-brand'      => 'reports#show_plan_by_brand',            :as => :show_report_by_brand
          match 'Find-plan-by-vendor'      => 'reports#find_plan_by_vendor',            :as => :find_plan_by_vendor
          match 'show-plan-by-vendor'      => 'reports#show_plan_by_vendor',            :as => :show_report_by_vendor
          match 'Find-plan-by-date'      => 'reports#find_plan_by_date',            :as => :find_plan_by_date
          match 'show-plan-by-date'      => 'reports#show_plan_by_date',            :as => :show_plan_by_date

          
          get '/resources' => 'download_resources#index', :as => :download_resources
          get 'resources/:page' => 'download_resources#index'
          get '/resources/download/:id' => 'download_resources#download', :as => :download_file

          match 'company/agency/:id' => 'agencies#is_blocked', :as => :agency_is_blocked

          ### for benchmark reports ########################################################################
          get "benchmarks" => "benchmarks#benchmark_reports", :as => :benchmarks
          post "get-benchmark-reports" => "benchmarks#get_benchmark_report", :as => :get_benchmark_report
          post "export-benchmark-salaries" => "benchmarks#export_benchmark_salaries", :as => :export_benchmark_salaries
          post "get-department-collections" => "benchmarks#get_department_collections", :as => :get_department_collections
          post "get-job_title-collections" => "benchmarks#get_job_title_collections", :as => :get_job_title_collections
          post "get-assets-collections" => "benchmarks#get_assets_collections", :as => :get_assets_collections
          get "comparison" => "benchmarks#comparison_reports", :as => :comparison_reports
          post "get-comparison-reports" => "benchmarks#get_comparison_report", :as => :get_comparison_report
          post "export-comparison-salaries" => "benchmarks#export_comparison_salaries", :as => :export_comparison_salaries
          get "benchmarks/job-title-description/:jtid" => "benchmarks#get_jobtitle_description"
          get "benchmarks/asset-description/:aid" => "benchmarks#get_asset_description"

          resources :assets

          resources :settings, :only => :index do
            collection do
              post :historical_benchmark_parameters
              post :exchange_rates
              post :import_templates
              get  :add_custom_rate
            end
          end
        end
      end
    end

    unauthenticated :user do
      as :user do
        root :to => 'pages#index'
      end
    end
    
    devise_for :users, :path_names => { :sign_in => "login", :sign_out => "logout" }, :controllers => { :registrations => "client/registrations", :sessions => "client/sessions", :confirmations => "client/confirmations", :passwords => "client/passwords", :unlocks => "client/unlocks" }
    devise_scope :user do
      get "valid-user/:token" => "client/sessions#valid_user", :as => :valid_user
      match "/getstate"  => "client/registrations#get_state", :as => :get_state
      match "create_user"  => "client/registrations#create_user", :as => :create_user
    end

    get "about-rightspend"            => 'pages#about',                 :as => :about_rightspend
    get "contact-us"                  => 'pages#contact',               :as => :contact_us
    post "create-user"                => "pages#create_user",           :as => :create_user

    authenticated :agency do
      as :agency do
        get "agency" => "agencies/vendor_agencies#index", :as => :agency_root
        get "agency/users" => "agencies/vendor_agencies#agency_users", :as => :agency_users
        get "agency/users/:page" => "agencies/vendor_agencies#agency_users"
        get "agency/client" => "agencies/vendor_agencies#client_details", :as => :agencies_client_details
        namespace :agencies do
          resources :vendor_agencies

          get ":plan_id/export-plan" => "vendor_agencies#export_plan", :as => :export_plan
          get "scope-of-works" => "scope_of_works#index", :as => :scope_of_works
          get "scope-of-works/:page" => "scope_of_works#index"
          get "scope-of-work/new" => "scope_of_works#new", :as => :new_scope_of_work
          post "scope-of-works" => "scope_of_works#create", :as => :create_scope_of_work
          get ":plan_id/scope-of-work/edit" => "scope_of_works#edit", :as => :edit_scope_of_work
          put ":plan_id/scope-of-work/update" => "scope_of_works#update", :as => :update_scope_of_work
          get ":plan_id/scope-of-work/step-2" => "scope_of_works#sow_step_2", :as => :step_2_scope_of_work
          post ":plan_id/scope-of-work/assets" => "scope_of_works#add_sow_assets", :as => :assets_scope_of_work
          post ":plan_id/scope-of-work/add" => "scope_of_works#add_duplicate_sow_assets"
          get ":plan_id/scope-of-work/step-3" => "scope_of_works#sow_step_3", :as => :step_3_scope_of_work
          post ":plan_id/scope-of-work/assets-price" => "scope_of_works#add_sow_assets_price", :as => :add_sow_assets_price
          get ":plan_id/scope-of-work/go-to-staffing" => "scope_of_works#go_to_staffing", :as => :go_to_staffing
          delete ":plan_id/scope-of-work/delete" => "scope_of_works#destroy", :as => :delete_scope_of_work
          get ":plan_id/scope-of-work/submit" => "scope_of_works#submit", :as => :submit
          
          get "staffing-plans" => "staffing_plans#index", :as => :staffing_plans
          delete ":plan_id/staffing-plans/delete" => "staffing_plans#destroy", :as => :delete_staffings
          get ":plan_id/staffing-plans/copy" => "staffing_plans#copy_staffing", :as => :copy_staffing
          get ":plan_id/staffing-plans/submit" => "staffing_plans#submit_plan", :as => :submit_plan
          post ":plan_id/staffing-plans/upload-attachments" => "staffing_plans#upload_attachments", :as => :staffing_upload_attachments
          get ":plan_id/staffing-plans/download-attachments" => "staffing_plans#download_attachments", :as => :staffing_download_attachments
          
          get ":plan_id/staffing-plans/goto" => "staffing_plans#goto_staffing", :as => :goto_staffing
          get "staffing-plans/new" => "staffing_plans#new", :as => :new_staffing_plan
          post "staffing-plans/create" => "staffing_plans#create", :as => :create_staffing_plan
          get ":plan_id/staffing-plans/compensation-methodology-and-metrics" => "staffing_plans#compensation_methodology", :as => :compensation_methodology
          put ":plan_id/staffing-plans/compensation-methodology-and-metrics" => "staffing_plans#save_compensation_methodology", :as => :save_compensation_methodology_staffings
          get ":plan_id/staffing-plans/reset-staffing-hourly-rates" => "staffing_plans#reset_job_rates", :as => :reset_staffing_plan_job_rates
          get ":plan_id/staffing-plans/create-staffing-plan" => "staffing_plans#add_staff", :as => :add_staff
          put ":plan_id/staffing-plans/create-staffing-plan" => "staffing_plans#create_staff", :as => :create_staff
          put ":plan_id/staffing-plans/import-staff" => "staffing_plans#import_staff", :as => :import_staff
          get ":plan_id/staffing-plans/imported-staffs" => "staffing_plans#edit_imported_staff", :as => :edit_imported_staff
          put ":plan_id/staffing-plans/imported-staffs" => "staffing_plans#update_imported_staff", :as => :update_imported_staff
          get ":plan_id/staffing-plans/direct-base-salary-by-department" => "staffing_plans#direct_base_salary", :as => :direct_base_salary
          put ":plan_id/staffing-plans/direct-base-salary-by-department" => "staffing_plans#add_department_direct_base_salary", :as => :add_department_direct_base_salary
          get ":plan_id/staffing-plans/overhead-costs-estimation" => "staffing_plans#overhead_costs_estimation", :as => :overhead_costs_estimation
          put ":plan_id/staffing-plans/overhead-costs-estimation" => "staffing_plans#save_overhead_costs_estimation", :as => :save_overhead_costs_estimation
          get ":plan_id/staffing-plans/save-and-finalize" => "staffing_plans#preview_client_data", :as => :preview_client_data
          put ":plan_id/staffing-plans/save-and-finalize" => "staffing_plans#save_benchmark_assesment", :as => :save_benchmark_assesment
          
          get ":plan_id/staffing-plans/staff-list" => "staffing_plans#staff_list", :as => :staff_list
          get ":plan_id/staffing-plans/:index/staff" => "staffing_plans#staffing_details", :index => /[0-9]+/
          post "priorities/:index" => "staffing_plans#get_priorities", :index => /[0-9]+/
          post "department/:index" => "staffing_plans#department", :index => /[0-9]+/
          post "job-title/:index" => "staffing_plans#job_title", :index => /[0-9]+/
          post "dependent-list/:index" => "staffing_plans#dependent_list", :as => :get_dependent_list, :index => /[0-9]+/
          post "correct-department" => "staffing_plans#get_correct_department"
          post "correct-job-title" => "staffing_plans#get_correct_job_title"
          delete ":plan_id/staffing-plans/clear-imported-staffs" => "staffing_plans#destroy_imported_staff", :as => :clear_imported_staff
          delete ":plan_id/staff/delete-all" => "staffing_plans#delete_all_staff_details", :as => :delete_all_staff_details
          get "job-title-description/:jtid" => "staffing_plans#get_job_title_description"
        end
        match 'is_blocked/:id'=> 'agencies/vendor_agencies#is_blocked',    :as => :is_blocked
      end
    end

    devise_for :agencies, :path_names => { :sign_in => "login", :sign_out => "logout" }, :controllers => { :sessions => "agencies/sessions", :confirmations => "agencies/confirmations", :registrations => "agencies/registrations", :passwords => "agencies/passwords", :unlocks => "agencies/unlocks" }
    devise_scope :agency do
      get "valid-agency/:token" => "agencies/sessions#valid_agency", :as => :valid_agency_user
    end
  end

  constraints(SupportSubdomain) do
    authenticated :support do
      as :support do
        root :to => "supports/tickets#index"
        namespace :supports, :path => "" do
          resources :support_users, :path => "profile", :only => [:edit, :update] do
            member do
              get "change-password", :action => "change_password", :as => :change_password
              put "update-password", :action => "update_password", :as => :update_password
            end
          end
          resources :tickets, :only => [:show] do
            member do
              get "close"
              get "reopen"
            end
            post "comment/create" => "tickets#add_comment", :as => :add_comment
            put "comment/:id" => "tickets#edit_comment", :as => :edit_comment
            delete "comment/:id" => "tickets#delete_comment", :as => :delete_comment
          end
          get "ticket-list" => "tickets#index", :as => :ticket_list
          get "ticket-list/:type" => "tickets#index", :type => /active|close/
        end
      end
    end
    match "getstate" => "supports/support_users#get_state", :as => :get_state
    unauthenticated :support do
      as :support do
        root :to => "supports/sessions#new"
      end
    end
    devise_for :supports, :path_names => { :sign_in => "login", :sign_out => "logout" }, :skip => [:registrations], :controllers => { :sessions => "supports/sessions", :passwords => "supports/passwords", :unlocks => "supports/unlocks" }
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  constraints(OnlyAjaxRequest) do
    get "timeout/:scope", :to => "errors#index", :scope => /user|agency|support|admin/
  end
  
  match "*p", :to => "errors#show", :as => :show_exception
end
