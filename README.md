# schematize-dart

> **O piso de Dart/Flutter da casa.** `!` desliga o null safety pelo qual você pagou; `Future` sem
> `await` é ordem de execução que ninguém escreveu; stream sem `cancel()` vaza e ainda chama
> `setState` depois da tela morrer; `BuildContext` depois de `await` precisa de `mounted`.
> E a fronteira é explícita: **no que é de app, a `schematize-mobile` manda**.

Pacote de **skill normativa para [Claude Code](https://claude.com/claude-code)**.
Parte do catálogo **schematize skills**.

## Instalar

```bash
schematize install dart
# ou
git clone https://github.com/schematizeme/skill-dart.git /tmp/skill-dart
bash /tmp/skill-dart/install.sh .
```

## O que tem dentro

- **SKILL.md** — o contrato: 11 pisos inegociáveis + mapa de references.
- **references/** — `piso` (null safety, assíncrono, Flutter, erro, segurança, teste),
  `plataforma` (lock, SDK, dependência, alvos, release), `stack-versoes` (anexo volátil datado, com
  **os lints que o piso exige ligados**).
- **scripts/** — `check-dart.sh` (gate textual, que também olha `pubspec.yaml` e
  `analysis_options.yaml`) e `check-dart.test.sh` (20 casos).
- **assets/commands/** — `/dart-help`, `/dart-load`, `/dart-review`, `/dart-claude`, `/dart-cc`,
  `/dart-handoff`.
- **assets/CLAUDE.md** — regra sempre-on.

## Comandos

| Comando | O que faz |
|---|---|
| `/dart-help` | lista os comandos |
| `/dart-load` | carrega o corpo normativo |
| `/dart-review` | roda o gate e revisa o que a máquina não lê |
| `/dart-claude` | cria/mescla o `CLAUDE.md` sempre-on |
| `/dart-cc` · `/dart-handoff` | context compact / handoff no archive |

## Versão

**v0.4.0** — changelog em `CHANGELOG.md`.

## Regra de ouro

**Herdar `flutter_lints` não basta.** O piso desta skill só existe de verdade quando as regras dele
estão **explícitas** no `analysis_options.yaml` — e o `flutter analyze` trava a conclusão local.

MIT.
