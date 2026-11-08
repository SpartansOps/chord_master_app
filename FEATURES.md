# 📋 Index de Features - Chord Master App

> Documentação para navegação rápida durante desenvolvimento e alterações.

---

## 🎵 Gestão de Cifras

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Criar Cifra | Formulário para adicionar nova cifra (nome, número, intro, link, conteúdo) | `lib/presenter/pages/chord/create_chord_page.dart` |
| Editar Cifra | Mesma tela de criação, modo edição | `lib/presenter/pages/chord/create_chord_page.dart` |
| Visualizar Cifra | Exibe conteúdo da cifra com formatação | `lib/presenter/pages/chord/chord_page.dart` |
| Copiar Cifra | Copia conteúdo para clipboard | `lib/presenter/pages/home/home_page.dart:307` |
| Senha Admin | Criar, editar e apagar cifras pedem a senha admin (SHA-256 via `--dart-define=ADMIN_PASSWORD_HASH`) | `lib/app/services/admin_auth.dart`, `lib/presenter/resources/widgets/admin_password_dialog.dart` |

---

## 🔍 Busca e Filtros

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Busca por Nome/Número | Filtra lista por nome ou número da música | `lib/presenter/pages/home/home_viewmodel.dart:157` |
| Contadores | Exibe total de músicas e músicas na lista | `lib/presenter/pages/home/home_page.dart:56` |

---

## 📝 Lista de Repertório

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Adicionar à Lista | Salva cifra no repertório do dia | `lib/presenter/pages/home/home_viewmodel.dart:94` |
| Remover da Lista | Remove cifra da lista | `lib/presenter/pages/home/home_viewmodel.dart:116` |
| Reordenar Lista | Drag-and-drop para reordenar | `lib/presenter/pages/home/home_viewmodel.dart:134` |
| Visualizar Lista | Página dedicada à lista de repertório | `lib/presenter/pages/home/list_page.dart` |

---

## 🎸 Cifra Club Integration

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Buscar no Cifra Club | Scraping de cifras do site | `lib/data/api/cifra_club_scraper.dart` |
| Visualizar Cifra Club | Renderiza HTML com formatação (acordes em destaque) | `lib/presenter/pages/cifra_club/cifra_club_page.dart` |
| Salvar da Cifra Club | Importa cifra para lista local | `lib/presenter/pages/cifra_club/cifra_club_page.dart:101` |

---

## 🎼 Transposição de Tom

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Transpor Cifra (HTML) | Transpõe acordes em conteúdo HTML (Cifra Club) | `lib/domain/utils/chord_transposer.dart:9` |
| Transpor Cifra (Texto) | Transpõe acordes em texto plano | `lib/domain/utils/chord_transposer.dart:21` |
| Controles de Tom | Slider visual com nome da nota atual | `lib/presenter/pages/chord/chord_page.dart:162` |

---

## 🔤 Ajustes de Fonte e Margem

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Aumentar/Diminuir Fonte | Ajusta tamanho do texto da cifra | `lib/presenter/pages/chord/chord_page.dart:183` |
| Aumentar/Diminuir Margem | Ajusta a margem lateral do conteúdo da cifra (0 a 48, passo 4) | `lib/presenter/pages/chord/chord_viewmodel.dart` |

---

## 🎬 YouTube Player

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Player Integrado | Reproduz vídeos do YouTube dentro do app | `lib/presenter/pages/chord/chord_page.dart:30` |

---

## 🔗 Links Externos

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Abrir Link | Abre links (YouTube, Spotify, etc.) no navegador/app externo | `lib/presenter/pages/home/home_page.dart:258` |

---

## ⚙️ Configurações

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Dark Mode | Alternar entre tema claro/escuro | `lib/presenter/pages/settings/settings_viewmodel.dart` |
| Persistência | Salva preferências localmente | `lib/app/services/app_preferences.dart` |

---

## 📥 Sincronização

| Feature | Descrição | Arquivo Principal |
|---------|-----------|-------------------|
| Download de Cifras | Baixa lista de cifras da API | `lib/presenter/pages/home/home_viewmodel.dart:57` |
| Verificação de Conexão | Detecta status da internet | `lib/presenter/pages/home/home_viewmodel.dart:61` |
| Cache Local | Salva dados localmente | `lib/presenter/pages/home/home_viewmodel.dart:68` |

---

## 🧭 Navegação (Rotas)

| Rota | Página | Descrição |
|------|--------|-----------|
| `/` | MyHomePage | Tela principal com busca e lista |
| `/chord` | ChordPage | Visualização de cifra |
| `/listChords` | ListChordPage | Lista de repertório |
| `/createOrUpdateChord` | CreateChordPage | Criar/Editar cifra |

**Definição das rotas:** `lib/presenter/resources/routes/routes_manager.dart`

---

## 📦 Dependências Principais

| Pacote | Uso |
|--------|-----|
| `get_it` | Injeção de dependências |
| `rxdart` | Gerenciamento de streams |
| `shared_preferences` | Armazenamento local |
| `http` | Requisições HTTP |
| `connectivity_plus` | Verificação de conexão |
| `url_launcher` | Abrir links externos |
| `youtube_player_iframe` | Player do YouTube |
| `google_fonts` | Fontes personalizadas |
| `html` | Parsing de HTML (scraping) |

---

## 🏗️ Arquitetura

```
lib/
├── app/              # Configurações do app, DI, constantes
├── data/             # API, modelos, repositórios, providers
├── domain/           # Entidades de negócio e utilitários
├── presenter/        # UI (pages, widgets, routes, theme)
│   ├── pages/        # Telas do app
│   └── resources/    # Widgets, tema, rotas
└── main.dart         # Entry point
```

---

## 🎨 Widgets Customizados

| Widget | Descrição | Arquivo |
|--------|-----------|---------|
| `ChordContentViewer` | Exibe cifra com acordes destacados e hierarquia visual | `lib/presenter/resources/widgets/chord_content_viewer.dart` |
| `SpeedDialFab` | FAB com menu expansivo (Cifra Club, Lista, Nova Cifra) | `lib/presenter/resources/widgets/speed_dial_fab.dart` |
| `CustomTextField` | Campo de texto personalizado | `lib/presenter/resources/widgets/custom_text_field.dart` |
| `SnackBar` | Mensagem de feedback | `lib/presenter/resources/widgets/snack_bar.dart` |
