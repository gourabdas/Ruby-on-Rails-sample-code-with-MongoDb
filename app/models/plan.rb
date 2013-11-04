class Plan
  include Mongoid::Document
  include Mongoid::Timestamps

  field :plan_name,           :type => String
  field :city,                :type => String
  field :start_date,          :type => Date
  field :end_date,            :type => Date
  field :total_budget,        :type => BigDecimal
  field :compensation,        :type => BigDecimal

  field :currency_symbol,     :type => String, :default => ""
  field :vendor_market_id,    :type => String
  field :vendor_market_name,  :type => String

  field :plan_no,             :type => String
  field :active,              :type => Boolean, :default => true ## true for open jobs and false for closed ones.Not being used.Always check w.r.t budget/staffing/scope of work
  field :approved,            :type => Boolean, :default => false  ## to check whether a plan is approved or not.Not being used.Always check w.r.t budget/staffing/scope of work
  field :approved_on,         :type => DateTime
  field :approved_by,         :type => String

  field :job_no,              :type => String
  field :is_agency,           :type => Boolean, :default => false
  field :is_agency_submited,  :type => Boolean, :default => false

  index :plan_name
  index :plan_no, :unique => true

  belongs_to :brand
  belongs_to :vendor
  belongs_to :country
  belongs_to :user
  belongs_to :company
  belongs_to :agency

  has_one :budget, :dependent => :destroy
  has_one :scope_of_work, :dependent => :destroy
  has_one :staffing, :dependent => :destroy
  has_many :track_staffings, :dependent => :destroy

  has_many :track_budgets
  has_one :track_scope_of_work, :dependent => :destroy

  has_many :references, :class_name => "Plan", :foreign_key => "reference_id", :inverse_of => :reference_plan, :dependent => :nullify # this association used for copy staffing plan
  belongs_to :reference_plan, :class_name => "Plan", :foreign_key => "reference_id" # this association used for copy staffing plan

  validates :plan_name, :city, :start_date, :end_date, :brand_id, :country_id, :vendor_id, :company_id, :presence => true
  validate :unique_job_number, :on => :update
  validate do
    errors.add(:total_budget, "must be greater than 0") if total_budget.present? && total_budget.to_f == 0
  end

  attr_accessible :plan_name, :city, :start_date, :end_date, :compensation, :total_budget, :brand_id, :vendor_id, :country_id, :total_budget, :user_id, :plan_no, :currency_symbol, :vendor_market_id, :vendor_market_name, :approved, :approved_on, :approved_by, :job_no, :active, :is_agency, :agency_id, :reference_id, :is_agency_submited
  before_create :set_plan_no
  before_save :convert_to_numaric

  COMPENSATION_METHOD = ["Asset/Output Based", "Cost Plus", "Hourly Rate (Blended)", "Hourly Rate (by Title)", "Media Commission"].freeze

  def unique_job_number
    if job_no.present?
      plans = company.plans.where(:job_no => /^#{Regexp.escape(job_no)}$/i).any_of({ :brand_id.nin => [brand_id] }, { :vendor_id.nin => [vendor_id] })
      errors.add(:job_no, "has already been taken") if plans.present?
    end
  end

  def chained_plan?
    chain = false
    chain = true if (budget && scope_of_work) || (scope_of_work && staffing)
    return chain
  end

  def valid_market_for_benchmark_data?
    company.company_markets.present? && company.company_markets.where(:market_id => vendor_market_id).present?
  end

  def valid_discipline_for_benchmark_data?
    company.company_disciplines.present? && company.company_disciplines.where(:discipline_id => vendor.discipline_id).present?
  end

  def accessible_compensation_method
    c_method = COMPENSATION_METHOD.dup
    c_method.delete("Asset/Output Based") unless scope_of_work.present?
    c_method
  end

  # This method used for Brand && Agency reports
  def total_fees
    staffing.present? ? staffing.compensation : nil
  end
  # This method used for Brand && Agency reports
  def total_hours
    staffing.present? ? staffing.total_client_hours : nil
  end
  # This method used for Agency reports
  def total_fte
    staffing.present? ? staffing.total_fte : nil
  end
  # This method used for Agency reports
  def total_direct_client_expenses
    staffing.present? ? staffing.total_direct_client_expenses : nil
  end

  protected

  def genarate_plan_no(&validity)
    begin
      plan_no = SecureRandom.hex(4).upcase
    end while !validity.call(plan_no) if block_given?
    plan_no
  end

  def set_plan_no
    self.plan_no = genarate_plan_no { |plan_no| !Plan.where(:plan_no => plan_no).present? }
  end

  def convert_to_numaric
    self.total_budget = self.total_budget.to_s.gsub(",", "").to_f if self.total_budget.present?
    self.compensation = self.compensation.to_s.gsub(",", "").to_f if self.compensation.present?
  end
end