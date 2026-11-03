#!/usr/bin/env bash
# Vermelho primeiro do gate de Dart.
#
# strict-ok: harness de teste — continua depois de um caso vermelho (`schematize-shell` -> `references/piso.md` secao 1)
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
G="$AQUI/check-dart.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT INT TERM
ok=0; fail=0
caso() {
  local nome="$1" esp="$2" agulha="$3" arq="${4:-alvo.dart}"
  local d="$TMP/$nome"; mkdir -p "$d"; cat > "$d/$arq"
  local saida; saida="$(bash "$G" "$d" 2>&1)"; local rc=$?
  if [ "$rc" != "$esp" ]; then echo "  ✖ $nome: exit $rc, esperado $esp"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  if [ -n "$agulha" ] && ! grep -qF -- "$agulha" <<<"$saida"; then echo "  ✖ $nome: exit certo, saída sem \"$agulha\""; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  echo "  ✔ $nome"; ok=$((ok+1))
}

echo "== verde de partida =="
caso verde 0 "regras textuais do piso" <<'FIX'
import 'dart:async';

sealed class Estado {}

class Carregando extends Estado {}

class Pronto extends Estado {
  Pronto(this.itens);
  final List<String> itens;
}

class Repositorio {
  StreamSubscription<String>? _sub;

  void ouvir(Stream<String> fonte, void Function(String) aoReceber) {
    _sub = fonte.listen(aoReceber);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
FIX

echo "== null safety =="
caso bang 1 "null safety pela qual você pagou" <<'FIX'
String nome(Map<String, String> m) {
  return m['nome']!;
}
FIX

echo "== assíncrono e vazamento =="
caso listen-sem-cancel 1 "sem guardar a subscription" <<'FIX'
import 'dart:async';

void ouvir(Stream<String> fonte) {
  fonte.listen((v) => sink.add(v));
}
FIX

echo "== erro engolido =="
caso catch-vazio 1 "erro engolido" <<'FIX'
Future<void> salvar() async {
  try {
    await gravar();
  } catch (e) {}
}
FIX

echo "== segurança do cliente =="
caso prefs-com-token 1 "plist/XML EM CLARO" <<'FIX'
import 'package:shared_preferences/shared_preferences.dart';

Future<void> guardar(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}
FIX

echo "== projeto: lock e lints =="
d="$TMP/sem-lock"; mkdir -p "$d"
printf 'void main() {}\n' > "$d/main.dart"
printf 'name: app\npublish_to: none\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\ndependencies:\n  flutter:\n    sdk: flutter\n' > "$d/pubspec.yaml"
printf 'linter:\n  rules:\n    - unawaited_futures\n' > "$d/analysis_options.yaml"
saida="$(bash "$G" "$d" 2>&1)"; rc=$?
if [ "$rc" = 1 ] && grep -qF "pubspec.lock ausente" <<<"$saida"; then echo "  ✔ aplicação sem pubspec.lock reprova"; ok=$((ok+1))
else echo "  ✖ sem lock: exit $rc"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); fi

d="$TMP/sem-analysis"; mkdir -p "$d"
printf 'void main() {}\n' > "$d/main.dart"
printf 'name: app\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\n' > "$d/pubspec.yaml"; : > "$d/pubspec.lock"
saida="$(bash "$G" "$d" 2>&1)"; rc=$?
if [ "$rc" = 1 ] && grep -qF "analysis_options.yaml" <<<"$saida"; then echo "  ✔ projeto sem analysis_options reprova"; ok=$((ok+1))
else echo "  ✖ sem analysis_options: exit $rc"; fail=$((fail+1)); fi

LINTS8='linter:
  rules:
    - unawaited_futures
    - use_build_context_synchronously
    - avoid_dynamic_calls
    - cancel_subscriptions
    - close_sinks
    - prefer_const_constructors
    - avoid_print
    - only_throw_errors'
# rodar d esp agulha nome
rodar() {
  local nome="$1" esp="$2" agulha="$3" d="$4"
  local saida; saida="$(bash "$G" "$d" 2>&1)"; local rc=$?
  if [ "$rc" = "$esp" ] && { [ -z "$agulha" ] || grep -qF -- "$agulha" <<<"$saida"; }; then echo "  ✔ $nome"; ok=$((ok+1))
  else echo "  ✖ $nome: exit $rc, esperado $esp (agulha \"$agulha\")"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); fi
}

echo "== P1-14: gate checa os 8 lints =="
d="$TMP/lints-faltando"; mkdir -p "$d"; echo 'void main() {}' > "$d/a.dart"
printf 'name: p\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\n' > "$d/pubspec.yaml"
printf 'linter:\n  rules:\n    - unawaited_futures\n    - use_build_context_synchronously\n    - avoid_dynamic_calls\n    - cancel_subscriptions\n' > "$d/analysis_options.yaml"
rodar lint-close_sinks-sumiu 1 "close_sinks" "$d"
d="$TMP/lints-ok"; mkdir -p "$d"; echo 'void main() {}' > "$d/a.dart"
printf 'name: p\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\n' > "$d/pubspec.yaml"; printf '%s\n' "$LINTS8" > "$d/analysis_options.yaml"
rodar 8-lints-verde 0 "regras textuais" "$d"

