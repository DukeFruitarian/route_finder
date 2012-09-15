#require "ohm"
#require "ohm/contrib"
class City < Ohm::Model

  attribute :name
  index     :name
  
end
