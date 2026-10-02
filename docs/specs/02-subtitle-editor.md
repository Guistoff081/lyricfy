# SPEC-02 — Editor e intercâmbio SRT

**História:** quero colar letra sincronizada e corrigir texto/tempos antes de gastar tempo renderizando.

**Comportamento:** editor por linhas e SRT bruto, importação de arquivo, prévia do rascunho e validação no servidor, preservação de caracteres Unicode e suporte a legendas de múltiplas linhas. Um bloco contém índice, intervalo `HH:MM:SS,mmm --> HH:MM:SS,mmm` e texto. A revisão deve sobreviver ao recarregamento da página. Download de SRT entrega a revisão salva.

**Aceite:**

- SRT válido com acentos, quebras de linha e finais de linha Windows é aceito.
- Intervalo malformado, início negativo, fim menor ou igual ao início e bloco sem texto são recusados com indicação do problema.
- Um erro não substitui silenciosamente a última revisão válida.
- Índices e serialização de saída são consistentes após parse/exportação.
- O usuário consegue baixar a legenda revisada sem renderizar vídeo.

**Decisão implementada:** exigir ordem cronológica e rejeitar sobreposições, tanto no editor quanto no servidor. O MVP não oferece sincronização automática, tradução ou edição por palavra.

## Estado e dependências

Implementado no MVP local; evidências e limites no [registro de verificação](verification.md). Persistência com SQLite, arquivos locais e processamento com FFmpeg/FFprobe. Consulte o [plano de agentes](agent-plan.md) para ownership e dependências.
