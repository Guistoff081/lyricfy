# SPEC-06 — Importação YouTube

## Fluxo entregue

Colar o link em **Importar mídia → Ou cole um vídeo do YouTube**, ou usar o comando:

```sh
bin/rails 'imports:youtube[https://youtu.be/UzGcGNPzsoI?list=RDUzGcGNPzsoI]'
```

Ambas as entradas criam `MediaImport` persistido. O worker `bin/rails imports:work` chama yt-dlp como subprocesso Unix, sem shell, e registra os estados queued/running/completed/failed. A tela de acompanhamento abre o projeto ao atualizar depois da conclusão. A listagem mantém acesso às importações pendentes e falhas.

## Preenchimento

- URL aceita somente vídeos YouTube e é normalizada; parâmetros de playlist não entram no download.
- Título vem dos metadados; duração e trilhas são confirmadas por FFprobe.
- Mídia MP4 é copiada para o armazenamento do projeto.
- Legendas disponíveis, incluindo automáticas, são procuradas em pt-BR, pt e en, nessa prioridade, e convertidas em SRT.
- A legenda é rascunho para revisão, não transcrição gerada pelo Lyricfy. Se indisponível, falhar ou contrariar os tempos aceitos pelo editor, o vídeo continua sendo importado com aviso e editor vazio.
- URLs privadas, playlists sem vídeo e hosts arbitrários são recusados. Configurações pessoais do yt-dlp não são carregadas; o app não lê cookies do navegador.

## Operação

Requer yt-dlp e FFmpeg no PATH. Para suporte completo ao YouTube, a instalação do yt-dlp pode exigir runtime JavaScript e componentes EJS; Deno permite isso sem instalar Node no frontend. Consulte a [documentação oficial](https://github.com/yt-dlp/yt-dlp#dependencies).

Cada subprocesso tem limite de 30 minutos e é encerrado junto com seus filhos em timeout. Temporários são removidos após sucesso ou falha; encerramento abrupto do worker pode deixar temporários no diretório do sistema. Com todos os workers de importação parados, `bin/rails imports:recover` recoloca trabalhos interrompidos na fila. Downloads grandes continuam sujeitos ao espaço em disco local. Não há login, cancelamento ou percentual de download nesta versão.

## Verificação

Testes determinísticos substituem apenas o executável yt-dlp por uma fixture local; FFmpeg gera mídia real e o restante do fluxo usa serviços, banco e arquivos reais. Cobrem projeto pré-preenchido com SRT, falha sem criar projeto, canonicalização de vídeo único, rejeição de URLs e tela de fila. Testes externos dependem da disponibilidade e das restrições do YouTube.
