// Bilingual labels for pkgdown's built-in navigation and reference headings.
// Package documentation and tutorial translations live in their source files.
document.addEventListener("DOMContentLoaded", function () {
  const labels = new Map([
    ["Skip to contents", "Ir ao conteúdo / Skip to contents"],
    ["Search site", "Buscar no site / Search site"],
    ["Search for", "Buscar / Search"],
    ["Copy to clipboard", "Copiar código / Copy to clipboard"],
    ["Toggle navigation", "Alternar navegação / Toggle navigation"],
    ["On this page", "Nesta página / On this page"],
    ["Contents", "Conteúdo / Contents"],
    ["License", "Licença / License"],
    ["Community", "Comunidade / Community"],
    ["Citation", "Citação / Citation"],
    ["Developers", "Desenvolvedores / Developers"],
    ["Authors", "Autores / Authors"],
    ["Usage", "Uso / Usage"],
    ["Arguments", "Argumentos / Arguments"],
    ["Value", "Retorno / Value"],
    ["Format", "Formato / Format"],
    ["Source", "Fonte / Source"],
    ["Details", "Detalhes / Details"],
    ["References", "Referências / References"],
    ["Examples", "Exemplos / Examples"],
    ["See also", "Veja também / See also"],
    ["Browse source code", "Consultar código / Browse source code"],
    ["Report a bug", "Relatar problema / Report a bug"],
    ["Full license", "Licença completa / Full license"],
    ["Contributing guide", "Guia de contribuição / Contributing guide"],
    ["Citing educabr2", "Citar educabr2 / Citing educabr2"],
    ["More about authors...", "Mais sobre os autores / More about authors..."],
    ["Author, maintainer", "Autor e mantenedor / Author and maintainer"],
    ["Contributor", "Colaborador / Contributor"]
  ]);

  // Edit text nodes, preserving anchors, icons, code and heading IDs.
  const roots = document.querySelectorAll("h2, h3, aside, footer, .sidebar, .skip-link, a[href='#main']");
  for (const root of roots) {
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    let node;
    while ((node = walker.nextNode())) {
      if (node.parentElement.closest("script, style, code, pre")) continue;
      const original = node.nodeValue.trim();
      if (labels.has(original)) {
        node.nodeValue = node.nodeValue.replace(original, labels.get(original));
      } else if (root.matches("footer")) {
        node.nodeValue = node.nodeValue
          .replace(/^Developed by /, "Desenvolvido por / Developed by ")
          .replace(/^Site built with /, "Site construído com / Site built with ");
      }
    }
  }
  for (const element of document.querySelectorAll("[aria-label], [placeholder], [title]")) {
    for (const attribute of ["aria-label", "placeholder", "title"]) {
      const original = element.getAttribute(attribute);
      if (labels.has(original)) element.setAttribute(attribute, labels.get(original));
    }
  }
});
