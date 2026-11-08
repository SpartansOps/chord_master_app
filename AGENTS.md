# AGENTS.md — Chord Master

Guia para agentes (Claude, Codex, Cursor etc.) e pessoas que trabalham neste repositório.

## O que é

App Flutter para leitura de cifras usado pela equipe de louvor da IEQ Timburi.
Roda como **PWA** (deploy na Netlify, `web/_redirects`); ainda não está nas lojas.
Uso típico: no palco, celular na mão ou no suporte, pouca luz. Isso pesa nas decisões de UI:
legibilidade da cifra, contraste, modo escuro e uso com uma mão vêm antes de enfeite.

Idioma: UI, mensagens e comentários em **português**. Nomes de código em inglês.

## Como rodar

```bash
flutter pub get
flutter run -d chrome \
  --dart-define=API_BASE_URL=<url da API> \
  --dart-define=ADMIN_PASSWORD_HASH=<sha256 da senha admin>
```

- `API_BASE_URL`: base da API de cifras (endpoints em `lib/data/api/api_end_points.dart`: `/read`, `/create`, `/update`).
- `ADMIN_PASSWORD_HASH`: SHA-256 (hex) da senha que libera criar/editar. Sem ele, ninguém vira admin.
- Build de produção: `flutter build web` com os mesmos `--dart-define`.
- Gerar código (`json_serializable`): `dart run build_runner build --delete-conflicting-outputs`.

Antes de entregar uma mudança: `flutter analyze` sem issues **e** `flutter build web` compilando
(o analyzer não pega tudo: um pacote incompatível com o Flutter atual só quebra na compilação).

Testes automatizados: por enquanto não. O dono do projeto testa manualmente.

## Estrutura

```
lib/
  main.dart           ProviderScope + SharedPreferences + URLs sem "#"
  app/
    app_widget.dart   MaterialApp.router (tema claro/escuro)
    providers.dart    providers de infraestrutura (prefs, http, api, repositório, scraper, admin)
    services/         AppPreferences (localStorage), AdminAuth
  data/               api (ChordApi, CifraClubScraper, http), models (*.g.dart gerados), mapper, repository
  domain/             entidades (Chord, Settings) e utils puros (chord_transposer, chord_markup)
  presenter/
    design_system/    tokens, tema, ícones e componentes (ver abaixo)
    state/            Notifiers do Riverpod: biblioteca + busca, repertório, configurações
    pages/            shell (navegação inferior), library, setlist, chord (leitura/editor), cifra_club
    resources/        rotas (go_router), widgets de domínio (leitor de cifra, admin, links), validators
assets/brand/         SVGs da marca (fonte dos PNGs em web/icons e assets/images/logo.png)
```

Índice de features com o arquivo de cada uma: [FEATURES.md](FEATURES.md). Atualize-o quando criar ou mover uma feature.

## Estado (Riverpod)

- Riverpod 3, **sem geração de código**: `Provider`, `Notifier`/`NotifierProvider`.
- Infraestrutura em `lib/app/providers.dart`; o `sharedPreferencesProvider` é sobrescrito no `main()`.
- Estado de tela compartilhado em `lib/presenter/state/`. Estado só da tela (tom atual, campos do formulário) fica no `State` do widget.
- Ações que precisam avisar o usuário retornam o resultado (ex.: `LibraryNotifier.sync()` retorna `({ok, message})`) e a tela mostra o toast. Nada de streams de eventos.
- Em `ConsumerState`, não use `ref` dentro de `dispose()`; leia o que precisar no `initState`.

## Navegação (go_router)

Rotas em `lib/presenter/resources/routes/app_router.dart`, nomes em `AppRoutes`.

| URL | Tela |
|-----|------|
| `/` | Biblioteca (aba Músicas) |
| `/repertorio` | Repertório (aba) |
| `/cifra/:id` | Leitura de uma cifra da biblioteca |
| `/cifra/:id/editar` | Editor (admin) |
| `/repertorio/:index` | Leitura de um item do repertório |
| `/nova` | Nova cifra (admin; aceita `extra: Chord` para pré-preencher) |
| `/cifra-club` | Busca/importação do Cifra Club |

As abas ficam num `StatefulShellRoute`; as demais telas abrem por cima (navigator raiz).
`extra` some ao recarregar a página na web; toda tela precisa funcionar só com a URL.

## Design system

Objetivo: o app não deve parecer Material UI padrão. Import único:
`import 'package:chord_master_app/presenter/design_system/design_system.dart';`

- **Cores**: `context.colors` (`AppColors`, paleta "palco": grafite quente + âmbar). Nada de hex solto em página.
- **Texto da interface**: `context.text` (Manrope). Espaço/raio: `AppSpace`, `AppRadius`.
- **Ícones**: `AppIcons` (Lucide por baixo). Não use `Icons.*` nem o pacote de ícones direto.
- **Componentes**: `AppPage`, `AppTopBar`, `AppBottomNav`, `AppButton`, `AppIconButton`, `AppCard`,
  `AppTextField`, `AppTag`, `AppChipButton`, `NumberBadge`, `AppStepper`, `AppSegmented`, `EmptyState`,
  `Pressable`; feedback com `showToast`, `showAppDialog`, `confirmAction`, `showAppSheet`, `showActionSheet`.
- Sem ripple (`NoSplash`), transição de página própria (fade + leve subida).
- Tema escuro é o padrão; teste toda tela nos dois temas e em largura de celular (~390px).
- Telas usam largura máxima (`AppSpace.maxContentWidth`); a `AppTopBar` recebe o mesmo `maxWidth` do conteúdo para alinhar.

### Fontes da cifra: NÃO MUDAR

O conteúdo das cifras mantém as fontes originais, independente do tema do app:
- cifras do app: **Roboto**;
- cifras do Cifra Club (link contém `cifraclub.com.br`): **Roboto Mono**.

Isso está em `ChordContentViewer` e no editor (o campo da cifra usa a mesma fonte da leitura).
Só as cores dos acordes seguem o design system.

## Pontos de atenção

- **Dois formatos de cifra** (`lib/domain/utils/chord_markup.dart`): texto puro (acordes em linhas próprias) e HTML do Cifra Club (acordes em `<b>`). O formato de exibição é decidido pelo link, o de transposição pelo conteúdo. Mudou algo aqui, teste os dois.
- **Cifra Club** (`lib/data/api/cifra_club_scraper.dart`): na web passa por proxy CORS público, que já mudou mais de uma vez. Se o import parar, olhe o proxy primeiro.
- **Admin** (`lib/app/services/admin_auth.dart`): a checagem é só no cliente. Ela esconde ações na UI, não protege a API.
- **Armazenamento local** (`AppPreferences`): as chaves antigas (`prefChordList`, `prefDownloadList`, `prefSettings`) foram mantidas para não perder dados de quem já usa o app.
- `android/` e `.metadata` com plataforma android estão fora do controle de versão por enquanto; o alvo é web.
