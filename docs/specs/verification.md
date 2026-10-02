# Verificação da implementação — 14/09/2026

MVP local implementado com o template Estúdio Noturno escolhido pelo usuário. IA permanece no roadmap. Importação YouTube adicionada na SPEC-06.

| Entrega | Evidência |
| --- | --- |
| SPEC-01 Mídia/projetos | Testes importam áudio e vídeo, preservam bytes e metadados e rejeitam mídia inválida; importação exercitada no navegador |
| SPEC-02 SRT | Validação UTF-8, tempos e sobreposição; importação de arquivo, edição por linha, adicionar/remover, ajuste temporal, SRT bruto e persistência exercitados |
| SPEC-03 Render | FFmpeg real, snapshot, download MP4 e falha sem perda da revisão; saída de vídeo inspecionada visualmente |
| SPEC-04 Cortes | Corte não zero, truncamento e reposicionamento das legendas testados; corte de 12–16 segundos exportado pelo navegador |
| SPEC-05 Local | Rails e worker separados, Tailwind standalone, daisyUI local, importmap; desktop e mobile verificados |

## Contratos reais

- `Lyricfy::Subtitles`: cues com `start_ms`, `end_ms`, `text`; parse/dump/clip/vtt.
- `Lyricfy::MediaProbe`: duração, presença de vídeo/áudio e dimensões.
- `Lyricfy::Renderer`: entrada, SRT, saída, intervalo e formato; processo FFmpeg sem shell.
- `Project`: fonte imutável, metadados e SRT revisado; diretório separado por ambiente.
- `Export`: snapshot de SRT/parâmetros e estados queued/running/completed/failed.
- `ExportProcessor`: claim atômico de job pendente, execução, validação da saída e persistência de sucesso/falha.
- `exports:work`: worker local separado; `exports:recover`: recuperação explícita com workers parados.

## Decisões de implementação

O editor oferece linhas e SRT bruto, importação local e prévia sincronizada do rascunho. Alterações não salvas impedem exportação e geram aviso antes de sair. O player suporta requisições HTTP Range para busca temporal. A prévia não simula proporções da saída.

A versão usa armazenamento direto em disco e fila na tabela exports. Active Storage não é necessário para os arquivos do fluxo atual. JSON fica na série 2.21 porque a combinação testada de Rails 8.1 e JSON 3 falhou na desserialização dos cookies de sessão.

## Resultado dos checks

- `bin/rails test`: 8 testes, 86 assertions, sem falhas/erros/skips.
- `bin/rails zeitwerk:check`: passou.
- `bundle exec brakeman --no-pager -q`: análise concluída, cinco alertas médios de acesso a arquivos. Revisão dos caminhos: derivam de IDs inteiros do banco sob `storage/<ambiente>/projects`, não do nome original ou de um caminho enviado pelo usuário. Nenhum alerta foi suprimido. O nome original é somente metadado de download. Uma futura API para caminhos deve preservar essa separação.
- O wrapper gerado `bin/brakeman` falhou na consulta de versão mais recente; a análise instalada foi executada diretamente pelo Bundler. Não alegar aprovação automática do wrapper.

## Evidência visual de render

[Frame extraído do MP4 real](../verification/portuguese-subtitles.png): fundo azul da fonte preservado, texto “Canção, coração e manhã” legível com acentos. Mídia sintética de 640×360 gerada com FFmpeg, renderizada pelo serviço Lyricfy::Renderer e inspecionada em 0,5 s. Essa evidência valida a saída de vídeo, não a interface da aplicação.

## Evidências da interface

Capturas e comparação com a referência estão no [relatório de design](../../design-qa.md). A demonstração usa mídia e letra originais em `docs/demo/`. O fluxo de vídeo incluiu importação, oito cues, revisão, persistência, corte, fila e download. O fluxo de áudio foi repetido no navegador com arquivo sintético de quatro segundos e exportação vertical.

## Limitações operacionais

Uso pessoal em loopback, sem autenticação. Worker sem cancelamento, timeout ou percentual de progresso. Atualização de estado por recarga explícita. Não há backup, retenção automática ou limite de upload. A recuperação de trabalhos interrompidos exige parar os workers antes de `exports:recover`.

## Extensão YouTube

12 testes, 133 assertions, sem falhas, erros ou skips após a integração de fila, importador e formulário. O sucesso de download nos testes usa um executável fixture; isso não comprova disponibilidade de um vídeo externo.

Teste externo concluído: o link fornecido pelo usuário (`UzGcGNPzsoI`, com parâmetro de playlist) produziu o projeto 3, **REFORMED - "The Conqueror" (Official Video)**, duração de aproximadamente 219,8 segundos. A tela de acompanhamento redirecionou ao editor; o player carregou sem erro (readyState 4). Nenhuma legenda pt-BR/pt/en foi disponibilizada pelo download; a interface exibiu o aviso e manteve o editor vazio. O primeiro teste dentro do sandbox falhou por DNS; a repetição autorizada com rede concluiu. `bin/rails zeitwerk:check` passou.

## Posicionamento

13 testes, 150 assertions, sem falhas/erros/skips. Prévia inferior e salvamento exercitados no navegador. Teste real de frames confirma as três posições; snapshot de exportação verificado.
