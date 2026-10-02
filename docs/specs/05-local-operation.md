# SPEC-05 — Experiência local e operação

**História:** quero iniciar o aplicativo e entender como corrigir problemas sem depender de serviços externos.

**Aceite:**

- README apresenta dependências, comandos de instalação, inicialização e teste.
- Arquivos e banco são armazenados localmente em caminhos documentados.
- O fluxo tem navegação entre projetos, editor e resultado de render.
- Formulários têm rótulos e erros visíveis; renderização longa não mantém uma requisição web aberta indefinidamente.
- O app é apresentado como pessoal/local. Exposição pública e multiusuário não são alegadas como suportadas.

## Estado e dependências

Implementado no MVP local; evidências e limites no [registro de verificação](verification.md). Persistência com SQLite, arquivos locais e processamento com FFmpeg/FFprobe. Consulte o [plano de agentes](agent-plan.md) para ownership e dependências.
