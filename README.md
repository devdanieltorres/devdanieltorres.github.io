# devdanieltorres.github.io

Portfólio de Daniel Torres, desenvolvedor full-stack, publicado no GitHub Pages.

HTML estático, sem build: edite os arquivos e faça push na `main`.

## Estrutura

```
index.html              home
projects.html           lista de projetos com filtros
<slug>.html             um case por projeto (ex.: psicosocial.html)
404.html                página de erro (caminhos absolutos, mantida à mão)
assets/css/main.css     design system (tokens, componentes, temas claro/escuro)
assets/js/main.js       tema, menu, lightbox, filtros, scroll-spy, animações
assets/projetos/<slug>/ capturas em WebP: NN.webp (1900px) e NN-960.webp
assets/img/og/          imagens de compartilhamento (1200x630)
partials/               head, header e footer comuns a todas as páginas
scripts/                utilitários em PowerShell (não precisam de Node nem Python)
```

## Tarefas comuns

Rode os scripts a partir da raiz do repositório:

| Tarefa | Comando |
|---|---|
| Mudar header, footer ou `<head>` em todas as páginas | edite `partials/*.html` e rode `powershell -ExecutionPolicy Bypass -File scripts\sync-layout.ps1` |
| Tarjar dados pessoais em capturas novas | adicione as áreas em `scripts\tarjas.json` e rode `scripts\tarjar-imagens.ps1` |
| Converter capturas para WebP | `powershell -ExecutionPolicy Bypass -File scripts\otimizar-imagens.ps1 -Pasta "C:\capturas\novo" -Slug novo-case` |
| Gerar imagens de compartilhamento | `powershell -ExecutionPolicy Bypass -File scripts\gerar-og.ps1` |

Os scripts de imagem usam o Microsoft Edge (já instalado no Windows) em modo headless.

## Adicionar um projeto

1. **Proteja os dados.** Antes de tudo, tarje nas capturas nomes, matrículas, CPF, telefones, assinaturas, valores e razão social (`tarjar-imagens.ps1`).
2. **Converta as imagens** para WebP com `otimizar-imagens.ps1`, usando o slug do novo case.
3. **Crie o case.** Duplique um case parecido (ex.: `batidas-ponto.html`) como `<slug>.html` e troque textos, imagens e o `view-transition-name` (`capa-<slug>`).
4. **Liste o projeto.** Adicione um card em `projects.html` com o `data-category` certo e atualize as contagens dos filtros.
5. **Ligue a navegação.** Ajuste os links "Anterior" e "Próximo" do case novo e dos vizinhos.
6. **Feche a publicação.** Rode `sync-layout.ps1` e `gerar-og.ps1` e acrescente a URL em `sitemap.xml`.

## Privacidade: histórico do git

As capturas antigas, sem tarja, e os rascunhos `doc.txt` foram retirados do site. Os originais estão em `..\portfolio-originais\`, fora do repositório. Mesmo assim, eles **continuam no histórico público do GitHub**.

Para apagá-los de vez é preciso reescrever o histórico. A operação é irreversível e reescreve todos os commits:

```bash
pip install git-filter-repo
git clone --mirror https://github.com/devdanieltorres/devdanieltorres.github.io.git
cd devdanieltorres.github.io.git
git filter-repo --path-glob 'assets/projetos/*.png' --path-glob 'assets/projetos/*/doc.txt' --invert-paths
git push --force
```

Depois do push forçado, peça ao suporte do GitHub a limpeza do cache de objetos antigos, se necessário.
