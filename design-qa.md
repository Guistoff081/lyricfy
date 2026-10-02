# Revisão visual — Estúdio Noturno

Resultado: aprovado para o MVP local selecionado pelo usuário, com diferenças de escopo registradas abaixo. A imagem de referência não é evidência funcional.

## Referência e evidências

- [Opção 1 selecionada](docs/design/selected-option-1.png).
- [Comparação lado a lado](docs/verification/design-comparison.png), com as duas imagens normalizadas para 1440×1024.
- [Editor desktop](docs/verification/editor-desktop.png).
- [Editor mobile](docs/verification/editor-mobile.png), viewport 390×844, sem overflow horizontal (scrollWidth igual a clientWidth).
- [Frame da exportação real](docs/verification/final-export.png), legenda centralizada e com fonte serifada.

## Avaliação

| Superfície | Resultado |
| --- | --- |
| Layout | Sidebar, cabeçalho, prévia à esquerda, editor à direita e exportação inferior preservados; empilhamento em telas menores |
| Tipografia | Hierarquia legível, campos compactos, legenda serifada e centralizada |
| Cores | Fundo carvão, painéis escuros, violeta como ação principal e seleção |
| Imagem | Cidade noturna original gerada para demonstração, sem dependência de mídia remota |
| Conteúdo e controles | Componentes daisyUI conectados às operações reais; oito linhas de demonstração visíveis no desktop |

## Iterações verificadas

A revisão identificou busca temporal sem suporte HTTP Range, duplicação de legenda na fronteira entre cues e excesso de altura nas linhas. Foram corrigidos o streaming parcial, a camada de prévia sincronizada e a altura dos campos. O render recebeu alinhamento central compatível com libass. A comparação final e a captura mobile foram inspecionadas; não restaram defeitos visuais bloqueadores identificados. Console do fluxo de vídeo sem avisos ou erros na verificação.

## Diferenças intencionais

O player usa controles nativos. A mídia de demonstração tem 32 segundos e imagem própria. Abas de configurações avançadas, estilos e contadores fictícios do conceito não foram apresentados como funcionalidades prontas. A exportação oferece intervalo e proporção reais. Prévia de reenquadramento, waveform, animação por palavra e estilos configuráveis ficam fora deste MVP. A prévia acompanha o rascunho; a renderização usa a revisão salva.
