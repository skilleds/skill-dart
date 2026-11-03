---
description: schematize-dart — revisa Dart/Flutter contra o piso: roda o gate e depois lê o que a máquina não lê (assíncrono, ciclo de vida, projeto, fronteira com a mobile)
argument-hint: "[arquivo.dart ou diretório]"
---

# /dart-review

## 1. A máquina

```bash
bash .claude/skills/schematize-dart/scripts/check-dart.sh .
# onde houver toolchain, É ELE que manda:
flutter analyze                      # com o analysis_options.yaml do projeto
dart format --set-exit-if-changed .
flutter test
```

`0` passa · `1` reprova · `2` **nada para verificar** (não é aprovação). O gate é **textual** e diz
isso na saída.

## 2. O que a máquina não lê

- **Assíncrono:** algum `Future` sem `await` (nem `unawaited(...)` explícito)? toda subscription tem
  `cancel()` no `dispose()`? `Timer`/`AnimationController` também? CPU pesado saiu da UI thread
  (`compute`/`Isolate`)?
- **Ciclo de vida:** todo uso de `context` **depois de `await`** tem `if (!mounted) return;`? algum
  `setState` que pode rodar depois do `dispose`?
- **Widget:** há `Key` nas listas dinâmicas (senão o estado do item errado é reaproveitado)? o que
  pode ser `const` é `const`? há lógica de negócio dentro do `build` (que roda a cada frame)?
- **Null safety:** cada `!` restante tem invariante **real**? algum `late` que é só conserto? algum
  `dynamic` que dá para tipar?
- **Erro:** o `catch` captura **o tipo** e guarda o **stack trace** (`on X catch (e, s)`)? nada de
  `print` como tratamento?
- **Projeto:** `pubspec.lock` commitado (é aplicação)? os lints do piso estão **explícitos** no
  `analysis_options.yaml` (herdar `flutter_lints` **não basta**)? todos os alvos suportados compilam
  no CI?
- **Segredo:** nada no bundle (nem via `--dart-define`); credencial em `flutter_secure_storage`.
- **Fronteira:** o que é de app segue a **`schematize-mobile`**?

## 3. Feche

Achado vira correção no mesmo commit ou item de checklist com dono. Mexeu no gate? rode o vermelho:
`bash scripts/check-dart.test.sh` (20 casos).
