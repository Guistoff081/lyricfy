# SPEC-04 — Corte temporal

**História:** quero exportar um trecho de uma música para compartilhar.

**Comportamento:** informar início e fim, em segundos, para uma renderização. Sem intervalo explícito, usar a mídia inteira. Um corte usa a linha do tempo da fonte para localizar legendas e reposiciona os tempos para começar em zero na saída.

**Aceite:**

- Exigir `0 <= início < fim <= duração da mídia` para cortes explícitos.
- Legendas totalmente fora do corte não aparecem na saída.
- Legendas que cruzam as bordas são truncadas às bordas e têm os tempos reposicionados.
- Exemplo: legenda de 12 a 16 segundos em corte de 14 a 20 aparece de 0 a 2 segundos.
- Duração final corresponde ao intervalo solicitado, dentro da tolerância de codificação documentada.

**Limitações:** uma faixa contínua por exportação. Proporções original, vertical e quadrada estão disponíveis com barras para preservar a imagem. Reenquadramento inteligente, safe areas e presets específicos de redes ficam para evolução futura. Gerar um corte não publica conteúdo externamente.

## Estado e dependências

Implementado no MVP local; evidências e limites no [registro de verificação](verification.md). Persistência com SQLite, arquivos locais e processamento com FFmpeg/FFprobe. Consulte o [plano de agentes](agent-plan.md) para ownership e dependências.
