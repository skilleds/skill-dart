---
description: schematize-dart — carrega à força TODO o corpo normativo do piso de Dart/Flutter e passa a aplicá-lo nesta sessão.
---
Carregue **agora** o corpo normativo da skill `schematize-dart`
(`.claude/skills/schematize-dart/references/*.md`):

- `piso.md` — null safety que **não se devolve** (`!` desliga a verificação pela qual você pagou a
  migração; `late` não é conserto de nulo incômodo; `dynamic` vira `NoSuchMethodError` em produção);
  **assíncrono** (`Future` sem `await` é ordem de execução que ninguém escreveu; stream sem
  `cancel()` vaza **e** dispara `setState` depois da tela morrer; CPU pesado fora da UI thread);
  **Flutter** (`BuildContext` depois de `await` sem `mounted`; `const`; **`Key`** em lista dinâmica);
  erro **com stack trace**; segurança do cliente; teste.
- `plataforma.md` — `pubspec.lock` commitado **em aplicação**, SDK e Flutter **fixados**,
  `flutter analyze` como gate, dependência como superfície (**plugin nativo dobra a superfície**),
  alvos com ADR (`dart:io` não existe no web), release (ofuscação com **mapa de símbolos guardado**,
  tamanho).
- `stack-versoes.md` — anexo volátil, com **os lints que o piso exige ligados** e a ressalva de
  alcance: a toolchain Flutter **não roda na máquina de referência** do catálogo.

Depois, rode o gate: `bash .claude/skills/schematize-dart/scripts/check-dart.sh .`
E lembre: no que é de **app**, quem manda é a **`schematize-mobile`**.