echo "== P1-10: app vs package/plugin, monorepo =="
d="$TMP/package"; mkdir -p "$d/lib"; echo 'class A {}' > "$d/lib/a.dart"
printf 'name: pkg\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\ndependencies:\n  flutter:\n    sdk: flutter\nflutter:\n  uses-material-design: true\n' > "$d/pubspec.yaml"; printf '%s\n' "$LINTS8" > "$d/analysis_options.yaml"
rodar package-sem-lock-passa 0 "" "$d"
d="$TMP/plugin"; mkdir -p "$d/lib"; echo 'class A {}' > "$d/lib/a.dart"
printf 'name: plg\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\ndependencies:\n  flutter:\n    sdk: flutter\nflutter:\n  plugin:\n    platforms:\n      android:\n        package: x\n' > "$d/pubspec.yaml"; printf '%s\n' "$LINTS8" > "$d/analysis_options.yaml"
rodar plugin-sem-lock-passa 0 "" "$d"
d="$TMP/mono"; mkdir -p "$d/apps/app/lib" "$d/packages/util/lib"
echo 'void main() {}' > "$d/apps/app/lib/main.dart"; echo 'class U {}' > "$d/packages/util/lib/u.dart"
printf 'name: app\npublish_to: none\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\ndependencies:\n  flutter:\n    sdk: flutter\n' > "$d/apps/app/pubspec.yaml"
printf 'name: util\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\n' > "$d/packages/util/pubspec.yaml"
printf '%s\n' "$LINTS8" > "$d/analysis_options.yaml"
rodar monorepo-app-aninhado-sem-lock 1 "apps/app/pubspec.yaml: pubspec.lock ausente" "$d"
: > "$d/apps/app/pubspec.lock"
rodar monorepo-com-lock 0 "" "$d"

echo "== P1-11: .listen( por subscription =="
d="$TMP/l1"; mkdir -p "$d"; cat > "$d/a.dart" <<'FIX'
import 'dart:async';
class R {
  StreamSubscription<int>? _sub;
  Timer? _t;
  void ouvir(Stream<int> s) { _sub = s.listen((v) {}); }
  void parar() { _t?.cancel(); }
}
FIX
rodar listen-com-Timer.cancel-nao-vale 1 "_sub" "$d"
d="$TMP/l2"; mkdir -p "$d"; cat > "$d/a.dart" <<'FIX'
import 'dart:io';
void main() {
  stdin.listen((bytes) => stdout.add(bytes));
}
FIX
rodar stdin-listen-e-cli 0 "" "$d"
d="$TMP/l3"; mkdir -p "$d"; cat > "$d/a.dart" <<'FIX'
import 'dart:async';
class R {
  late StreamSubscription<int> sub;
  void ouvir(Stream<int> s) {
    sub = s
        .listen((v) {});
  }
  Future<void> dispose() async { await sub.cancel(); }
}
FIX
rodar listen-multilinha-com-cancel 0 "" "$d"

echo "== P1-11/P2-9: context depois de await por região =="
d="$TMP/m1"; mkdir -p "$d"; cat > "$d/a.dart" <<'FIX'
class A {
  Future<void> seguro(BuildContext context) async {
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> furado(BuildContext context) async {
    await Future<void>.delayed(Duration.zero);
    Navigator.of(context).pop();
  }
}
FIX
rodar mounted-em-outra-funcao-nao-protege 0 "a.dart:10: usa \`context\` depois de \`await\`" "$d"
d="$TMP/m2"; mkdir -p "$d"; cat > "$d/a.dart" <<'FIX'
class A {
  Future<void> seguro(BuildContext context) async {
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}
FIX
rodar mounted-ok-sem-aviso 0 "regras textuais" "$d"

echo "== teste pode usar bang =="
caso bang-em-teste 0 "" "repositorio_test.dart" <<'FIX'
import 'package:test/test.dart';

void main() {
  test('acha', () {
    final m = {'a': 1};
    expect(m['a']!, 1);
  });
}
FIX

echo "== nada para verificar =="
d="$TMP/vazio"; mkdir -p "$d"; echo "# prosa" > "$d/LEIA.md"
saida="$(bash "$G" "$d" 2>&1)"; rc=$?
if [ "$rc" = 2 ] && grep -q "não é aprovação" <<<"$saida"; then echo "  ✔ repo sem .dart sai 2 (não 0)"; ok=$((ok+1))
else echo "  ✖ repo sem .dart: exit $rc"; fail=$((fail+1)); fi

echo; echo "check-dart: $ok ok, $fail falha(s)"; [ "$fail" = 0 ]
