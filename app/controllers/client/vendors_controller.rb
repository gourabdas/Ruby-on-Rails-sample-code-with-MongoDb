class Client::VendorsController < ClientController
  before_filter :except => [:get_custom_asset_description] do |controller|
    controller.check_users_privileges('setup')
  end
  include ActionView::Helpers::FormOptionsHelper

  # Listing the all Vendor's under a company
  def index
    #@vendors = current_user.vendors.asc(:market_name).asc(:name).paginate(:per_page => 20, :page => params[:page])
    @vendors = current_user.vendors.asc(:name)#.paginate(:per_page => 20, :page => params[:page])
  end

  # Initializing Vendor
  def new
    session[:return_to] = nil if session[:return_to_plan].present?
    if session[:vendor].present?
      @vendor = session[:vendor]
      session[:vendor] = nil
    else
      @vendor = Vendor.new
    end
  end

  # creating a Vendor
  def create
    session[:vendor] = nil    
    if params[:commit] == "Add New"
      session[:return_to] = nil
      session[:vendor] = Vendor.new(params[:vendor])
      session[:return_to] = request.headers["Referer"]
      redirect_to new_client_brand_path
    else
      begin
        market = Market.find(params[:vendor][:market_id])
        if market.present?
          params[:vendor][:market_name] = market.name
          params[:vendor][:currency_symbol] = market.country.symbol
        end

        country = Country.find(params[:vendor][:country_id].to_s) if params[:vendor][:country_id].present?
        if country.present?
          unless country.us_country?
            params[:vendor][:state_id] = nil
          else
            state = State.find(params[:vendor][:state_id].to_s) if params[:vendor][:state_id].present?
            params[:vendor][:state_id] = nil if !state.present? || (state.present? && !state.is_us_state?)
          end
        else
          params[:vendor][:state_id] = nil
        end

        @vendor = @company.vendors.create!(params[:vendor])
        brands = @company.brands.collect { |b| b.id.to_s }
        params[:brand_ids].each do |id|
          @vendor.brand_vendors.create!(:brand_id => id) if brands.include?(id.to_s)
        end if params[:brand_ids].present?
        
        flash[:notice] = "Successfully created."

        if params[:commit] == "Save & Setup Contract Metrics"
          redirect_to client_setup_contract_metrics_path(@vendor)
        else
          return_to = session[:return_to_plan] if session[:return_to_plan].present?
          session[:return_to_plan] = nil
          redirect_to(return_to.present? ? return_to : client_vendors_path)
        end
      rescue Exception => e
        @vendor = Vendor.new(params[:vendor]) unless @vendor.present?
        flash[:error] = "ERROR: #{e.message}."
        render :action => "new"
      end
    end
  end

  # find vendor for editing
  def edit
    begin
      @vendor = current_user.vendors.find(params[:id])
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
      redirect_to client_vendors_path
    end
  end

  # update the vendor
  def update
    begin
      @vendor = current_user.vendors.find(params[:id])
      params[:vendor].delete(:market_id)

      country = Country.find(params[:vendor][:country_id].to_s) if params[:vendor][:country_id].present?
      if country.present?
        unless country.us_country?
          params[:vendor][:state_id] = nil
        else
          state = State.find(params[:vendor][:state_id].to_s) if params[:vendor][:state_id].present?
          params[:vendor][:state_id] = nil if !state.present? || (state.present? && !state.is_us_state?)
        end
      else
        params[:vendor][:state_id] = nil
      end

      @vendor.update_attributes!(params[:vendor])
      brand_ids = @vendor.brand_vendors.collect { |p| p.brand_id }
      current_brand_ids = params[:brand_ids].present? ? current_user.brands.where(:_id.in => params[:brand_ids]).collect { |i| i.id } : []
      old_brand_ids = brand_ids - current_brand_ids
      new_brand_ids = current_brand_ids - brand_ids
      new_brand_ids.each do |id|
        @vendor.brand_vendors.create(:brand_id => id)
      end if new_brand_ids.present?
      @vendor.brand_vendors.where(:brand_id.in => old_brand_ids).destroy_all if old_brand_ids.present?      
      flash[:notice] = "Successfully updated."
      if ["Save & Setup Contract Metrics", "Update & Setup Contract Metrics"].include?(params[:commit])
        redirect_to client_setup_contract_metrics_path(@vendor)
      else
        redirect_to client_vendors_path
      end      
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
      render :action => "edit"
    end
  end

  # delete the vendor
  def destroy
    begin
      @vendor = current_user.vendors.find(params[:id])
      plans = @vendor.plans if @vendor.present?
      if plans.present?
        raise "This vendor cann't be deleted, because this vendor belongs to the exiting plan."
      else
        @vendor.destroy
        flash[:notice] = "Successfully deleted."
      end
      redirect_to client_vendors_path
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
      redirect_to client_vendors_path
    end
  end

  ## setup contract metrics for a particular vendor(Agency)
  def setup_contract_metrics
    begin
      if request.headers.present? && request.headers["Referer"].present?
        p_ref = request.headers["Referer"].split('/')
        budget_ref = "#{p_ref[-2]}/#{p_ref.last}"
        session[:return_to] = request.headers["Referer"] if p_ref.last == "compensation-methodology-and-metrics" || budget_ref == "budgets/edit"
      else
        session[:return_to] = nil
      end
      @vendor = current_user.vendors.find(params[:vid])
      @assets = Asset.get_valid_assets
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
      redirect_to client_vendors_path
    end
  end

  def add_contract_metrics
    begin
      @vendor = current_user.vendors.find(params[:vid])
      
      @vendor.update_attributes!(params[:vendor])

      @vendor.vendor_spend_mixes.destroy_all
      params[:vendor_spend_mix].sort_by{ |a| a.first.to_i }.each { |key, vendor_spend_mix|    
        @vendor.vendor_spend_mixes.create(vendor_spend_mix)      
      } if params[:vendor_spend_mix].present?
      
      @vendor.vendor_job_rates.destroy_all
      params[:vendor_job_rates].sort_by{ |a| a.first.to_i }.each { |key, vendor_job_rate|
        @vendor.vendor_job_rates.create(vendor_job_rate)       
      } if params[:vendor_job_rates].present?

      @vendor.vendor_asset_rates.destroy_all
      params[:vendor_asset_rates].sort_by{ |a| a.first.to_i }.each { |key, vendor_asset_rate|
        @vendor.vendor_asset_rates.create(vendor_asset_rate)
      } if params[:vendor_asset_rates].present?

      @vendor.vendor_asset_rates.unscoped.where(:is_custom => true).destroy_all
      params[:vendor_custom_asset_rates].sort_by{ |a| a.first.to_i }.each { |key, vendor_custom_asset_rate|
        @vendor.vendor_asset_rates.create(vendor_custom_asset_rate.merge(:is_custom => true))
      } if params[:vendor_custom_asset_rates].present?

      return_to = nil
      if session[:return_to].present?
        return_to = session[:return_to]
        session[:return_to] = nil
      elsif session[:return_to_plan].present?
        return_to = session[:return_to_plan]
        session[:return_to_plan] = nil
      else
        session[:return_to] = nil
        session[:return_to_plan] = nil
      end
      
      flash[:notice] = "Contract Metrics Saved Successfully."
      redirect_to(return_to.present? ? return_to : client_setup_contract_metrics_path(@vendor))
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
      redirect_to client_setup_contract_metrics_path(@vendor)
    end
  end

  def reset_job_rates
    begin
      @vendor = current_user.vendors.find(params[:vid])
      @vendor.vendor_job_rates.destroy_all
      flash[:notice] = "Contract Hourly Rate(By Title) reset successfully."
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
    end
    redirect_to :back
  end

  def reset_assets_price
    begin
      @vendor = current_user.vendors.find(params[:vid])
      @vendor.vendor_asset_rates.destroy_all
      flash[:notice] = "Assets Price reset successfully."
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
    end
    redirect_to :back
  end

  def reset_custom_assets_price
    begin
      @vendor = current_user.vendors.find(params[:vid])
      @vendor.vendor_asset_rates.unscoped.where(:is_custom => true).destroy_all
      flash[:notice] = "Custom assets price reset successfully."
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
    end
    redirect_to :back
  end

  def get_states_markets
    country = Country.find(params[:country_id])
    if country.present?
      states = country.states.present? ? country.states.asc(:name).collect{|p|[p.name, p.id]} : []
      markets = country.markets.present? ? country.markets.asc(:name).collect{|p|[p.name, p.id]} : []
      render :json => { :success => true, :states => "#{select :vendor, :state_id, states, {:prompt => true}, :id => 'vendor-market-drop-down', :class => 'validate[required]'}", :markets => "#{select :vendor, :market_id, markets, {:prompt => true}, :id => 'vendor-market-drop-down', :class => 'validate[required]'}" }
    else
      render :json => { :success => true, :states => "#{select :vendor, :state_id, [], {:prompt => true}, :id => 'vendor-market-drop-down', :class => 'validate[required]'}", :markets => "#{select :vendor, :market_id, [], {:prompt => true}, :id => 'vendor-market-drop-down', :class => 'validate[required]'}" }
    end
  end

  def get_asset_description
    begin
      asset = Asset.find(params[:aid])
      if asset.description.present?
        render :json => { :success => true, :description => asset.description }
      else
        render :json => { :success => false }
      end
    rescue Exception => e
      render :json => { :success => false }
    end
  end

  def get_custom_asset_description
    begin
      company_asset = CompanyAsset.find(params[:caid])
      if company_asset.description.present?
        render :json => { :success => true, :description => company_asset.description }
      else
        render :json => { :success => false }
      end
    rescue Exception => e
      render :json => { :success => false }
    end
  end

  def get_job_title_description
    begin
      job_title = JobTitle.find(params[:jtid])
      if job_title.description.present?
        render :json => { :success => true, :description => job_title.description }
      else
        render :json => { :success => false }
      end
    rescue Exception => e
      render :json => { :success => false }
    end
  end
end