# Índice de Features — Chord Master

> Onde cada coisa vive no código, para navegar rápido.

## Biblioteca (aba Músicas)

| Feature | Descrição | Arquivo |
|---------|-----------|---------|
| Lista de músicas | Cards com número, nome e etiquetas (Cifra Club, Vídeo) | `lib/presenter/pages/library/library_page.dart` |
| Busca | Por nome ou número, ignora acentos e maiúsculas | `lib/presenter/state/library_state.dart` (`filteredLibraryProvider`) |
| Sincronizar | Baixa da API e guarda cópia offline; automático na primeira abertura | `lib/presenter/state/library_state.dart` (`LibraryNotifier.sync`) |
| Ações da música | Adicionar ao repertório, editar (admin), copiar cifra | `lib/presenter/pages/library/library_page.dart` (`_ChordTile`) |
| Tema claro/escuro | Botão no topo; escuro é o padrão | `lib/presenter/state/settings_state.dart` |

## Repertório (aba)

| Feature | Descrição | Arquivo |
|---------|-----------|---------|
| Lista do culto | Ordem das músicas, com contador na aba | `lib/presenter/pages/setlist/setlist_page.dart` |
| Reordenar | Arrastar pela alça | `lib/presenter/state/setlist_state.dart` (`move`) |
| Remover / Desfazer | Remove com opção de desfazer | `lib/presenter/pages/setlist/setlist_page.dart` |
| Limpar | Esvazia o repertório (com confirmação) | `lib/presenter/pages/setlist/setlist_page.dart` |

## Leitura de cifra

| Feature | Descrição | Arquivo |
|---------|-----------|---------|
| Leitor | Biblioteca (`/cifra/:id`) e repertório (`/repertorio/:index`) | `lib/presenter/pages/chord/chord_page.dart` |
| Renderização | Fontes fixas: Roboto (app) e Roboto Mono (Cifra Club) | `lib/presenter/resources/widgets/chord_content_viewer.dart` |
| Transposição | − Tom +, mostra o tom resultante; toque no valor volta ao original | `lib/presenter/pages/chord/reader_widgets.dart`, `lib/domain/utils/chord_transposer.dart` |
| Salvar no repertório | Da biblioteca: adiciona já transposta. Do repertório: "Salvar tom" | `lib/presenter/pages/chord/chord_page.dart` |
| Ajustes de leitura | Tamanho da letra e margem, salvos no aparelho | `lib/presenter/pages/chord/reader_widgets.dart` |
| Vídeo do YouTube | Player dentro do app quando o link é do YouTube | `lib/presenter/pages/chord/chord_page.dart` |
| Links externos | Spotify etc. abrem fora do app | `lib/presenter/resources/widgets/link_launcher.dart` |

## Criar / editar cifra (admin)

| Feature | Descrição | Arquivo |
|---------|-----------|---------|
| Editor | Tela única; prévia ao lado (desktop) ou em aba (celular) | `lib/presenter/pages/chord/chord_editor_page.dart` |
| Rascunho | Cifra nova salva no aparelho enquanto digita; restaura ao voltar | `lib/presenter/pages/chord/chord_editor_page.dart`, `lib/app/services/app_preferences.dart` |
| Senha admin | SHA-256 via `--dart-define=ADMIN_PASSWORD_HASH` | `lib/app/services/admin_auth.dart`, `lib/presenter/resources/widgets/admin_password_dialog.dart` |

## Cifra Club

| Feature | Descrição | Arquivo |
|---------|-----------|---------|
| Buscar | Artista + música, ou link colado | `lib/presenter/pages/cifra_club/cifra_club_page.dart` |
| Scraping | HTML do `<pre>` via proxy CORS | `lib/data/api/cifra_club_scraper.dart` |
| Para o repertório | Adiciona já no tom escolhido | `lib/presenter/pages/cifra_club/cifra_club_page.dart` |
| Para a biblioteca | Abre o editor pré-preenchido (texto puro) | `lib/presenter/pages/cifra_club/cifra_club_page.dart` |

## Base

| Item | Arquivo |
|------|---------|
| Rotas | `lib/presenter/resources/routes/app_router.dart` |
| Providers de infraestrutura | `lib/app/providers.dart` |
| Design system | `lib/presenter/design_system/` |
| Marca (SVG) | `assets/brand/` |
