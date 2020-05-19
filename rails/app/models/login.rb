class Login
  extend ActiveModel::Naming
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email
  attr_reader :user

  validates_each :email do |record, attr, value|
    user = User.find_by(email: value)
    if user
      record.instance_variable_set '@user', user
    else
      record.errors.add attr, 'not found'
    end
  end

end
