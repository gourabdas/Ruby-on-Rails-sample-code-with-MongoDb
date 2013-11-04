class ClientController < ApplicationController
  skip_before_filter :valid_subdomain_required?
  before_filter :authenticate_user!, :company_required

  def current_company
    @company ||= current_user.company
  end
  
  protected

  # This is a before_filter we'll use in other controllers
  def company_required
    redirect_to root_path(:subdomain => false) unless current_company
  end

  def check_users_privileges(type)
    unless current_user.send("#{type}_accessible?".to_sym)
      flash[:error] = "You don't have permission to access #{type.titleize} section."
      redirect_to root_path
    end
  end
end