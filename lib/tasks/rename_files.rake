task :rename_files => :environment do
  
  directory = "#{RAILS_ROOT}/public/system/offers/"
  
  p "Renombrando ficheros en: #{directory}"

  Dir.chdir(directory)

  linked_count = 0
  unlinked_count = 0

  #borramos imagenes basura
  ficheros = []
  Dir.foreach(directory) do |filename|
    ficheros << filename
  end

  ficheros.sort.each do |filename|

    name = filename.to_s.split("_")
    
    if name.size < 4 
      unless File.directory?(filename)
        p "Basura: #{filename}"
        File.delete(filename)
      end
      next
    end

    if name.size == 4
      v = Version.first(:all, :conditions => {:offer_id => name[3].split(".")[0], :cod => 1})
    end
    if name.size == 5
      v = Version.first(:all, :conditions => {:offer_id => name[3].split(".")[0], :cod => name[4].first.to_i + 1})
    end

    if v.nil?
      p "Enlace roto: #{filename}"
      File.delete(filename)
      unlinked_count+=1
      next
    end
    
    extension = File.extname(filename)
    
    if extension.blank?
      extension = "."
    end

    if v.doc? and filename.include?(v.version_cod)
      linked_count+=1
      Dir.mkdir(v.offer_id.to_s) unless File.exists?(v.offer_id.to_s)

      if name[0].include? v.offer.account.name and !filename.include? "_0"
        FileUtils.copy(filename,"#{v.offer_id}/#{v.id}#{extension}")
        p "Si existe sobrescribo: #{filename}"
      end

      if filename.include? "_0" and !File.exist? "#{v.offer_id}/#{v.id}"
        FileUtils.copy(filename,"#{v.offer_id}/#{v.id}#{extension}")
        p "Tiene _0 pero no tiene normal: #{filename}"
      end

      if !filename.include? "_0" and !File.exist? "#{v.offer_id}/#{v.id}" and !name[0].include? v.offer.account.name
        FileUtils.copy(filename,"#{v.offer_id}/#{v.id}#{extension}")
        p "No tiene _0 pero la cuenta esta mal y no hay otra cosa mejor: #{filename}"
      end
      File.delete(filename)
    end

  end
  
  p "Enlaces correctos: #{linked_count}"
  p "Enlaces Rotos: #{unlinked_count}"
end

task :links_rotos => :environment do

  v = Version.all

  directory = "#{RAILS_ROOT}/public/system/offers/"
  Dir.chdir(directory)
  count = 0
  v.each do |ver|
    if ver.doc? and !File.exist? "#{ver.offer_id}/#{File.split(ver.doc.path)[1]}"
      p "link roto propuesta: #{ver.version_cod} cuenta: #{ver.offer.account.name}"
      count += 1
    end
  end
  p "Total: #{count}"
end

task :cross_accounts => :environment do
  require 'csv'
  
  directory = "#{RAILS_ROOT}/public/system/offers_old/"

  Dir.chdir(directory)
  count = 0
  CSV.open("cross_accounts.csv", "wb") do |csv|
    csv << ["Documento","Propuesta","Cuenta propuesta"]
    Dir.foreach(directory) do |filename|

      name = filename.to_s.split("_")
    
      if name.size >= 4
        a = Account.find_by_name(name[0])
        unless a.nil?
          o = Offer.find_by_id(name[3].split(".")[0])
          if !o.nil? and a.name != o.account.name
            csv << [filename, o.id, o.account.name]
            count = count+1
          end
        end
      end
    end
    csv << ["Total: #{count}"]
  end
end
