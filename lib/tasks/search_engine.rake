task :need_reindex? do

  if FileTest.exists?("#{RAILS_ROOT}/config/need_reindex")
    Rake::Task['ts:reindex'].invoke
    File.delete("#{RAILS_ROOT}/config/need_reindex")
  end
end
