# Lyricfy — visão de produto e brainstorming

## Origem e decisões propostas

O [PIN.md](../../PIN.md) é uma coleção de ideias, não um conjunto de instruções operacionais. Este documento transforma essas ideias em hipóteses de produto e propõe uma ordem de implementação. Rails, Tailwind e daisyUI aparecem no PIN como possibilidades. O usuário confirmou Rails local e o fluxo importar mídia → revisar SRT → exportar vídeo legendado e cortes. A implementação usa SQLite e arquivos locais; Tailwind e daisyUI não são requisitos confirmados.

**Proposta:** transformar uma faixa de áudio ou um videoclipe e uma letra sincronizada em um vídeo legendado que possa ser revisado, exportado e recortado, com processamento na própria máquina.

O primeiro usuário é o próprio criador do projeto. O produto começa como aplicação pessoal local, sem contas, colaboração, publicação em redes ou infraestrutura em nuvem. O fluxo inicial deve funcionar sem credenciais de serviços de IA.

## Jornada central

1. Criar um projeto e selecionar um arquivo local de áudio ou vídeo.
2. Colar uma legenda SRT com letra e tempos.
3. Corrigir o texto e a minutagem com feedback claro sobre erros.
4. Conferir a mídia e as legendas antes de renderizar.
5. Escolher o vídeo inteiro ou um intervalo de corte.
6. Renderizar um MP4, acompanhar o resultado e baixar o arquivo.
7. Preservar a fonte e a legenda para poder ajustar e gerar outra versão.

Para áudio, o primeiro resultado é um vídeo com fundo sólido e letra. Para vídeo, preserva-se a imagem original e incorporam-se as legendas. Geração visual por IA é uma evolução posterior, não uma dependência do produto inicial.

## Brainstorming e escolhas

| Ideia | Valor | Custo ou incerteza | Decisão inicial |
| --- | --- | --- | --- |
| SRT colado e revisável | Controle da letra e sincronização; resultado útil imediato | Requer que o usuário prepare os tempos | Centro do MVP |
| Vídeo com legenda incorporada | Funciona em players e redes sem suporte a legenda separada | Cada revisão exige nova renderização | Primeiro formato de saída |
| SRT exportável | Permite reutilizar a revisão em outros editores | Formatação precisa ser consistente | Incluir no MVP |
| Áudio com fundo simples | Gera um lyric video sem serviço externo | Resultado visual deliberadamente básico | Incluir no MVP |
| Cortes por tempo | Reaproveita trechos para compartilhamento | Legendas precisam ser recortadas e reposicionadas | Incluir uma faixa por render |
| Transcrição automática | Reduz trabalho de digitação | Canto e instrumentos prejudicam reconhecimento | Roadmap com revisão humana |
| Tradução PT-BR adaptada | Amplia compreensão da letra | Tradução literal pode perder sentido e ritmo | Roadmap; preservar original e tradução |
| Importação por URL/yt-dlp | Evita etapas manuais | Dependência externa e disponibilidade variável | Roadmap após fluxo local |
| Visuais gerados por IA | Cria identidade para cada música | Custos, latência, continuidade visual e credenciais | Experimento opcional posterior |
| CLI com GUI local | Automação e operação simples | Duas interfaces aumentam escopo | Extrair serviços reutilizáveis; CLI depois |
| Linha do tempo visual | Melhora o ajuste fino | Interface mais complexa | Depois de validar o editor SRT |

## Princípios

- A revisão da letra vem antes da renderização final.
- O usuário pode continuar usando o produto mesmo sem provedores de IA.
- Os arquivos de entrada são preservados; saídas são novos arquivos.
- Erros identificam o que corrigir: arquivo inválido, intervalo incorreto, SRT inválido ou ferramenta ausente.
- O estado de uma renderização é visível; uma solicitação não pode parecer concluída quando ainda está processando.
- Automação deve produzir um rascunho editável, com revisão especialmente importante em música e tradução.

## Hipóteses a validar usando o MVP

1. Colar e corrigir SRT já economiza trabalho suficiente para tornar o app útil.
2. Fundo simples é aceitável para validar a jornada de áudio antes de investir em imagens.
3. Um corte por exportação atende ao primeiro uso; montagem de vários trechos pode esperar.
4. A máquina do usuário dispõe de espaço para fonte, temporários e render final.
5. Vídeo em proporção original atende ao primeiro uso; exportar para redes não implica publicar nem garante formato vertical.

O primeiro teste de produto é concluir uma música a partir de mídia local e SRT, corrigir uma linha, renderizar novamente e gerar um corte com legenda sincronizada. Registrar o tempo gasto e os pontos em que foi necessário sair do app.

## Fases e resultado esperado

| Fase | Resultado verificável | Dependências |
| --- | --- | --- |
| 1 — Base local | Importar mídia, editar SRT e gerar MP4/legenda | Rails, armazenamento local, FFmpeg/FFprobe com libass |
| 2 — Ergonomia | Prévia sincronizada refinada, ajuste por linha, estilos e formatos verticais | Uso real da fase 1 |
| 3 — Assistência | Transcrição e tradução geram versões revisáveis | Escolha de motor local ou provedor e avaliação de qualidade |
| 4 — Aquisição e criação | URLs e fundos gerados integrados sem quebrar fluxo local | Adaptadores, credenciais quando aplicáveis e gestão de custos |
| 5 — Automação | CLI, presets e lote reutilizam os serviços do app | Contratos estáveis e necessidades confirmadas |

As fases são propostas de evolução. A existência destas specs não declara funcionalidades implementadas; o README do projeto registra o estado executável e as verificações realizadas.

## Fora do escopo inicial

Contas e permissões multiusuário, hospedagem pública, edição não linear, karaokê palavra a palavra, separação de voz/instrumentos, postagem automática, colaboração em tempo real, cobrança e geração automática integral de videoclipes. O uso é em loopback na própria máquina; acesso remoto exige uma decisão posterior sobre autenticação e proteção dos arquivos.
