class FullFly
  attr_reader :tracks, :total_cost, :total_time, :total_pending_time
  
  def initialize
    @tracks=[]
    @total_cost = @total_time = @total_pending_time = 0
  end
  
  def +(track)
    track.pending_time = (track.dep_time - @tracks.last.arr_time) if @tracks.last
    (@total_pending_time += track.pending_time) if track.pending_time
    @total_cost+= track.cost.to_i
    @total_time+= (track.dur + track.pending_time)    
    @tracks << track
    self
  end
    
end
