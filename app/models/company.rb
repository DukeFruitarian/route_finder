#require "ohm"
#require "ohm/contrib"
class Company < Ohm::Model

  attribute :name
  index     :name
  
end
