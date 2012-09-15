class Track
  attr_accessor :pending_time
  attr_reader :dep_place, :arr_place, :dep_time, :arr_time, :dur, :cost, :company 
  
  def initialize(string)
    arr = string.split(", ")
    @pending_time = 0
    @dep_place, @arr_place, dep_time_str, arr_time_str, dur, @cost, @company = arr
    #debugger
    @dep_time = dep_time_str.to_time.to_i
    @arr_time = arr_time_str.to_time.to_i
    @dur = dur.to_i
  end
end
