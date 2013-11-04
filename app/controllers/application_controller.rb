class ApplicationController < ActionController::Base
  include ::SslRequirement
  include CustomMethod

  protect_from_forgery
  before_filter :valid_subdomain_required?
  before_filter :mailer_set_url_options

  def initialize(*params)
    super(*params)
    @res = Hash.new()
    @res[:metaData] = {
      :root => "data",
			:idProperty => "id",
			:totalProperty => "total",
			:successProperty => "success",
			:messageProperty => "message"
    }
  end

  protected
  #Find company from id
  def get_company_from_id
    Company.find(params[:id]) if params[:id].present?
  end

  def valid_subdomain_required?
    subdomain = current_subdomain
    case subdomain
    when 'admin', 'www', 'support','', nil
      true
    else
      render(:template => "errors/subdomain_missing", :layout => "application") if Company.where(:subdomain => subdomain).first.blank?
    end
  end

  def mailer_set_url_options
    parts = request.host_with_port.split('.')
    ActionMailer::Base.default_url_options[:host] = parts[-(SubdomainFu.config.tld_size+1)..-1].join(".")
  end

  def current_agency_company
    @company ||= current_agency.company
  end

  def check_agencies_privileges(type)
    case type
    when "submit_plan"
      flash[:error] = "You don't have permission to #{type.titleize}."
      redirect_to agencies_staffing_plans_path
    when "sow"
      flash[:error] = "This agency didn't have any permission to build Scope of Work."
      redirect_to agencies_scope_of_works_path
    when "staffing_plan"
      flash[:error] = "This agency didn't have any permission to build Staffing Plan."
      redirect_to agencies_staffing_plans_path
    else
      flash[:error] = "You don't have permission to access #{type.titleize} section."
      redirect_to agency_root_path
    end unless current_agency.send("#{type}_accessible?".to_sym)
  end

  private
  # make whole application ssl required
  def ssl_required?
    Rails.env.production?
  end
end