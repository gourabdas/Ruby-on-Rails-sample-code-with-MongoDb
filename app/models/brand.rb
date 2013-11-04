class Brand
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :brand_manager, :type => String
  field :title, :type => String
  field :email, :type => String
  field :contact_no, :type => String
  field :lifecycle, :type => String
  field :business_unit, :type => String
  field :category, :type => String
  
  belongs_to :company
  has_many :plans, :dependent => :destroy
  has_many :brand_vendors, :dependent => :destroy
  has_many :user_brands, :dependent => :destroy
  
  validates :name, :brand_manager, :contact_no, :title, :company_id, :presence => true
  validates :name, :uniqueness => { :scope => :company_id, :case_sensitive => false, :allow_blank => true }
  validates :email, :presence => true, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true }

  attr_accessible :name, :brand_manager, :email, :contact_no, :title, :company_id, :lifecycle, :business_unit, :category

  LIFECYCLE = ["Pre-launch", "Launch", "Growth", "Mature", "Maintenance"].freeze
end