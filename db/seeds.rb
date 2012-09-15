#---
# Excerpted from "Agile Web Development with Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/rails4 for more book information.
#---
# encoding: utf-8
#debugger
#-----------------------------------------------------------
City.all.each{|ct| ct.delete}

City.create name: "Moskow"
City.create name: "Bangkok"
City.create name: "Kopengagen"
City.create name: "Paris"
City.create name: "New York"
City.create name: "Manila"

#-----------------------------------------------------------
Aeroport.all.each{|ae| ae.delete}

Aeroport.create   city: City[1],
                  name: "Domodedovo"
Aeroport.create   city: City[1],
                  name: "Pulkovo"
Aeroport.create   city: City[2],
                  name: "Bangkok airport"
Aeroport.create   city: City[3],
                  name: "Kopenkopen"
Aeroport.create   city: City[4],
                  name: "Paris Airport 1"
Aeroport.create   city: City[4],
                  name: "Paris Airport 2"
Aeroport.create   city: City[5],
                  name: "Manila ways"

Track.all.each{|tr| tr.delete}


Track.create  arrival_place: Aeroport[3],
              departure_place: Aeroport[1],
              company: "Aeroflot",
              cost: 125,
              arrival_time: Time.now + 3.days + 12.hours,
              departure_time: Time.now + 3.days
               