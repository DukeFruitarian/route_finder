class Route
  attr_reader :departure, :arrival, :min_price, :max_price,
              :min_total_days,:min_total_hours,
              :max_total_days,:max_total_hours,
              :max_pending_days,:max_pending_hours,
              :min_pending_days,:min_pending_hours,:flys
  
  def initialize(dep,arr)
    @departure,@arrival = dep,arr
    @flys = []
    @min_price = @min_total_time = @min_pending_time =10000000
    @max_price = @max_total_time = @max_pending_time = 0
    
  end
  
  def flys=(arr)
    if arr
      arr.each do |track|
        self + track
      end
    end
    
  end
  
  def +(fly)
    @flys << fly
    #debugger
    @min_price = fly.total_cost unless @min_price && @min_price < fly.total_cost 
    @max_price = fly.total_cost unless @max_price && @max_price > fly.total_cost 
    @min_total_time = fly.total_time unless @min_total_time && @min_total_time < fly.total_time 
    @max_total_time = fly.total_time unless @max_total_time && @max_total_time > fly.total_time 
    @min_pending_time = fly.total_pending_time unless @min_pending_time && @min_pending_time < fly.total_pending_time
    @max_pending_time = fly.total_pending_time unless @max_pending_time && @max_pending_time > fly.total_pending_time
  end

  def min_total_days
    @min_total_time.to_i/86400
  end
  
  def min_total_hours
    (@min_total_time.to_i - self.min_total_days*86400)/3600
  end

  def max_total_days
    @max_total_time.to_i/86400
  end
  
  def max_total_hours
    (@max_total_time.to_i - self.max_total_days*86400)/3600 +1
  end

  def min_pending_days
    @min_pending_time.to_i/86400
  end
  
  def min_pending_hours
    (@min_pending_time.to_i - self.min_pending_days*86400)/3600
  end

  def max_pending_days
    @max_pending_time.to_i/86400
  end
  
  def max_pending_hours
    (@max_pending_time.to_i - self.max_pending_days*86400)/3600 + 1
  end


end
