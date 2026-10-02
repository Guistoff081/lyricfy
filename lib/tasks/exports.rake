namespace :exports do
  desc "Processa exportações pendentes (worker local; Ctrl-C para parar)"
  task work: :environment do
    puts "Lyricfy worker: aguardando exportações."
    loop do
      processed = ExportProcessor.run_once
      sleep 1 unless processed
    end
  end

  desc "Recupera exportações interrompidas; execute apenas com workers parados"
  task recover: :environment do
    count = Export.where(status: "running").update_all(status: "queued", updated_at: Time.current)
    puts "#{count} exportação(ões) recolocada(s) na fila."
  end
end
