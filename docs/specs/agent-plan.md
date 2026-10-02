# Plano de agentes, dependências e integração

## Objetivo desta rodada

Entregar o MVP local confirmado: importar mídia → revisar SRT → exportar MP4 inteiro ou corte. SQLite mantém os registros, o disco local mantém arquivos e FFmpeg/FFprobe processam a mídia. Funcionalidades futuras de yt-dlp/IA não bloqueiam este fluxo.

## Divisão e ownership

| Papel | Arquivos sob responsabilidade | Entrega | Depende de |
| --- | --- | --- | --- |
| Produto | `docs/product/`, `docs/specs/` | Visão, specs, critérios de aceite e fases | PIN e decisões do usuário |
| Domínio | Serviços SRT/mídia e testes correspondentes, conforme acordo com integrador | Parse/serialize, validação, cortes, probe e render | Formato de resultado combinado |
| Interface | Views, componentes e CSS acordados com integrador | Listagem, importação, revisão, render e download | Rotas, modelos e parâmetros combinados |
| Integrador | Scaffold Rails, Gemfile, banco/migrations, modelos, controllers, jobs, rotas e README | Fluxo persistente, conexão dos serviços e execução ponta a ponta | Domínio e interface |

Os diretórios concretos de domínio e interface devem ser atribuídos pelo integrador antes de alterações concorrentes. Um arquivo tem um único responsável ativo. Mudança de contrato é comunicada antes de editar consumidores de outro agente. Com três agentes auxiliares, produto, domínio e interface podem avançar enquanto o integrador monta a aplicação.

## Contratos a combinar antes da integração

- **Projeto:** título, mídia e duração; acesso à revisão SRT salva e aos resultados.
- **Legenda:** parse recebe texto, retorna cues com tempos em uma unidade única e texto Unicode; falha fornece erro legível. Serialização retorna SRT válido.
- **Corte:** recebe início/fim na linha do tempo da fonte e retorna cues truncados e reposicionados. Não altera os cues originais.
- **Probe:** recebe caminho de arquivo local e retorna duração e disponibilidade de áudio/vídeo, ou erro estruturado.
- **Render:** recebe fonte, snapshot SRT, intervalo opcional e caminho de saída; retorna artefato ou falha, sem dependência do controller.
- **Job:** cria transição aguardando → processando → concluído/falhou e só publica download de saída concluída. Revisões posteriores não mudam o snapshot enfileirado.

## Ordem de execução

1. Integrador define nomes, rotas e contratos mínimos; produto registra o escopo e domínio inicia parser/cortes.
2. Integrador prepara SQLite, armazenamento e upload; interface implementa telas nos contratos combinados.
3. Domínio entrega probe/render e seus testes; integrador conecta jobs e downloads.
4. Integrador executa o fluxo com áudio e vídeo sintéticos e confere um corte atravessando legenda.
5. Resolver divergências entre implementação e specs; documentar no README o que funciona, testes feitos e limitações reais.

## Critério de entrega entre agentes

Informar caminhos modificados, comportamento entregue, comando de teste executado, resultado e pendências. Não declarar um fluxo funcionando com base apenas em sintaxe ou testes isolados. Testes de domínio não substituem a renderização real e o smoke test de interface.

## Próxima divisão após o MVP

Transcrição, tradução e aquisição por URL serão adaptadores independentes que produzem mídia ou revisões editáveis. IA visual será um produtor opcional de fundo/clipe. Esses agentes futuros reutilizam a persistência e a renderização verificadas, com suas próprias configurações e testes de indisponibilidade do provedor.
