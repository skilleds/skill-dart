# Anexo volátil — versões e ferramental (Dart / Flutter)

> Parte da skill **schematize-dart**. **Fonte volátil:** prazo de validade, atualizado à parte do
> corpo normativo (regra `anexo-volatil` do lint).
>
> **Verificado em: 2026-10-14.** Cadência: trimestral e antes de cada release da skill.
> **Ressalva honesta:** esta é uma das três (Swift, Kotlin, Dart) cuja toolchain Flutter **não roda na
> máquina de referência** do catálogo. Os
> números vêm da documentação oficial, não de execução local — por isso moram aqui, no anexo datado.

## Linguagem e SDK

- **Piso normativo:** canal **stable**, versão **fixada** no repo (FVM ou equivalente) e declarada
  no CI. Canal `master`/`beta` em produto é VETADO.
- **SDK constraint** no `pubspec.yaml` (`environment: sdk:`), coerente com o que o CI usa.
- **Linha corrente (verificada em 2026-10-14, reverificar):** Flutter 3.47 / Dart 3.13. <!-- reverificar -->
- **Impeller** é o renderer padrão em iOS, Android (API 29+) e, desde a 3.47, desktop; **web ainda
  usa Skia/CanvasKit** e o **wasm** (`--wasm`) é o caminho oficial mas não é o default ainda.
  Material/Cupertino estão em separação do core (depreciação formal anunciada para nov/2026) —
  acompanhe antes de upgrade maior.
- **Null safety** é pressuposto — pacote sem null safety é dívida de migração, não opção.

## Ferramental

| Ferramenta | Papel | Nota |
|---|---|---|
| **`flutter analyze`** | análise estática | **o gate**; com `analysis_options.yaml` do projeto |
| **`dart format`** | formatação | `--set-exit-if-changed` no CI |
| `flutter_lints` / `very_good_analysis` | conjunto de regras | herdar **não basta**: as regras do piso ficam explícitas |
| `flutter test` / `integration_test` | teste | disciplina na `schematize-qa` |
| `flutter_secure_storage` | credencial | `shared_preferences` **não** é cofre |
| `--analyze-size` | tamanho do artefato | teto acordado no CI |

## Lints que o piso exige ligados

`unawaited_futures` · `use_build_context_synchronously` (satisfeito por **`context.mounted`**, que
funciona em qualquer contexto, além de `mounted` do `State`) · `avoid_dynamic_calls` ·
`cancel_subscriptions` · `close_sinks` · `prefer_const_constructors` · `avoid_print` ·
`only_throw_errors`. Estas são as que transformam o piso desta skill em erro de build — o resto é
estilo.

## Regra que NÃO é volátil

`!` em produção, `late` como conserto, `Future` sem `await`, segredo no bundle e `catch (e) {}` são
VETADOS **em qualquer versão**.
