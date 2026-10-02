# SPEC-01 — Projeto e mídia de origem

**História:** como criador, quero organizar uma música e sua mídia para revisar e exportar versões sem alterar o arquivo original.

**Comportamento:** projeto com título, mídia de origem, legenda e renderizações. O usuário seleciona um arquivo local pela interface. A aplicação armazena a cópia e verifica as características da mídia com FFprobe. Um nome de arquivo ou MIME declarado não é suficiente para identificar áudio/vídeo válido.

**Aceite:**

- Um áudio e um vídeo válidos podem ser importados em projetos independentes.
- Arquivo ausente, vazio ou sem trilhas utilizáveis gera mensagem de erro compreensível.
- A duração é obtida da mídia e pode ser usada para validar cortes.
- O arquivo original não é reescrito pela importação ou renderização.
- O título aparece na listagem e o usuário consegue retornar ao projeto.

**Limitações:** formatos aceitos dependem dos codecs disponíveis na instalação local. Persistência local não equivale a backup. Política de retenção, limites de tamanho e substituição de mídia devem ser documentados conforme implementados.

## Estado e dependências

Implementado no MVP local; evidências e limites no [registro de verificação](verification.md). Persistência com SQLite, arquivos locais e processamento com FFmpeg/FFprobe. Consulte o [plano de agentes](agent-plan.md) para ownership e dependências.
