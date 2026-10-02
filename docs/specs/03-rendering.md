# SPEC-03 — Renderização de vídeo

**História:** quero transformar minha revisão em um arquivo reproduzível com a letra visível.

**Comportamento:** vídeo de entrada mantém a imagem de origem; áudio recebe fundo sólido. Legendas são incorporadas ao vídeo por FFmpeg/libass. A saída é MP4, com vídeo H.264 e áudio AAC quando disponível. O pedido registra uma cópia da legenda e dos parâmetros usados para que editar o projeto depois não mude um trabalho já solicitado.

**Aceite:**

- Render de áudio com legenda produz MP4 com imagem e som.
- Render de vídeo com legenda produz MP4 com imagem da fonte, som quando presente e texto incorporado.
- Texto Unicode é exibido com uma fonte disponível; a documentação informa a dependência de fontes/libass.
- A interface distingue aguardando, processando, concluído e falhou.
- Sucesso só é marcado quando há um arquivo final válido para download.
- Ausência de FFmpeg/FFprobe, libass ou erro do processo aparece como falha compreensível.
- Argumentos de processo são passados como valores, sem interpolar texto de letra ou nomes de arquivo em comandos de shell.

**Limitações:** a primeira versão usa um estilo fixo, sem efeito karaokê ou composição IA. Não prometer percentagem de progresso se somente os estados forem implementados. Reiniciar o app pode exigir recuperação ou nova execução, conforme o mecanismo de jobs escolhido e documentado.

## Estado e dependências

Implementado no MVP local; evidências e limites no [registro de verificação](verification.md). Persistência com SQLite, arquivos locais e processamento com FFmpeg/FFprobe. Consulte o [plano de agentes](agent-plan.md) para ownership e dependências.

## Posicionamento da legenda

Escolha global entre superior, centro (padrão) e inferior. A configuração é validada e persistida no projeto; cada exportação registra uma cópia independente. A prévia acompanha a alteração antes de salvar. A exportação exige a revisão salva. O alinhamento horizontal permanece centralizado. Não há arraste livre ou posição individual por linha nesta versão. O SRT exportado permanece sem instruções de posicionamento.

Verificação: frames renderizados com FFmpeg foram inspecionados por distribuição de pixels para confirmar texto no terço superior, central e inferior; teste de integração confirma que alterações posteriores não mudam a posição de um trabalho enfileirado.

## Fonte e tamanho

O projeto permite Liberation Serif, Liberation Sans e Liberation Mono (instaladas localmente), com tamanho inteiro de 12 a 48. Padrão: Liberation Serif, 24. O tamanho é relativo à altura do quadro, na escala de composição do libass (288), não pixels finais. Prévia atualizada imediatamente; exportações registram fonte e tamanho da revisão salva. SRT não armazena essas configurações. Não há upload de fontes ou estilo individual por linha.

Validação: 13 testes, 154 assertions sem falhas. Fluxo de integração renderiza com Liberation Sans 32 e confirma que alterar o projeto depois não modifica o snapshot. Prévia, salvamento e recarga de fonte/tamanho verificados no navegador.
