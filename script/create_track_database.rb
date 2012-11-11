#-----------------------------------------------------------
City.all.each{|ct| ct.delete}

# уникальные города, в которых расположены аэропорты
id = City.create(name: "Moskow").id.to_i
City.create name: "Bangkok"
City.create name: "Kopengagen"
City.create name: "Paris"
City.create name: "New York"
City.create name: "Manila"

#-----------------------------------------------------------
Aeroport.all.each{|ae| ae.delete}
idA = 1
# Установка количество аэропортов, из которых и в которые будут осуществляться
#   перелёты
(1..20).each_with_index do |aid, indx|
  ap = Aeroport.create   city: City[id+rand(6)],
                    name: "Airport#{aid}"
  idA = ap.id.to_i if indx == 0
end


#-----------------------------------------------------------
Company.all.each{|cmpny| cmpny.delete}

idC = Company.create(name: "Aeroflot").id.to_i
# Компании-перевозчики
Company.create(name: "China ways")
Company.create(name: "Thay flights")
Company.create(name: "France Airlines")
Company.create(name: "Danish Air")
Company.create(name: "German lines")
Company.create(name: "Air of GB")
#-----------------------------------------------------------

APcount = (Ohm.redis.get "Aeroport:counter").to_i
# Общее количество перелётов из всех аэропортов
(0..5000).each do |i|
# Определение точки убытия и прибытия
  arr = dep = Aeroport[rand(APcount)+idA]
  arr = Aeroport[rand(APcount)+idA] while dep.city.id == arr.city.id

  comp = Company[rand(7)+idC]
# Дата и время убытия. В интервале +- 5 дней от текущего времени
  dep_time = Time.now - 5.days + (i%10).days
# Время в полёте от 3 до 14 часов
  dur = (3.hours + rand(10).hours + rand(60).minutes).to_i
  arr_time = dep_time + dur
# Цена от 1000 до 2000 условных единиц.
  c = 1000 + rand(1000)
# Запись в базу данных полную информацию о перелёте
  Ohm.redis.zadd("from:#{dep.id}:to:#{arr.id}",dep_time.to_i, "#{dep.name}, #{arr.name}, #{dep_time.strftime("%Y.%m.%d %H:%M:%S")}, #{arr_time.strftime("%Y.%m.%d %H:%M:%S")}, #{dur},  #{c}, #{comp.name}")
# Добавление в список возможных путей из точки убытия в точку назначеия
  Ohm.redis.sadd("allRoutesFrom:#{dep.id}","#{arr.id}")
# Добавление в список возможных путей в точку назначеия из точки убытия
  Ohm.redis.sadd("allRoutesTo:#{arr.id}","#{dep.id}")
end
