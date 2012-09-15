class Result < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  
  collection  :all_flys, :Fly, :result
  reference   :member, :Member
  attribute   :search_at, Type::Time
  attribute   :departure_date
  attribute   :departure_place
  attribute   :arrival_place
  attribute   :res_array, Type::Array
  attribute   :search_params, Type::Hash
end
