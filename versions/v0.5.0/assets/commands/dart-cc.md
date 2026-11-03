---
description: schematize-dart — context compact: grava o handoff no archive e roda /compact.
---
Antes de compactar, grave o handoff em `<projeto>/<projeto>_archive/context/`, no par
context + checklist do padrão da `schematize-archive` (prefixo `AAAA-MM-DD-<slug>-`): o que foi
escrito/revisado, o que o `check-dart.sh` acusou e ficou aberto, e as decisões que precisam
sobreviver à sessão (o que ficou em `late` e por quê, os `unawaited(...)` explícitos, quais alvos
entram no CI, o teto de tamanho acordado). Só então rode `/compact`.
