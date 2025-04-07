class Patient < User
  belongs_to :doctor
  has_many :diet_plans, foreign_key: :patient_id, class_name: "DietPlan", dependent: :destroy
  has_many :appointments, dependent: :destroy
end
