# Dependências visuais locais

Instalação sem Node/npm, conforme a [documentação oficial Rails do daisyUI](https://daisyui.com/docs/install/rails/).

- `tailwindcss-rails` 4.6.0 e `tailwindcss-ruby` 4.3.3: compilador standalone distribuído por gems.
- `importmap-rails`: módulos JavaScript locais em `app/javascript`, pins em `config/importmap.rb`.
- `propshaft`: entrega dos assets locais.
- daisyUI 5.7.37: arquivos vendorizados `app/assets/tailwind/daisyui.mjs` e `daisyui-theme.mjs`, obtidos dos releases oficiais em 14/09/2026. Mantidos no projeto para builds reproduzíveis, sem baixar latest a cada execução.
- Tabler Icons 3.34.0: subset SVG original em `public/icons`, licença MIT incluída.

SHA-256:

```text
5399c9d59c274887dbd5fb70d0a087563e88479b57a1bc4290244ac9100926fd  daisyui.mjs
ebbcbdb01a7a66734846f1cfacc56193bbe85bde05021ec0385f18974e6eb08e  daisyui-theme.mjs
```

Compile com `bin/rails tailwindcss:build`; acompanhe alterações com `bin/rails tailwindcss:watch`. `bin/dev` compila uma vez antes de iniciar o Rails. A aplicação não acessa CDNs em execução.

## Referência e mídia demonstrativa

`selected-option-1.png` é o primeiro resultado exibido e escolhido pelo usuário. `../demo/night-city.png` foi gerado com ImageGen integrado e usado como frame de um vídeo demonstrativo local, sem conteúdo pessoal. Prompt: cidade noturna cinematográfica, céu azul escuro e lua, telhados e janelas iluminadas no terço inferior, sem texto/interface. O SRT em `../demo/primeiro-refrao.srt` contém versos demonstrativos originais. O áudio do teste é um tom sintético baixo, não uma música gerada.
