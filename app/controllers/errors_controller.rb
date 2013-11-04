class ErrorsController < ApplicationController
  include ::Routes
  prepend_before_filter :only => [:index] do
    request.env["devise.skip_trackable"] = true
  end

  def index
    timeout = true
    warning = false
    catch(:warden){
      timeout = send("#{params[:scope]}_signed_in?".to_sym) == true ? false : true
      unless timeout
        last_request_at = warden.session("#{params[:scope]}".to_sym)["last_request_at"]
        warning = true if send("current_#{params[:scope]}".to_sym).timedout?(last_request_at - 10.minutes)
      end
    }
    resp = { :timeout => timeout, :warning => warning }
    
    if timeout
      flash[:error] = "Your session expired, please sign in again to continue."
      resp.merge!(:path => case params[:scope];when "user";"/users/login";when "agency";"/agencies/login";else;"/";end)
    end

    render :json => resp
  end
  
  def show
    path = "/#{params[:p]}"
    subdomain = current_subdomain
    case subdomain
    when "admin"
      if valid?(path) && !current_admin
        session["admin_return_to"] = path
        flash[:error] = "Login required."
        redirect_to root_path
      else
        render :file => "/errors/show.html.erb", :status => 404, :layout => "admins"
      end
    when "support"
      if valid?(path) && !current_support
        session["support_return_to"] = path
        flash[:error] = "Login required."
        redirect_to root_path
      else
        render :file => "/errors/show.html.erb", :status => 404, :layout => "support"
      end
    when "www", "", nil
      if valid?(path)
        flash[:error] = "Login required."
        redirect_to new_user_session_path
      else
        render :file => "/errors/show.html.erb", :status => 404, :layout => "application"
      end
    else
      unless Company.where(:subdomain => /^#{subdomain}$/i).first.present?
        render "show", :status => 404, :layout => "application"
      else
        if valid?(path)
          if path.match(/\/agencies|agency/).present?
            if current_agency
              render :file => "/errors/show.html.erb", :status => 404, :layout => "application"
            else
              session["agency_return_to"] = path
              flash[:error] = "Login required."
              redirect_to new_agency_session_path
            end
          else
            if current_user
              render :file => "/errors/show.html.erb", :status => 404, :layout => "application"
            else
              session["user_return_to"] = path
              flash[:error] = "Login required."
              redirect_to new_user_session_path
            end
          end
        else
          render :file => "/errors/show.html.erb", :status => 404, :layout => "application"
        end
      end
    end    
  end
end