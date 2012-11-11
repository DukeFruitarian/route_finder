class FinderController < ApplicationController
  # GET /index
  def index
    @member = Member[session[:member_id]] if session[:member_id]
  end

  # вход в систему, под указанным юзером
  def entering
    session[:member_id] = Member.find(:name => params[:member]).first.id if Member.find(:name => params[:member]).first || Member.create(:name => params[:member]).id
    redirect_to index_path
  end

  # выход из системы
  def leaving
    session[:member_id] = nil
    redirect_to index_path
  end

  # GET /result/id
  # показывает результат, основанный на id
  def old_result
    @res = Result[params[:id]]
    session[:result_id] = @res.id
    render(:result)
  end

  # GET /result
  # создаёт новый результат и перенаправляет в old_result
  def result
    member = Member[session[:member_id]] if session[:member_id]
    res = Result.create(:member => member,
                        :search_params => params,
                        :search_at => Time.now,
                        )
    session[:result_id] = res.id
    redirect_to :action => :old_result, :id => res.id
  end

  # AJAX запрос, POST /index
  # метод поиска
  def find
    # получаем переменную результата, в которую будем записывать найденные перелёты
    res = Result[session[:result_id]]
    @results = []

    # Если данный запрос уже был обработан, возвращается его результат из БД
    data = Ohm.redis.get("results:#{res.id}")
    if data
      @results = Marshal.load(data)
      return
    end

    # В инстанс переменную записывается результат выполнения метода find_flys
    #   с параметрами поиска
    @results << find_flys(Aeroport[res.search_params["departure"]],
                          convert_date(res.search_params["departure_date"],0),
                          Aeroport[res.search_params["arrival"]])

    # Если указано продолжение пути - в результат дописывается второй перелёт
    if res.search_params["second_route"]
      @results << find_flys(Aeroport[res.search_params["departure_2"]],
                            convert_date(res.search_params["departure_date_2"],0),
                            Aeroport[res.search_params["arrival_2"]])
    end

    # Запись в БД результат поиска
    Ohm.redis.set("results:#{res.id}", Marshal.dump(@results))

    # рендер яваскрипта
    respond_to do |format|
      format.js
    end
  end

  private

  # хелпер парсинга параметров поиска
  def parsing_params(fly, par)
    if par[:format] == :html
      (params[:changes].to_i + 1) >= fly.number_of_tracks &&
        params[:price].to_f >= fly.total_cost &&
        (params[:pend_hours].to_i*3600 + params[:pend_minutes].to_i*60) >=
          fly.total_pending &&
        (params[:hours].to_i*3600 + params[:days].to_i*86400) >=
          fly.total_time
    elsif par[:format] == :js
      (params[:select_changes].to_i + 1) >= fly.number_of_tracks &&
        params[:select_price].to_f >= fly.total_cost &&
        (params[:select_pend_hours].to_i*3600 + params[:select_pend_minutes].to_i*60) >=
          fly.total_pending &&
        (params[:select_hours].to_i*3600 + params[:select_days].to_i*86400) >=
          fly.total_time
    end
  end

  # хелпер конвертирования даты
  def convert_date(date, difference=0)
    d = date.map{|key,value| value.to_i}
    (d[-1] = d[-1] - 1) until Date.valid_date?(*d)
    date = Date.new(*d)
    date+difference
  end

  # основной метод поиска перелётов
  def find_flys(dep_port, dep_date, arr_port)
    # максимальное число часов между перелётами в одном маршруте
    max_pending_hours = 24

    # переменная маршрута, класса Route с местом отправления и местом назначения
    route = Route.new(dep_port.name,arr_port.name)

    # Поиск прямых перелётов из точки отправления в точку назначения
    route.flys = (Ohm.redis.zrangebyscore("from:#{dep_port.id}:to:#{arr_port.id}",
      dep_date.to_time.to_i, (dep_date+1).to_time.to_i) ||
    []).map do |par|
      ff = FullFly.new
      ff + Track.new(par)
    end

    # Поиск перелётов с одной пересадкой.
    # Логика: Ищем все аэропорты, перелёты в которые возможно сделать из места
    #   убытия. В каждом найденном аэропорту ищутся:
    #   1. Перелёты из места убытия в текущий аэропорт, в заданную дату.
    #   2. Перелёты из текущего аэропорта в место назначения,
    #     в заданную дату плюс от 5 (минимальное время полёта + ожидания) до 38
    #     (14 максимальное время одного полёта + 24 максимальное время ожидания
    #     между перелётами)
    #   Затем значения массивов сравниваются, и добавляются как возможный вариант,
    #     если подходят условиям (время прибытия первого перелёта < времени
    #     убытия второго перелёта на время от часа до 24 часов)
    Ohm.redis.smembers("allRoutesFrom:#{dep_port.id}").each do |id|
      # Создание массива вылетов из места убытия
      temp_dep =  (Ohm.redis.zrangebyscore("from:#{dep_port.id}:to:#{id}",
        dep_date.to_time.to_i, (dep_date+1).to_time.to_i) ||
      [])

      # Создание массива прилётов в место назначения
      temp_arr =  (Ohm.redis.zrangebyscore("from:#{id}:to:#{arr_port.id}",
        dep_date.to_time.to_i + 60*60*(4+1),
        (dep_date+1).to_time.to_i + 60*60*14 + 60*60*max_pending_hours) ||
      [])
      # Проверка условий перелётов
      temp_dep.each do |first|
        temp_arr.each do |last|
          tr_dep = Track.new(first)
          tr_arr = Track.new(last)
          if (tr_dep.arr_time + 60*60 < tr_arr.dep_time &&
            tr_dep.arr_time + 60*60*max_pending_hours > tr_arr.dep_time)

            ff = FullFly.new
            ff + tr_dep
            ff + tr_arr
            route + ff
          end # if
        end   # temp_arr.each
      end     # temp_dep.each
    end       # smembers.each

    # Поиск перелётов с 2-мя пересадками. Принцип тот же, только ищется
    #   перелёты во все возможные места из пункта убытия, и все возможные места
    #   откуда можно добраться в конечную точку. И между ними ищется подходящий
    #   перелёт.

    Ohm.redis.smembers("allRoutesFrom:#{dep_port.id}").each do |first_id|
      # Пропускаем аэропорт если он конечная точка, т.к. это уже учли в перелётах
      #   без пересадки
      next if first_id == arr_port.id
      # Все возможные перелёты из стартовой точки в текущий аэропорт
      first_temp_arr = (Ohm.redis.zrangebyscore("from:#{dep_port.id}:to:#{first_id}",
        dep_date.to_time.to_i,(dep_date+1).to_time.to_i) ||
      []).map{|str| Track.new(str)}

      # Все аэропорты, из которых возможны перелёты в конечную точку
      Ohm.redis.smembers("allRoutesTo:#{arr_port.id}").each do |last_id|
        # Пропускаем аэропорт если пенкт отправления в конечную точку -
        #   место отправления (это учли в перелётах без пересадки) или
        #   место возможного перелёта из места отправления (это учли
        #   в перелёте с 1 пересадкой)
        next if last_id == dep_port.id || last_id == first_id
          # Все возможные перелёты в конечную точку
        last_temp_arr = (Ohm.redis.zrangebyscore("from:#{last_id}:to:#{arr_port.id}",
          (dep_date+1).to_time.to_i + 60*60*12,
          (dep_date+4).to_time.to_i) ||
        []).map{|str| Track.new(str)}

        # средний перелёт - между 2-мя пересадками
        middle_temp_arr = (Ohm.redis.zrangebyscore("from:#{first_id}:to:#{last_id}",
          (dep_date).to_time.to_i + 60*60*5,
          (dep_date+1).to_time.to_i + 60*60*max_pending_hours) ||
        []).map{|str| Track.new(str)}

        # проверка условий. Такие же как с 1 пересадкой
        first_temp_arr.each do |first|
          last_temp_arr.each do |last|
            middle_temp_arr.each do |middle|
              if (middle.arr_time + 60*60 < last.dep_time  &&
                first.arr_time + 60*60 < middle.dep_time &&
                first.arr_time + 60*60*max_pending_hours > middle.dep_time &&
                middle.arr_time + 60*60*max_pending_hours > last.dep_time)

                ff = FullFly.new
                ff + first
                ff + middle
                ff + last
                route + ff
              end # if
            end   # middle_temp_arr.each
          end     # last_temp_arr.each
        end       # first_temp_arr.each
      end         # smembers airports with flys to arrival place
    end           # smembers airports with flys from dep place
    # сортируем по общей стоимости
    route.flys.sort_by!{|fly| fly.total_cost}
    route
  end

end
