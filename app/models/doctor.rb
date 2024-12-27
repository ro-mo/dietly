class Doctor < User
  has_many :patients, dependent: :nullify
end
