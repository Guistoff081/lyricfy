# Lyricfy

Estúdio pessoal local para importar áudio/vídeo, revisar letras em SRT e exportar vídeos legendados ou cortes. Rails 8.1, SQLite e FFmpeg. A [visão de produto](docs/product/vision.md), as [specs](docs/specs/README.md) e o [plano de agentes](docs/specs/agent-plan.md) documentam escopo, contratos e evolução.

## Estado

MVP local implementado com o template **Estúdio Noturno** (opção 1): importação de áudio/vídeo, editor por linhas e SRT, prévia sincronizada, exportação MP4 e cortes, fila persistente e download. Interface responsiva com componentes daisyUI. Veja a [verificação funcional](docs/specs/verification.md) e a [revisão visual](design-qa.md).

## Executar localmente

Requer Ruby (testado com 4.0.6), Bundler, FFmpeg e FFprobe no PATH. FFmpeg precisa incluir libx264, AAC e filtro subtitles/libass. Instale uma fonte com caracteres portugueses (por exemplo Liberation Serif).

```sh
bundle install
bin/rails db:prepare
bin/dev
```

Em outro terminal, no mesmo diretório:

```sh
bin/rails exports:work
```

Abra http://127.0.0.1:3000. `bin/dev` vincula o servidor ao loopback. A aplicação não tem autenticação nem suporte a hospedagem pública/multiusuário.

1. Crie um projeto e selecione um arquivo local. A fonte é copiada e identificada com FFprobe.
2. Importe ou cole SRT em UTF-8, revise e salve. Tempos devem ser crescentes, sem sobreposição e dentro da mídia.
3. Exporte a mídia inteira ou informe início/fim em segundos. Formatos vertical e quadrado preservam a imagem com barras; não fazem recorte inteligente.
4. Atualize a página para acompanhar a fila e baixe o MP4. Cada exportação preserva a legenda salva no momento da solicitação.

Áudio recebe fundo sólido. Legendas são queimadas no vídeo; SRT também pode ser baixado separadamente. A prévia usa a mídia original e acompanha as alterações de legenda antes de salvar. A exportação exige salvar a revisão; cada trabalho preserva seu próprio snapshot. O controle **Posição da legenda** permite escolher Superior, Centro ou Inferior para todas as linhas. A escolha acompanha a prévia, é salva junto da revisão e fica preservada em cada exportação. O SRT baixado contém texto e tempos; a posição é uma configuração do projeto. A prévia não simula o enquadramento final.

## Frontend sem Node

JavaScript é servido por importmap e Propshaft. Tailwind compila com o binário da gem `tailwindcss-rails`; daisyUI 5.7.37 e o plugin de tema ficam copiados em `app/assets/tailwind/`. Não é necessário npm, Yarn ou Node para instalar, executar ou compilar o projeto.

`bin/dev` compila o CSS antes de iniciar o servidor. Durante alterações de estilos, execute em outro terminal:

```sh
bin/rails tailwindcss:watch
```

Para compilar uma vez: `bin/rails tailwindcss:build`. Versões, hashes e atualização dos plugins estão em [dependências de design](docs/design/dependencies.md).

## Importar do YouTube

Na tela **Importar mídia**, cole o link em **Link do vídeo**. O aplicativo baixa somente o vídeo selecionado, preenche título e duração e tenta importar legendas disponíveis em português ou inglês. Sem legenda válida, abre o editor vazio com um aviso.

Requer `yt-dlp` no PATH. Nesta máquina também há Deno para suporte JavaScript do YouTube, sem Node no frontend. Inicie o worker de importação em outro terminal:

```sh
bin/rails imports:work
```

Também é possível enfileirar pelo CLI:

```sh
bin/rails 'imports:youtube[https://youtu.be/UzGcGNPzsoI]'
```

O comando imprime o endereço de acompanhamento. Atualize essa tela para abrir o projeto concluído. Veja [contratos e recuperação](docs/specs/06-youtube-import.md).

## Arquivos e recuperação

- Banco: `storage/development.sqlite3` (veja `config/database.yml`).
- Mídias: `storage/development/projects/ID/source`.
- Saídas: `storage/development/projects/ID/exports/EXPORT_ID.mp4`.
- Testes usam `storage/test/projects/` separado.
- Não há exclusão automática, limite de tamanho de upload ou política de backup. A origem selecionada não é alterada.
- Jobs ficam no SQLite; o worker separado realiza uma exportação por vez. Não há percentual de progresso, cancelamento ou timeout do FFmpeg nesta versão.
- Se um worker for interrompido durante render, pare todos os workers antes de executar `bin/rails exports:recover`, depois inicie o worker novamente. Essa recuperação recoloca jobs `running` na fila. Jobs `failed` podem ser solicitados de novo pelo formulário.

## Verificar

```sh
bin/rails test
bin/rails zeitwerk:check
```

Os testes geram mídia sintética local com FFmpeg. Cobrem parser, intervalos, corte com início não zero, legendas via comparação de frames, áudio para vídeo, upload, persistência da revisão, snapshot, render e download. Não substituem a verificação visual da interface no navegador.

## Próximas etapas

Evoluir pelas specs de transcrição, tradução PT-BR, visuais IA e CLI. Essas integrações não estão implementadas nem são necessárias para o primeiro fluxo local.

Referências técnicas: [Rails](https://guides.rubyonrails.org/getting_started.html), [filtros FFmpeg](https://ffmpeg.org/ffmpeg-filters.html), [temas daisyUI](https://daisyui.com/docs/themes/).

### Tipografia das legendas

No editor, use **Fonte da legenda** (serifada, sem serifa ou monoespaçada) e **Tamanho da letra** (12–48). A prévia acompanha as alterações. Clique em **Salvar legenda** antes de exportar. Instale as fontes Liberation Serif, Sans e Mono para usar as mesmas famílias na prévia e na renderização local.
