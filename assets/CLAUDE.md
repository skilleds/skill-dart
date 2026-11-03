# Piso de Dart/Flutter (schematize-dart) — sempre-on

> No que é de **app** (offline, IAM, push, loja, teste no device), quem manda é a
> **`schematize-mobile`**. Aqui é o que é de **linguagem e framework**.

1. **`!` (bang) é VETADO** em produção — desliga a verificação pela qual você pagou a migração.
2. **`late` não conserta nulo incômodo**; **`dynamic`** vira `NoSuchMethodError` em produção.
3. **Todo `Future` é aguardado** ou `unawaited(...)` explícito, com motivo.
4. **Stream tem `cancel()` no `dispose()`** (idem `Timer`, `AnimationController`) — senão vaza e
   dispara `setState` depois da tela morrer.
5. **`BuildContext` depois de `await` exige `if (!mounted) return;`** (`State`) ou **`if (!context.mounted) return;`**.
6. **CPU pesado fora da UI thread** (`compute`/`Isolate`) — o sintoma de ignorar é jank.
7. **`const` onde der**; **`Key`** em lista dinâmica; nada de lógica de negócio no `build`.
8. **Erro com stack trace** (`on X catch (e, s)`); `catch (e) {}` e `print` como tratamento são
   VETADOS.
9. **Segredo nunca no bundle** (nem via `--dart-define`); **`shared_preferences` não é cofre**.
10. **`pubspec.lock` commitado** (aplicação), SDK fixado, e os **lints do piso explícitos** no
    `analysis_options.yaml` — herdar `flutter_lints` não basta.
11. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

Gate: `bash .claude/skills/schematize-dart/scripts/check-dart.sh .`

<!-- herdado:engineering/pisos-22-29:bloco -->**Herda os pisos 22–29 da `schematize-engineering`** (texto completo em `assets/CLAUDE.md` dela): 22 tudo no git — sem remote, push falho ou HEAD≠origin a demanda NÃO se conclui; 23 deploy só do git (VETADO scp/rsync/tar|ssh/docker save|load/git bundle); 24 o ops é o gate da IA — a IA nunca muda a VPS direto nem escreve SQL, só operação nomeada (`ssh vps "ops <op>"`); 25 sem agents inúteis (entregou, morreu); 26 relatório a cada 30 min e handoff a cada 6 h; 27 CI remoto só antes do hml, a pedido ou em tag (`workflow_dispatch` + `hml-*`/`v*`; VETADO `pull_request`, `push` em branch, `workflow_run`, cron sem justificativa); 28 microserviço autônomo (fila durável + 7 testes de resiliência); 29 build/teste na máquina dev/hml quando existe (ponte só no workspace de build, nunca prd) + higiene (`scripts/higiene.sh`).<!-- /herdado -->
