# Toolchain, dependência e alvos — Dart/Flutter

> Parte da skill **schematize-dart**. O que é de **app** (lojas, rollout, push, IAM) é da
> **`schematize-mobile`**; aqui fica build, dependência e as decisões de alvo.

---

## 1. Build reprodutível

- **MUST: `pubspec.lock` commitado** para **aplicação** (para *package* publicado, não se commita —
  o consumidor resolve). Sem lock, duas máquinas resolvem versões diferentes da mesma faixa.
- **SDK constraint declarada** (`environment: sdk:`) e **versão do Flutter fixada** no CI (FVM ou
  equivalente). "Compila na minha máquina" quase sempre é canal/versão diferente.
- **`flutter analyze` com `analysis_options.yaml` do projeto** travando o CI — e as regras que o
  piso exige **ligadas** (não basta herdar `flutter_lints` e achar que está coberto).
- **`dart format --set-exit-if-changed`** no CI.

## 2. Dependência é superfície

- **Toda dependência tem dono, licença e versão verificados** (`schematize-engineering`, cadeia de
  suprimentos). O pub.dev tem muito pacote de uma pessoa só — *popularity* não é manutenção.
- **Plugin com código nativo dobra a superfície**: ele traz Kotlin/Swift/C que passa a ser seu no
  build, no crash e na revisão da loja. Prefira o que tem alternativa oficial.
- **`dependency_overrides` é dívida com data**: registre por que existe e quando sai.

## 3. Alvos — decida, não herde

- **Mobile é o alvo padrão desta casa.** Web e desktop em Flutter são **decisão com ADR**: o custo
  aparece em tamanho de bundle, SEO (no web) e integração com o SO (no desktop) — e, para web
  institucional/marketing, o rol é outro (`schematize-web`).
- **`kIsWeb`/`Platform.isX` espalhados pelo código** são cheiro: isole a diferença atrás de uma
  interface, senão cada alvo novo multiplica os `if`.
- **`dart:io` não existe no web** e **`dart:html` não existe no mobile** — o erro aparece só no
  alvo que ninguém compilou no CI. Compile **todos os alvos suportados** no CI.

## 4. Release

- **Assinatura em cofre** (`schematize-mobile`); **build no CI**, com o artefato que foi testado
  sendo o que sobe.
- **Ofuscação** (`--obfuscate --split-debug-info`) no release, com o mapa de símbolos **guardado** —
  sem ele, o crash report vira ruído.
- **Tamanho é requisito**: `--analyze-size` no CI, com teto acordado. App grande é desinstalado.
