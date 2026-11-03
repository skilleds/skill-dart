# O piso de Dart/Flutter da casa

> Parte da skill **schematize-dart**. A base agnóstica é da **`schematize-engineering`**; o piso de
> **app** (offline-first, IAM mobile, push, lojas, testes no device) é da **`schematize-mobile`** —
> e, no que é de app, **ela manda**. Aqui fica o que é da linguagem e do framework.

Convenção: **MUST** = o gate cobra · **VETADO** = piso.

---

## 1. Null safety é do compilador — não a devolva

- **VETADO `!` (bang operator)** em caminho de produção. Ele desliga exatamente a verificação pela
  qual você pagou a migração do null safety.
- **VETADO `late` como conserto de nulo incômodo.** `late` é promessa de que alguém inicializa
  antes; quando não inicializa, o erro (`LateInitializationError`) chega em runtime e não diz mais
  que um null.
- **MUST:** `?.`, `??`, *pattern matching* com `switch` exaustivo, ou o valor obrigatório no
  construtor (`required`).
- **`dynamic` é o buraco no sistema de tipos:** ele desliga a checagem em compilação e transforma
  erro de tipo em `NoSuchMethodError` em produção. Use `Object?` + `is`, ou tipe de verdade.

## 2. Assíncrono — `Future` que ninguém espera é bug

- **MUST:** `await` em tudo o que retorna `Future`, ou `unawaited(...)` **explícito** com o motivo.
  O lint `unawaited_futures` é o que pega o esquecimento — e o esquecimento produz ordem de execução
  que ninguém escreveu.
- **Erro em `Future` não esperado vira `unhandled exception` global** (e, em Flutter, some no
  `FlutterError.onError`). Ou trata, ou propaga, ou registra.
- **`Stream`:** toda subscription tem `cancel()` no `dispose()`; **stream sem cancelamento é
  vazamento** e, em app, ainda dispara `setState` depois da tela morrer.
- **CPU pesado sai da UI thread:** `compute`/`Isolate`. Dart é single-threaded por isolate — um
  parse grande no `main` **trava o frame**, e o sintoma é jank, não erro.
- **`Timer`/`AnimationController`** têm `dispose()`. Sempre.

## 3. Flutter — o que é da linguagem e some no review

- **`BuildContext` depois de `await` é a armadilha nº 1:** o widget pode ter sido desmontado.
  **`if (!mounted) return;`** (em `State`) ou **`if (!context.mounted) return;`** (em qualquer lugar, inclusive função e `StatelessWidget`) antes de usar o contexto — e o lint `use_build_context_synchronously`
  ligado.
- **`setState` depois do `dispose`** joga exceção: cancele stream/timer antes.
- **`const` onde der:** widget `const` não é reconstruído — é a otimização mais barata que existe, e
  o lint (`prefer_const_constructors`) a cobra.
- **Chave (`Key`) em lista dinâmica**: sem ela, o Flutter reaproveita estado do item errado quando a
  lista muda — o bug "o checkbox marcou a linha de cima".
- **Nada de lógica de negócio no `build`**: ele roda a cada frame. Estado vive no gerenciador
  escolhido (a escolha é ADR, não gosto).
- **`GlobalKey` é caro e vaza** quando guardado em campo estático.

## 4. Erro é valor na fronteira

- Erro esperado (validação, rede, regra) é **retorno tipado** (`sealed class` + `switch`, ou
  Result/Either da lib escolhida); exceção fica para o excepcional.
- **VETADO `catch (e) { }`** e `catch (e) { print(e); }` como tratamento. **`on Erro catch (e, s)`**
  com o **stack trace** — sem ele, o log diz o quê e esconde o onde.
- **`print` não é log de produção** (some no release, não tem nível, não tem contexto): use o
  logger do projeto.

## 5. Segurança do cliente

- **Nunca segredo no app:** `--dart-define`, string constante, `.env` embutido — tudo sai do bundle.
  Piso da `schematize-mobile`.
- **`shared_preferences` não é cofre** (é plist/XML em claro): credencial vai em
  `flutter_secure_storage`/Keychain/Keystore.
- **`WebView` com JS habilitado** só com conteúdo próprio; canal JS↔Dart é ponte de execução.
- **Log sem PII/token**; e cuidado com `debugPrint` de objeto inteiro.

## 6. Teste

Disciplina da **`schematize-qa`**. Aqui: `flutter test` para unidade/widget, `integration_test`
para o fluxo; **`pumpAndSettle` não é sinônimo de "esperou"** — com animação infinita ele estoura, e
com `Future` pendente ele passa cedo demais. Golden test é regressão visual (a política é da `qa`),
e ele **quebra por diferença de plataforma** — fixe a fonte e o device de referência, senão vira
flaky no CI.
