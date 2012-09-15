class Member < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  
  collection  :results, :Result
  attribute   :name
  index       :name
  
end
