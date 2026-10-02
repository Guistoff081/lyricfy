# Landing page do Lyricfy

Site estático de divulgação, em português, independente do servidor Rails. HTML, CSS e JavaScript sem dependências de build. A prévia demonstra a sincronização de texto, sem áudio; não executa o editor Rails.

Para conferir localmente, execute na raiz do repositório:

```sh
python3 -m http.server 8080 --directory site --bind 127.0.0.1
```

Publicação em https://guistoff081.github.io/lyricfy/ pelo workflow `pages.yml`. Apenas `site/` é publicado. Pushes na `main` que alterem esta pasta ou o workflow disparam uma publicação; também há execução manual.

As imagens são a arte original da demonstração e a captura real do editor já presentes em `docs/`. Recursos futuros são identificados como roadmap. Não há analytics, cookies ou chamadas a provedores externos na página.
