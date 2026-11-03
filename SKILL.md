---
name: schematize-dart
metadata:
  version: 0.4.0
description: >-
  Piso de Dart/Flutter para clientes mobile. Use ao tocar pubspec.yaml ou *.dart: null safety sem '!', await em Futures, context.mounted, segredo fora do bundle. IAM/lojas: mobile.
---
<!-- cross-skill: linguagens.md -> schematize-engineering -->

# O piso de Dart/Flutter da casa (schematize-dart)

Recorte de **linguagem e framework**. A base agnóstica é a **`schematize-engineering`**; o piso de
**app** é da **`schematize-mobile`** — e, no que é de app, **ela manda**.

**Versão:** skill `schematize-dart` v0.4.0. Changelog em `CHANGELOG.md`.

## Precedência e herança (leia antes de divergir)

<!-- herdado:engineering/precedencia:mobile intro="Esta skill é o recorte **Dart** das linguagens **sancionadas fora do rol de backend** (`schematize-engineering` → `references/linguagens.md` §2.2): cliente **Flutter**, **sob a `schematize-mobile`**." cmd="dart" -->Esta skill é o recorte **Dart** das linguagens **sancionadas fora do rol de backend** (`schematize-engineering` → `references/linguagens.md` §2.2): cliente **Flutter**, **sob a `schematize-mobile`**.

1. **Onde esta skill divergir da base, a BASE MANDA.** Aqui mora a especialização — a lib, o gate, a
   sintaxe da linguagem. Divergência de *piso* é defeito desta skill, não variante local.
2. **O que não está repetido aqui é HERDADO, não dispensado.** Valem integralmente, sem cópia local:
   - **§28 Archive** — `<projeto>/<projeto>_archive/` é **repositório git próprio, PRIVADO e
     obrigatório**, criticidade 0 (`schematize-archive`).
   - **§35 Definition of Done** e a lista de anti-padrões (citada por **título**, nunca por número).
   - **§39 Índice/MAPA** — enumeração exaustiva (uma entrada por unidade chamável, `M == N`) e grafo
     com arestas em ASCII (`A -> B`), nunca a seta unicode.
   - **IAM** (`schematize-engineering` → `references/iam.md`): identidade ≠ email, ≥2 fatores, ReBAC
     multi-tenant, argon2id-only para senha nova, sessão longa e logout irreversível.
   - **Efeito externo** nunca sai de não-produção (`schematize-engineering` →
     `references/efeitos-externos.md`).
   - **Orquestração** (`schematize-engineering` → `references/orquestracao.md` §9): o principal não
     desenvolve (é Claude Opus); executor mais barato que resolve — `haiku`/`sonnet` → Codex Terra → Cursor → `opus` só após falha; visual direto ao Codex; imagem nunca pelo Claude: detecta Codex/Gemini e pergunta ao usuário qual usar (Codex é a sugestão, não automática), nunca API paga.
3. **Delegado à `schematize-mobile`, por nome:** IAM mobile (public client OIDC/PKCE, passkeys,
   Keychain/Keystore), ops, offline/sync, push, testes no device e entrega nas lojas
   (`schematize-mobile` → `references/testes-mobile.md`, `schematize-mobile` →
   `references/entrega-lojas.md`; comandos `/mobile-auth`, `/mobile-offline`, `/mobile-test`,
   `/mobile-release`). **Dependência:** instale a `schematize-mobile` junto; sem ela esses
   arquivos não existem no seu ambiente e o piso de app fica sem dono.
4. **QA, ops, IAM e índice não têm comando próprio aqui:** vêm da base `/eng-*`. Para trabalho
   contínuo use `/eng-overdev`; para planejar `/eng-plan`; para varrer a base `/eng-scan`; para
   revisão geral `/eng-review` (e `/eng-ops`, `/eng-iam`, `/eng-index`). Os comandos
   `/dart-*` cobrem só o piso da linguagem.<!-- /herdado -->

## Por que ela nasceu

A `schematize-mobile` promete escolha *"nativo vs cross por fit + ADR"* e **não havia skill por trás
de nenhuma das opções** (vistoria de 2026-08-21). Esta é a peça **cross** — publicada junto com
`schematize-swift`, `schematize-kotlin` e o conserto da própria `schematize-mobile`, para que a
escolha por fit passe a ter as duas respostas sustentadas.

## Comandos (Claude Code)

| Comando | O que faz |
|---|---|
| `/dart-help` | lista os comandos |
| `/dart-load` | carrega à força o corpo normativo (piso, plataforma) |
| `/dart-review` | revisa `.dart` e o projeto contra o piso: roda o gate e lê o que a máquina não lê |
| `/dart-claude` | cria/mescla o `CLAUDE.md` sempre-on na raiz do repo |
| `/dart-cc` · `/dart-handoff` | context compact / handoff arquivado |

