# Changelog — schematize-dart

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]
### Corrigido
- P0-1: template de CI sem `pull_request`/push em branch: `workflow_dispatch` + tags `hml-*`/`v*`, `concurrency` com cancel, `paths-ignore` de docs. Removido "trava o merge".
- P1-12: CI não usa mais `flutter-version-file: pubspec.yaml` (lia só a faixa, não pinava); versão vem de `.fvmrc`. Comentário falso corrigido.
- P1-10: gate varre todos os `pubspec.yaml` (monorepo); só APLICAÇÃO (Flutter, não plugin, `publish_to: none` ou `lib/main.dart`) exige `pubspec.lock` (aceita o lock num ancestral/workspace).
- P1-11/P2-9: `.listen(` exige `<var>.cancel()` da própria subscription (Timer.cancel não vale; stdin/CLI/return isentos); `context` depois de `await` checado por função; `context.mounted` padronizado.
- P1-14: gate exige os 8 lints do piso (erro, não aviso).
- P1-1/P1-2: bloco "Herda os pisos 22–29" em SKILL.md e assets/CLAUDE.md. README em v0.4.0, contagem de testes (20).
### Em espera
- [~] P1-13: Flutter 3.47/Dart 3.13, Impeller no desktop e depreciação Material/Cupertino em `stack-versoes.md` seguem como estavam (marcadas `reverificar`): docs.flutter.dev/release/archive (2026-11-03) não carregou a tabela stable nem cita Dart nem Impeller/Material; sem fonte oficial confirmada, sem alteração.

## [0.4.0] — 2026-10-14
Description reduzida para o orçamento de listagem do catálogo; sem mudança de piso.

### Alterado
- Description encurtada para ≤190 caracteres (catálogo estourou o orçamento de 9000 com 45 skills), mantendo O QUE + gatilho concreto + divisa com as irmãs.
- Ponteiro: o broker que emite os tokens do IAM mobile é da `schematize-iam` (`references/protocolos.md`).

## [0.3.1] — 2026-10-14
Ressincronização dos blocos herdados com a engineering v0.27.0; sem mudança de piso próprio.

### Alterado
- Description reduzida (≤235 chars) para caber no orçamento de listagem de skills (soma ≤8300); mesmo território, fronteiras com as irmãs preservadas.
- Blocos herdados ressincronizados com a `schematize-engineering` v0.27.0 (`tools/sync-herdados.mjs`): orquestração com a regra de imagem (nunca pelo Claude; detecta Codex/Gemini e pergunta ao usuário qual usar, Codex como sugestão) e `schematize overdev delegar` (comando do app) no lugar do falso nome de skill `schematize-overdev`.

## [0.3.0] — 2026-10-14
Saneamento: description válida e ancorada nos artefatos, herança explícita da base e CI de referência — porque a skill não dizia o que herdava (nem qual era o papel dela no §2.2 de `linguagens.md`) e o instalador prometia hooks que não existem.

### Corrigido
- `description` em bloco `>-`, ≤350 caracteres, YAML válido, ancorada nos artefatos da linguagem.
- Seção "Precedência e herança": §28 archive, §35 DoD, §39 índice, IAM, efeito externo, orquestração herdados da base; papel ancorado em `schematize-engineering → references/linguagens.md` §2.2; QA/ops/IAM/índice vêm de `/eng-*` (`/eng-overdev`, `/eng-plan`, `/eng-scan`, `/eng-review`). IAM/ops/entrega delegados à `schematize-mobile`.
- `install.sh`: removido o trecho que copiava `assets/hooks` e mandava registrar `assets/settings.claude.example.json` — nenhum dos dois existe (mensagem enganosa).
- `dart-help`: `/dart-load` listava "(piso, plataforma)"; corrigido para os arquivos reais. `schematize-mobile → references/...` com aviso de dependência; ressalva de toolchain passa a "uma das três (Swift, Kotlin, Dart)".

### Adicionado
- `assets/ci/github-actions-ci.yml` (actions pinadas por SHA) e arquivo de config do linter em `assets/lint/`; referenciados no SKILL.md.

### Atualizado
- Anexo volátil: `context.mounted`, Impeller padrão, status web/wasm.
- **Description** reduzida (~270 chars) para caber no orçamento de listagem (soma das 31 skills ≤ 8500; o Claude Code corta a listagem acima disso).

### Alterado
- Bloco "Precedência e herança" passa a ser herdado da base (`schematize-engineering` → `assets/herdados/precedencia.md`), gerado por `tools/sync-herdados.mjs`; corpo sem mudança de conteúdo.

## [0.2.2] — 2026-09-30
O piso de orquestração passa a ser **herdado** da base em vez de copiado à mão: uma mudança na engineering não exige mais editar 38 arquivos.

