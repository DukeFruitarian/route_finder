module FinderHelper
  def seconds_to_time(sec)
    #debugger
    str=""
    days = sec/86400
    hours = (sec - days*86400)/3600
    minutes = (sec - days*86400 - hours*3600)/60
    if days > 0
      str += days.to_s + "d." 
    end
    str += " " + hours.to_s + "h. " + minutes.to_s + "m."
  end
  
  def generate_link(res)
    #debugger
    link_to("From: " + Aeroport[res.search_params["departure"]].name + " To: " + Aeroport[res.search_params["arrival"]].name + " at: " + convert_date(res.search_params["departure_date"],0).to_s + " (searched at:" + res.search_at.strftime("%y.%m.%d %H:%M )"),
    "result/#{res.id}")
  end
  
  def index_link
    if session[:member_id]
      link_to 'Recent searches', index_path 
    else
      link_to 'New search', index_path 
    end
  end
  
  private
  	  
	  def convert_date(date, difference=0)
      d = date.map{|key,value| value.to_i}
      (d[-1] = d[-1] - 1) until Date.valid_date?(*d) 
      date = Date.new(*d)
      date+difference
    end
end
