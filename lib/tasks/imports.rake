namespace :imports do
  desc "Importa um vídeo: bin/rails 'imports:youtube[https://youtu.be/VIDEO_ID]'"
  task :youtube, [:url] => :environment do |_task, args|
    item = MediaImport.create!(url: args[:url])
    puts "Importação #{item.id} na fila. Acompanhe em http://127.0.0.1:3000/media_imports/#{item.id}"
  end

  desc "Processa importações YouTube pendentes (Ctrl-C para parar)"
  task work: :environment do
    puts "Lyricfy: aguardando importações."
    loop do
      sleep 1 unless MediaImportProcessor.run_once
    end
  end

  desc "Recupera importações interrompidas; execute apenas com workers parados"
  task recover: :environment do
    puts MediaImport.where(status: "running").update_all(status: "queued", updated_at: Time.current)
  end
end
