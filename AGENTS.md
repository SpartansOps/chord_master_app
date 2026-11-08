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
- `ADMIN_PASSWORD_HASH`: SHA-256 (hex) da senha que libera criar/editar/apagar. Sem ele, ninguém vira admin.
- Build de produção: `flutter build web` com os mesmos `--dart-define`.
- Gerar código (`json_serializable`): `dart run build_runner build --delete-conflicting-outputs`.

Antes de entregar uma mudança: `flutter analyze` sem erros novos.

## Estrutura

```
lib/
  app/          bootstrap, DI (di.dart), serviços (preferências, admin_auth)
  data/         api (http, scraper do Cifra Club), models (*.g.dart gerados), mapper, provider, repository
  domain/       entidades (Chord, Settings) e utils puros (chord_transposer)
  presenter/
    base/       BaseViewModel (eventos via BehaviorSubject)
    pages/      home, chord (ver/criar), cifra_club, settings
    resources/  theme, routes, widgets compartilhados, validators
```

Fluxo de dados: `ChordProvider` (HTTP) → `ChordRepository` (mapeia `ChordData` → `Chord`) → ViewModel → página.
As cifras baixadas e a lista do repertório ficam no `SharedPreferences` (`AppPreferences`), que na web é localStorage.

Índice de features com arquivo de cada uma: [FEATURES.md](FEATURES.md). Atualize-o quando criar ou mover uma feature.

## Estado atual × direção

O app está em transição. Ao mexer em código, siga a direção e não espalhe o padrão antigo.

| Tema | Hoje | Direção |
|------|------|---------|
| Estado / DI | GetIt + ViewModels singleton + rxdart (`StreamBuilder`) | **Riverpod**: providers para http, prefs, repositório; `Notifier`/`AsyncNotifier` por tela |
| Navegação | `onGenerateRoute` com strings em `routes_manager.dart` | **go_router**, com URLs reais (é PWA) |
| UI | Material 3 com tema customizado | **Design system próprio** sobre `MaterialApp` (ver abaixo) |
| Testes | praticamente nenhum | testes unitários para `domain/` (começando pelo `chord_transposer`) |

Regras durante a migração:
- Tela migrada para Riverpod não deve voltar a ler `instance<...>()` do GetIt.
- Não crie novos ViewModels baseados em `BaseViewModel`/`BehaviorSubject`.
- Migre uma tela por vez, junto com a troca para os componentes novos, para não mexer duas vezes no mesmo arquivo.

## Design system (em construção)

Objetivo: o app não deve parecer Material UI padrão.

- Tokens (cores, espaço, raio, tipografia) num lugar só, expostos via `ThemeExtension`. Nada de cor hex solta em página.
- Páginas usam componentes do app (botão, card, campo, chip, sheet, snackbar), não `ElevatedButton`/`Card`/`AlertDialog` direto.
- Sem ripple/ink splash; transições de página próprias.
- Ícones de um pacote único (Phosphor ou Lucide), não `Icons.*`.
- Cifra em fonte **monoespaçada**, para os acordes ficarem alinhados com a letra.
- Tema escuro é cidadão de primeira classe; teste toda tela nos dois.
- Layout com largura máxima no desktop; nada esticando de ponta a ponta.

## Pontos de atenção

- **Transposição** (`lib/domain/utils/chord_transposer.dart`): trata HTML (Cifra Club, acordes em `<b>`) e texto puro. Mudou aqui, teste os dois formatos.
- **Cifra Club** (`lib/data/api/cifra_club_scraper.dart`): na web passa por proxy CORS público, que já mudou mais de uma vez. Se o import parar, olhe o proxy primeiro.
- **Admin** (`lib/app/services/admin_auth.dart`): a checagem é só no cliente. Ela esconde ações na UI, não protege a API.
- `android/` e `.metadata` com plataforma android estão fora do controle de versão por enquanto; o alvo é web.
