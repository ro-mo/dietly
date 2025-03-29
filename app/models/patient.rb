class Patient < User
  belongs_to :doctor
  has_one :diet_plan, dependent: :destroy
  has_many :appointments, dependent: :destroy
end
