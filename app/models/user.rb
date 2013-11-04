class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :token_authenticatable,
    :recoverable, :rememberable, :trackable, :validatable, :timeoutable, :lockable,
    :maximum_attempts => 3, :lock_strategy => :failed_attempts, :unlock_strategy => :email, :timeout_in => 30.minutes

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts,       :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,          :type => String # Only if unlock strategy is :email or :both
  field :locked_at,             :type => Time

  ## Token authenticatable
  field :authentication_token, :type => String

  ## Extra attributes
  field :first_name,              :type => String, :default => ""
  field :mid_name,                :type => String
  field :last_name,               :type => String, :default => ""
  field :contact_no,              :type => String, :default => ""
  field :address1,                :type => String
  field :address2,                :type => String
  field :zip,                     :type => String
  field :city,                    :type => String

  field :is_admin,                :type => Boolean, :default => false

  field :setup,                   :type => Boolean, :default => false
  field :build_plan,              :type => Boolean, :default => false
  field :track,                   :type => Boolean, :default => false
  field :report,                  :type=> Boolean,  :default => false
  field :benchmark_report,        :type=> Boolean,  :default => false
  
  field :is_blocked,              :type => Boolean, :default => false
  field :is_notified,             :type => Boolean, :default => false

  index :email, :unique => true
  #index :reset_password_token, :unique => true
  #index :confirmation_token, :unique => true

  belongs_to :company
  belongs_to :country
  belongs_to :state
  has_many :plans, :dependent => :nullify
  
  has_many :issues, :dependent => :nullify
  has_many :tickets, :dependent => :nullify
  has_many :comments, :dependent => :nullify
  has_many :user_brands, :dependent => :destroy
  has_many :user_markets, :dependent => :destroy

  validates :first_name, :last_name, :contact_no, :company_id, :presence => true
  after_update :update_user_name_on_related_collection

  attr_accessible :email, :password, :password_confirmation, :first_name, :mid_name, :last_name, :contact_no, 
    :address1, :address2, :zip, :city, :remember_me, :company_id, :country_id, :state_id, :setup, :build_plan,
    :track, :report, :benchmark_report, :is_blocked, :is_admin, :token, :confirmation_token,
    :confirmation_sent_at, :is_contact_person, :confirmed_at, :is_notified

  def vendors
    if is_admin?
      company.vendors
    else
      brand_ids = user_brands.collect { |p| p.brand_id }
      vendor_ids = BrandVendor.where(:brand_id.in => brand_ids).collect { |p| p.vendor_id }
      company.vendors.where(:_id.in => vendor_ids)
    end
  end

  def brands
    if is_admin?
      company.brands
    else
      brand_ids = user_brands.collect { |p| p.brand_id }
      company.brands.where(:_id.in => brand_ids)
    end
  end

  def accessible_plans
    if is_admin?
      company.plans
    else
      brand_ids = user_brands.collect { |p| p.brand_id }
      company.plans.where(:brand_id.in => brand_ids)
    end
  end

  def accessible_client_plans
    if is_admin?
      company.plans.where(:active => true, :approved => false).any_of({ :is_agency.in => [false, nil] }, { :is_agency => true, :is_agency_submited => true })
    else
      brand_ids = user_brands.collect { |p| p.brand_id }
      company.plans.where(:active => true, :approved => false).any_of({ :brand_id.in => brand_ids, :is_agency.in => [false, nil] }, { :brand_id.in => brand_ids, :is_agency => true, :is_agency_submited => true })
    end
  end

  def accessible_active_client_plans
    if is_admin?
      company.plans.where(:active => true).any_of({ :is_agency.in => [false, nil] }, { :is_agency => true, :is_agency_submited => true })
    else
      brand_ids = user_brands.collect { |p| p.brand_id }
      company.plans.where(:active => true).any_of({ :brand_id.in => brand_ids, :is_agency.in => [false, nil] }, { :brand_id.in => brand_ids, :is_agency => true, :is_agency_submited => true })
    end
  end

  def brands_name
    if is_admin?
      company.brands.asc(:name).collect { |b| b.name }.compact.join(", ")
    else
     user_brands.collect { |ub| ub.brand.name }.sort.compact.join(", ")
    end
  end

  def name
    [first_name, mid_name, last_name].compact.join(' ')
  end

  def is_admin?
    is_admin
  end

  #check user's admin status
  def user_accessible?
    is_admin
  end

  #check user's setup status
  def setup_accessible?
    setup || is_admin
  end

  #check user's build_plan status
  def build_plan_accessible?
    build_plan || is_admin
  end

  #check user's track status
  def track_accessible?
    track || is_admin
  end

  #check user's report status
  def report_accessible?
    report || is_admin
  end

  #check user's report status
  def benchmark_accessible?
    benchmark_report || is_admin
  end

  def update_password(params, *options)
    current_password = params.delete(:current_password)
    result = if valid_password?(current_password)
      update_attributes(params, *options)
    else
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end
    clean_up_passwords
    result
  end

  def active_for_authentication?
    super && !is_blocked && !company.is_blocked
  end

  # Generates a new random token for confirmation, and stores the time
  # this token is being generated
  def resend_confirmation_instruction!
    self.confirmed_at = nil
    generate_confirmation_token && save(:validate => false)
    send_devise_notification(:confirmation_instructions)
  end

  protected

  def update_user_name_on_related_collection
    tickets.update_all(:reporter => name)
    comments.update_all(:user_name => name)
  end
end