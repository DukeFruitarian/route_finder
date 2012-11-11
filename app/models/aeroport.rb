#require "ohm"
#require "ohm/contrib"
class Aeroport < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks
  reference :city, :City
  collection :arrivals, :Track, :arrival_place
  collection :departures, :Track, :departure_place
  #index     :tracks

  attribute :name
  index     :name

  def self.names
    all.each{}.map{|ap| [ap.name,ap.id.to_i]}
  end

  def after_create
    Ohm.redis.incr "Aeroport:counter"
  end

end
