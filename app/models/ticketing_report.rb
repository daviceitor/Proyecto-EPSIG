# To change this template, choose Tools | Templates
# and open the template in the editor.



class TicketingReport
  require 'csv'
  
  def initialize
    @user=$ticketing_db_data[:user]
    @pass=$ticketing_db_data[:pass]
    @server=$ticketing_db_data[:server]
    @database=$ticketing_db_data[:database]
    @port=$ticketing_db_data[:port]
  end

  def get_all_responsables

    execute do |mysql|
      @result = mysql.query("SELECT u.idUsuario,u.Nombre,u.Apellidos from usuario u
                           INNER JOIN proyecto p on p.idUsuario = u.idUsuario
                           group by u.idUsuario")
    end

    @responsables = []
    @result.each do |row|
      @responsables << ["#{row[1]} #{row[2]}", row[0]]
    end
    @responsables
  end

  def get_states
    [["Abiertos","1"],["Todos",""],["Cerrados","2"]]
  end

  def get_responsable id
    result = execute do |mysql|
      @result = mysql.query("SELECT concat(u.Nombre,' ',u.Apellidos) from usuario u
                              where u.IdUsuario = #{id}")
    end
    result.fetch_row
  end

  def generate_report user, state, ini_date, end_date
    
    @report = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = {}}}
    
    query_tickets_time(user, state, ini_date, end_date).each do |row|
      merge_row @report, row, "tickets"
    end
    
    query_conference_time(user, state, ini_date, end_date).each do |row|
      merge_row @report, row, "conferencias"
    end
    
    query_task_time(user, state, ini_date, end_date).each do |row|
      merge_row @report, row, "tareas"
    end
    
    query_assembly_time(user, state, ini_date, end_date).each do |row|
      merge_row @report, row, "reuniones"
    end
    
  end

  def to_csv user, state, ini_date, end_date
    csv = ""
    CSV::Writer.generate(csv, ",") do |result|
      result << ["Busqueda:"]
      result << ["Responsable:", get_responsable(user), "Entre", ini_date, "y", end_date]
      result << []
      result << ["Cliente", "Proyecto", "Estado", "Consultor", "Tiempo Tickets",
        "Tiempo Conferencias", "Tiempo Tareas", "Tiempo Reuniones", "Nº reuniones"]
      
      @report.each_pair do |consultor,proyectos|
        proyectos.each_pair do |proyecto, clientes|
          clientes.each_pair do |cliente, datos|
            result << [cliente, proyecto, datos[:estado], consultor, datos[:tiempos][:tickets], datos[:tiempos][:conferencias], datos[:tiempos][:tareas], datos[:tiempos][:reuniones], datos[:n_reuniones]]
          end
        end
      end
    end
    csv
  end

  def query_tickets_time user, state, ini_date, end_date
    execute do |mysql|
      mysql.query("SELECT c.Nombre, p.Nombre, e.nombre,CONCAT(u.Nombre,' ',u.Apellidos) as Consultor, sum(i.TiempoTarea) as 'Tiempo Imputado Tickets'
                    FROM proyecto p
                    INNER JOIN cliente c ON p.IdCliente=c.IdCliente
                    INNER JOIN incidencia i ON p.IdProyecto=i.IdProyecto
                    INNER JOIN usuario u ON i.IdUsuario=u.IdUsuario
                    INNER JOIN estado e ON p.IdEstado=e.IdEstado

                    WHERE p.IdUsuario='#{user}' #{"AND p.IdEstado='#{state}'" unless state.blank?} 
                                                #{"AND i.Apertura <= str_to_date('#{end_date}', '%d/%m/%Y')" unless end_date.blank?}
                                                #{"AND i.Apertura >= str_to_date('#{ini_date}', '%d/%m/%Y')" unless ini_date.blank?}

                    GROUP BY p.IdProyecto, i.IdUsuario;")
    end
  end

  def query_conference_time user, state, ini_date, end_date
    execute do |mysql|
      mysql.query("SELECT c.Nombre, p.Nombre, e.nombre,CONCAT(u.Nombre,' ',u.Apellidos) as Consultor, sum(ll.Duracion) as 'Tiempo Imputado Conferencias'
                    FROM proyecto p INNER JOIN cliente c ON p.IdCliente=c.IdCliente
                    INNER JOIN llamadas l ON p.IdProyecto=l.IdProyecto
                    INNER JOIN llamadasusuario ll ON l.IdLlamada=ll.IdLlamada
                    INNER JOIN usuario u ON ll.IdUsuario=u.IdUsuario
                    INNER JOIN estado e ON p.IdEstado=e.IdEstado

                    WHERE p.IdUsuario='#{user}' #{"AND p.IdEstado='#{state}'" unless state.blank?} 
                                                #{"AND l.Inicio <= str_to_date('#{end_date}', '%d/%m/%Y')" unless end_date.blank?}
                                                #{"AND l.Inicio >= str_to_date('#{ini_date}', '%d/%m/%Y')" unless ini_date.blank?}

                    GROUP BY p.IdProyecto, ll.IdUsuario;")
    end
  end

  def query_task_time user, state, ini_date, end_date
    execute do |mysql|           
      mysql.query("SELECT c.Nombre, p.Nombre, e.nombre, CONCAT(u.Nombre,' ',u.Apellidos) as Consultor, sum(t.duracion) as 'Tiempo Imputado Tareas'
                    FROM proyecto p INNER JOIN cliente c ON p.IdCliente=c.IdCliente
                    INNER JOIN tarea t ON p.IdProyecto=t.IdProyecto
                    INNER JOIN usuario u ON t.IdUsuario=u.IdUsuario
                    INNER JOIN estado e ON p.IdEstado=e.IdEstado

                    WHERE p.IdUsuario='#{user}' #{"AND p.IdEstado='#{state}'" unless state.blank?} 
                                                #{"AND t.Fecha <= str_to_date('#{end_date}', '%d/%m/%Y')" unless end_date.blank?}
                                                #{"AND t.Fecha >= str_to_date('#{ini_date}', '%d/%m/%Y')" unless ini_date.blank?}

                    GROUP BY p.IdProyecto, t.IdUsuario;")
    end
  end

  def query_assembly_time user, state, ini_date, end_date
    execute do |mysql|
      mysql.query("SELECT c.Nombre, p.Nombre, e.nombre, CONCAT(u.Nombre,' ',u.Apellidos) as Consultor, sum(rr.Duracion) as 'Tiempo Imputado Reuniones' , count(r.IdReunion) as 'Numero reuniones'
                    FROM proyecto p inner join cliente c ON p.IdCliente=c.IdCliente
                    INNER JOIN reunion r ON p.IdProyecto=r.IdProyecto
                    INNER JOIN reunionusuario rr ON r.IdReunion=rr.IdReunion
                    INNER JOIN usuario u ON rr.IdUsuario=u.IdUsuario
                    INNER JOIN estado e ON p.IdEstado=e.IdEstado

                    WHERE p.IdUsuario='#{user}' #{"AND p.IdEstado='#{state}'" unless state.blank?} 
                                                #{"AND r.Inicio <= str_to_date('#{end_date}', '%d/%m/%Y')" unless end_date.blank?}
                                                #{"AND r.Inicio >= str_to_date('#{ini_date}', '%d/%m/%Y')" unless ini_date.blank?}
                    GROUP BY p.IdProyecto, rr.IdUsuario;")
    end
  end

  def merge_row hash, row, timename
    #debugger if row[3] == "Juan Ramón Fdez"
    if hash[row[3]][row[1]][row[0]].nil?
      hash[row[3]][row[1]][row[0]] = {:estado => row[2], :tiempos => {:tickets => 0, :conferencias => 0, :tareas => 0, :reuniones => 0}, :n_reuniones => 0}
    end
    
    hash[row[3]][row[1]][row[0]][:tiempos][timename.to_sym] = row[4]
    hash[row[3]][row[1]][row[0]][:n_reuniones] = row[5] if timename == "reuniones"

  end

  private
  def execute
    mysql = Mysql.init()
    mysql.options(Mysql::SET_CHARSET_NAME, 'utf8')
    mysql.connect(@server, @user, @pass, @database, @port)
    result = yield mysql
    mysql.close()
    result
  end
end

