# Specs de produto e divisão do trabalho

Estas specs traduzem a [visão](../product/vision.md) em unidades de entrega. Os critérios descrevem o MVP e o roadmap; a evidência da implementação está no registro de verificação. Os nomes das entidades abaixo são conceituais; a implementação pode ajustá-los mantendo os comportamentos observáveis.

## Corte do MVP

Decisão confirmada pelo usuário: Rails local, SQLite e armazenamento local. O primeiro fluxo é importar mídia → revisar SRT → exportar vídeo legendado e cortes. Status: MVP implementado, template daisyUI Estúdio Noturno aplicado e fluxo de vídeo verificado no navegador. Veja o [registro de verificação](verification.md).

Uma aplicação Rails local permite criar um projeto, importar um arquivo de áudio/vídeo, salvar SRT validado, renderizar vídeo inteiro ou corte e baixar MP4/SRT. O processamento usa FFmpeg/FFprobe locais. Nenhum fluxo obrigatório exige IA, login de serviço externo ou rede. Estilos avançados, transcrição, tradução e geração visual ficam fora deste corte. A importação YouTube foi adicionada posteriormente por solicitação do usuário (SPEC-06).

## Specs individuais

- [SPEC-01 — project media ](01-project-media.md)
- [SPEC-02 — subtitle editor ](02-subtitle-editor.md)
- [SPEC-03 — rendering ](03-rendering.md)
- [SPEC-04 — clips ](04-clips.md)
- [SPEC-05 — local operation ](05-local-operation.md)
- [SPEC-06 — importação YouTube](06-youtube-import.md)

## Roadmap com contratos preliminares

| Spec | Entrega | Pré-condição e aceite futuro |
| --- | --- | --- |
| R-01 Transcrição | Motor gera rascunho com tempos | Escolher motor; preservar revisão anterior; toda transcrição pode ser editada; medir qualidade com canto real |
| R-02 Tradução PT-BR | Traduzir letra preservando sentido e tempos | Manter original e tradução separados; revisão manual; falha externa não perde texto |
| R-03 Importação URL | Entregue para vídeos YouTube via yt-dlp (SPEC-06) | Evolução: cancelamento e progresso percentual |
| R-04 Visuais IA | Gerar e selecionar fundos/clipes | Provedor opcional; orçamento/consentimento para gasto; prévia antes de render final; resultado associado ao projeto |
| R-05 Editor visual | Entregue: edição por linha, tempos, adicionar/remover e prévia | Evolução: waveform e ajuste por palavra |
| R-06 Formatos sociais | Exportar proporções/presets | Prévia do reenquadramento e da área útil da legenda; nenhuma postagem implícita |
| R-07 CLI e lote | Automatizar serviços existentes | Mesmas validações e saídas da GUI; códigos de saída e erros documentados |

## Fronteiras entre agentes

| Unidade | Responsabilidade | Contrato com as outras unidades | Evidência para entrega |
| --- | --- | --- | --- |
| Produto/specs | Visão, prioridades, histórias e critérios de aceite | Não alterar código de implementação | Specs rastreáveis ao PIN e hipóteses explícitas |
| Domínio/mídia | Parser SRT, cortes, probe e comando de render | Entrada tipada; resultado ou erro estruturado; sem dependência de tela | Testes de parser/corte e smoke test FFmpeg |
| Aplicação Rails | Persistência, upload, jobs, rotas e downloads | Chamar serviços e persistir estados/snapshots | Testes de fluxo e falhas |
| Interface | Listagem, formulário, editor, estados e resultados | Consumir modelos/rotas combinados previamente | Navegação manual e validação de estados vazios/erro |
| Integração | Resolver contratos, executar ponta a ponta e atualizar operação | Verificar o conjunto; evitar mudanças concorrentes nos mesmos arquivos | Áudio e vídeo de teste renderizados e saídas inspecionadas |

Produto e domínio podem começar em paralelo. Aplicação e interface precisam combinar nomes de modelos, parâmetros e rotas antes de editar arquivos compartilhados. Um agente integrador possui os arquivos de configuração e resolve dependências. Cada entrega deve informar arquivos alterados, comandos de verificação, limitações e contratos que mudou.

## Definition of done do MVP

1. Criar projeto com áudio local, salvar SRT e gerar MP4 reproduzível.
2. Repetir com vídeo local e verificar imagem, áudio e legenda.
3. Gerar um corte atravessando uma legenda e conferir o ajuste temporal.
4. Baixar SRT, recarregar projeto e confirmar persistência da revisão.
5. Exercitar SRT inválido, mídia inválida e falha de render sem perder a fonte ou a revisão válida.
6. Executar testes relevantes e registrar qualquer aceite ainda não implementado no README; specs sozinhas não contam como conclusão.