## Como usar

1. **O que é de app é da `schematize-mobile`**.
2. **Rode o gate:** `bash scripts/check-dart.sh .` — `0` passa · `1` reprova · `2` **nada para
   verificar** (não é aprovação). Ele é **textual**: onde houver `flutter analyze`, **é ele que
   manda**.
3. **Piso de linguagem** em `references/piso.md`; **build, dependência e alvos** em
   `references/plataforma.md`.

Mapa de references:

| Tarefa | Reference |
|---|---|
| Null safety, assíncrono (`await`, stream, isolate), Flutter (`mounted`, `const`, `Key`, `dispose`), erro com stack trace, segurança do cliente, teste | `references/piso.md` |
| `pubspec.lock`, SDK fixado, `flutter analyze` como gate, dependência como superfície (plugin nativo dobra a superfície), alvos com ADR, release (ofuscação, tamanho) | `references/plataforma.md` |
| Versões, ferramental e **os lints que o piso exige ligados**, com data **e a ressalva de que a toolchain não roda na máquina de referência** | `references/stack-versoes.md` |

Assets prontos para copiar: `assets/ci/github-actions-ci.yml` (dart format, flutter analyze, flutter test) · `assets/lint/analysis_options.yaml`.

## Pisos inegociáveis (vetam o atalho)

1. **`!` (bang) é VETADO** em produção — ele desliga exatamente a verificação pela qual você pagou a
   migração do null safety.
2. **`late` não é conserto de nulo incômodo**, e `dynamic` é o buraco no sistema de tipos (vira
   `NoSuchMethodError` em produção).
3. **Todo `Future` é aguardado** ou `unawaited(...)` **explícito** — esquecer produz ordem de
   execução que ninguém escreveu, e o erro vira `unhandled exception` global.
4. **Stream tem `cancel()` no `dispose()`**; `Timer`/`AnimationController` também. Sem isso é
   vazamento **e** `setState` depois da tela morrer.
5. **`BuildContext` depois de `await` exige `if (!mounted) return;` (`State`) ou `if (!context.mounted) return;` (qualquer lugar)** — a armadilha nº 1 do Flutter.
6. **CPU pesado fora da UI thread** (`compute`/`Isolate`): o sintoma de ignorar é jank, não erro.
7. **Erro com stack trace** (`on X catch (e, s)`); `catch (e) {}` e `print` como tratamento são
   VETADOS.
8. **Segredo nunca no bundle** (`--dart-define` inclusive); **`shared_preferences` não é cofre** —
   credencial em `flutter_secure_storage`/Keychain/Keystore.
9. **`pubspec.lock` commitado em aplicação**; SDK e versão do Flutter **fixados** no CI.
10. **Os lints do piso ficam explícitos** no `analysis_options.yaml` — herdar `flutter_lints` **não
    basta**, e é o `flutter analyze` que trava a conclusão local (o gate por commit é local).
11. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

<!-- herdado:engineering/pisos-22-29:bloco -->**Herda os pisos 22–29 da `schematize-engineering`** (texto completo em `assets/CLAUDE.md` dela): 22 tudo no git — sem remote, push falho ou HEAD≠origin a demanda NÃO se conclui; 23 deploy só do git (VETADO scp/rsync/tar|ssh/docker save|load/git bundle); 24 o ops é o gate da IA — a IA nunca muda a VPS direto nem escreve SQL, só operação nomeada (`ssh vps "ops <op>"`); 25 sem agents inúteis (entregou, morreu); 26 relatório a cada 30 min e handoff a cada 6 h; 27 CI remoto só antes do hml, a pedido ou em tag (`workflow_dispatch` + `hml-*`/`v*`; VETADO `pull_request`, `push` em branch, `workflow_run`, cron sem justificativa); 28 microserviço autônomo (fila durável + 7 testes de resiliência); 29 build/teste na máquina dev/hml quando existe (ponte só no workspace de build, nunca prd) + higiene (`scripts/higiene.sh`).<!-- /herdado -->

## Relação com as outras skills

- **`schematize-mobile`** — o piso de app; **ela manda** no que é de produto/plataforma, inclusive
  na decisão *nativo vs cross*.
- **`schematize-engineering`** — a base e o rol. **Backend em Dart não é do rol**; web
  institucional/marketing é da **`schematize-web`**, não Flutter Web.
- **`schematize-qa`** — a disciplina de teste; aqui muda o runner e as armadilhas
  (`pumpAndSettle`, golden test que quebra por plataforma).
- **`schematize-swift`/`schematize-kotlin`** — as respostas **nativas** da mesma pergunta; o plugin
  com código nativo cai no piso delas.
