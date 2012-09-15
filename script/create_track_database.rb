#-----------------------------------------------------------
City.all.each{|ct| ct.delete}

id = City.create(name: "Moskow").id.to_i
City.create name: "Bangkok"
City.create name: "Kopengagen"
City.create name: "Paris"
City.create name: "New York"
City.create name: "Manila"

#-----------------------------------------------------------
Aeroport.all.each{|ae| ae.delete}
idA = 1
(1..20).each_with_index do |aid, indx|
  ap = Aeroport.create   city: City[id+rand(6)],       
                    name: "Airport#{aid}"
  idA = ap.id.to_i if indx == 0
end
#idA = Aeroport.create(city: City[id],        #1
#                  name: "Domodedovo").id.to_i
#debugger
#Aeroport.create   city: City[id],        #2
#                  name: "Pulkovo"
#Aeroport.create   city: City[id+1],        #3
#                  name: "Bangkok airport"
#Aeroport.create   city: City[id+2],        #4
#                  name: "Kopenkopen"
#Aeroport.create   city: City[id+3],        #5
#                  name: "Paris Airport 1"
#Aeroport.create   city: City[id+3],        #6
#                  name: "Paris Airport 2"
#Aeroport.create   city: City[id+4],        #7
#                  name: "Manila ways"
                  
                  
#-----------------------------------------------------------
Company.all.each{|cmpny| cmpny.delete}

idC = Company.create(name: "Aeroflot").id.to_i

Company.create(name: "China ways")
Company.create(name: "Thay flights")
Company.create(name: "France Airlines")
Company.create(name: "Danish Air")
Company.create(name: "German lines")
Company.create(name: "Air of GB")
#-----------------------------------------------------------

#Track.all.each{|tr| tr.delete}
APcount = (Ohm.redis.get "Aeroport:counter").to_i
#debugger
(0..5000).each do |i|
  #debugger
  arr = dep = Aeroport[rand(APcount)+idA]
  arr = Aeroport[rand(APcount)+idA] while dep.city.id == arr.city.id
  comp = Company[rand(7)+idC]
  dep_time = Time.now - 5.days + (i%10).days
  dur = (3.hours + rand(10).hours + rand(60).minutes).to_i
  arr_time = dep_time + dur
  c = 1000 + rand(1000)
  #debugger
  Ohm.redis.zadd("from:#{dep.id}:to:#{arr.id}",dep_time.to_i, "#{dep.name}, #{arr.name}, #{dep_time.strftime("%Y.%m.%d %H:%M:%S")}, #{arr_time.strftime("%Y.%m.%d %H:%M:%S")}, #{dur},  #{c}, #{comp.name}")
  Ohm.redis.sadd("allRoutesFrom:#{dep.id}","#{arr.id}")
  Ohm.redis.sadd("allRoutesTo:#{arr.id}","#{dep.id}")
end