### Alterado
- Piso "Orquestrador não desenvolve; subagent barato executa" em `assets/CLAUDE.md` e `SKILL.md` agora é um bloco `<!-- herdado:engineering/orquestracao:… -->`, sincronizado de `schematize-engineering/assets/herdados/orquestracao.md` por `tools/sync-herdados.mjs` (checado no CI). Redação normalizada; conteúdo inalterado.

### Mantido (piso inalterado)
- Sonnet por default, escada até opus, sem frota ociosa (engineering `references/orquestracao.md` §9/§9.6).

## [0.2.1] — 2026-09-30
Pedido do dono: agents idle poluem a tela e seguram recurso.

### Adicionado
- Piso de orquestração ganha a regra de frota ociosa (idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata); detalhe na `schematize-engineering` §9.6.

## [0.2.0] — 2026-09-30

Pedido do dono, por **custo**: o orquestrador não desenvolve; ação onerosa vira micro-tasks baratas; `sonnet` é o default dos subagents e `opus` só entra após falha.

### Adicionado
- **Piso "Orquestrador não desenvolve; subagent barato executa"** no `assets/CLAUDE.md` e no `SKILL.md`: o agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para subagents em `sonnet` (falhou → o mesmo subagent corrige → re-decompõe → só então `opus`, com motivo). Detalhe na base: `schematize-engineering` → `references/orquestracao.md` §9.

### Mantido (piso inalterado)
- Todos os pisos anteriores e o gate de `scripts/` seguem exatamente como estavam; a mudança é só de orquestração, não de código.

## [0.1.1] — 2026-08-21

### Corrigido
- Os comandos `/dart-load`, `/dart-review` e `/dart-cc` carregavam **texto do template de Swift** (force-unwrap, `@MainActor`, `Sendable`, "simulador fixado") — resíduo de terem nascido de uma cópia adaptada por substituição. Reescritos para o que é de Dart/Flutter: `Future` sem `await`, stream sem `cancel()`, `mounted` depois de `await`, `Key` em lista dinâmica, `pubspec.lock`, e os lints do piso **explícitos** no `analysis_options.yaml`. *É a mesma Classe C que este catálogo passou o dia removendo — e ela reapareceu na skill nova, no primeiro dia.*

## [0.1.0] — 2026-08-21

Primeira versão. A `schematize-mobile` promete escolha *"nativo vs cross por fit + ADR"* e **não havia skill por trás de nenhuma das opções** (vistoria de 2026-08-21). Esta é a peça **cross**, publicada no mesmo marco que `schematize-swift`, `schematize-kotlin` e o conserto da `schematize-mobile` (v0.3.0).

### Adicionado
- **`references/piso.md`** — null safety que **não se devolve** (`!` desliga exatamente a verificação pela qual você pagou a migração; `late` é promessa cujo erro **não diz mais que um null**; `dynamic` transforma erro de tipo em `NoSuchMethodError` em produção); **assíncrono** (`Future` sem `await` é **ordem de execução que ninguém escreveu**, e o erro dele vira `unhandled exception` global; stream sem `cancel()` vaza **e** dispara `setState` depois da tela morrer; CPU pesado fora da UI thread, porque o sintoma é **jank, não erro**); **Flutter** (`BuildContext` depois de `await` sem `mounted` — a armadilha nº 1; `const`; **`Key` em lista dinâmica**, que é o bug "o checkbox marcou a linha de cima"); erro **com stack trace**; segurança do cliente; teste (com `pumpAndSettle` que **não** é sinônimo de "esperou").
- **`references/plataforma.md`** — `pubspec.lock` commitado **em aplicação** (em package publicado, não), SDK e Flutter fixados, **dependência como superfície** (*plugin com código nativo dobra a superfície*: traz Kotlin/Swift/C que passa a ser seu no build, no crash e na revisão da loja), alvos com ADR (`dart:io` não existe no web e `dart:html` não existe no mobile — **compile todos os alvos no CI**), release com ofuscação e **mapa de símbolos guardado**.
- **`scripts/check-dart.sh`** + **`check-dart.test.sh`** (**9 casos**, 7 vermelhos): `!`, `late`, `dynamic`, `catch` vazio, `print`, `context` com `await` e sem `mounted`, `.listen(` sem `cancel()`, credencial em `shared_preferences`, WebView com JS irrestrito — e, no projeto: **`pubspec.lock` ausente em aplicação**, `environment:` ausente, **`analysis_options.yaml` ausente** e os lints do piso não declarados.

### Honestidade sobre o alcance
- A toolchain Flutter **não roda na máquina de referência** do catálogo. O gate é **textual** e **diz isso na saída**; onde houver `flutter analyze`, **é ele que manda**. Os números moram no anexo volátil, com a mesma ressalva.
