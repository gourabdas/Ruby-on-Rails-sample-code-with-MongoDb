class Client::BrandsController < ClientController
  before_filter do |controller|
    controller.check_users_privileges('setup')
  end

  # Listing the all Brand's under a company
  def index
    @brands = current_user.brands#.paginate(:per_page => 20, :page => params[:page])
  end

  # initializing a brand
  def new    
    if session[:return_to_plan].present?
      if session[:return_to].present?
        split_path = session[:return_to].split('/')
        split_ref = "#{split_path[3]}/#{split_path[4]}"
        session[:return_to] = nil unless ["client/vendors"].include?(split_ref)
      end      
    else
      session[:return_to] = request.headers["Referer"] if !session[:return_to].present?
    end
    @brand = Brand.new
  end

  # creating a brand
  def create
    begin
      raise "Selected Brand Lifecycle value not found" if params[:brand][:lifecycle].present? && !Brand::LIFECYCLE.include?(params[:brand][:lifecycle])

      case business_unit = params[:brand].delete(:business_unit)
      when "Others"
        params[:brand].merge!(:business_unit => params[:other_business_unit])
      else
        params[:brand].merge!(:business_unit => business_unit)
      end

      case category = params[:brand].delete(:category)
      when "Others"
        params[:brand].merge!(:category => params[:other_category])
      else
        params[:brand].merge!(:category => category)
      end
      
      @brand = @company.brands.create!(params[:brand])
      current_user.user_brands.create(:brand_id => @brand.id) 
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
      flash[:notice] = "Successfully created."
      redirect_to(return_to.present? ? return_to : client_brands_path)
    rescue Exception => e
      @brand = Brand.new unless @brand.present?
      flash[:error] = "ERROR: #{e.message}."
      render :action => "new"
    end
  end

  # find brand for editing
  def edit
    begin
      @brand = current_user.brands.find(params[:id])
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
      redirect_to client_brands_path
    end
  end
  
  # update the brand
  def update
    begin
      @brand = current_user.brands.find(params[:id])
      raise "Selected Brand Lifecycle value not found" if params[:brand][:lifecycle].present? && !Brand::LIFECYCLE.include?(params[:brand][:lifecycle])

      case business_unit = params[:brand].delete(:business_unit)
      when "Others"
        params[:brand].merge!(:business_unit => params[:other_business_unit])
      else
        params[:brand].merge!(:business_unit => business_unit)
      end

      case category = params[:brand].delete(:category)
      when "Others"
        params[:brand].merge!(:category => params[:other_category])
      else
        params[:brand].merge!(:category => category)
      end
      
      @brand.update_attributes!(params[:brand])
      flash[:notice] = "Successfully updated."
      redirect_to client_brands_path
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
      render :action => "edit"
    end
  end

  # delete the brand
  def destroy
    begin
      @brand = current_user.brands.find(params[:id])
      plans = @brand.plans if @brand.present?
      if plans.present?
        raise "This brand cann't be deleted, because this brand belongs to the exiting plan."
      else
        @brand.destroy
        flash[:notice] = "Successfully deleted."
      end
      redirect_to client_brands_path
    rescue Exception => e
      flash[:error] = "ERROR: #{e.message}."
      redirect_to client_brands_path
    end
  end
end