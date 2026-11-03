#!/usr/bin/env bash
# schematize-dart — o gate. Cobra o piso de `references/piso.md` sobre o Dart do repo.
#
# HONESTIDADE SOBRE O ALCANCE: este gate é TEXTUAL — ele não compila. Onde existir `flutter analyze`
# (com o `analysis_options.yaml` do projeto), é ELE que manda, e o gate diz isso na saída.
#
# strict-ok: COLETOR — varre tudo e soma os achados (`schematize-shell` -> `references/piso.md` secao 1)
set -uo pipefail

raiz="${1:-.}"
erros=(); avisos=()

arquivos=()
while IFS= read -r -d '' f; do arquivos+=("$f"); done < <(
  find "$raiz" -type f -name '*.dart' \
    -not -path '*/.dart_tool/*' -not -path '*/build/*' -not -path '*/.git/*' \
    -not -path '*/versions/*' -not -name '*.g.dart' -not -name '*.freezed.dart' -print0 2>/dev/null
)
if [ "${#arquivos[@]}" -eq 0 ]; then
  echo "✖ nenhum .dart em $raiz — nada para verificar (ausência de material não é aprovação)." >&2
  exit 2
fi

command -v flutter >/dev/null 2>&1 || command -v dart >/dev/null 2>&1 \
  || avisos+=("SDK do Dart/Flutter ausente nesta máquina: o gate rodou só as regras TEXTUAIS. Onde houver \`flutter analyze\`, é ele que manda")

# --------------------------------------------------------- projeto: lock e lints exigidos
LINTS=(unawaited_futures use_build_context_synchronously avoid_dynamic_calls cancel_subscriptions close_sinks prefer_const_constructors avoid_print only_throw_errors)

# sobe de $1 até a raiz procurando o arquivo $2 (workspace/monorepo: lock e análise podem morar acima)
acima() {
  local d="$1" nome="$2"
  while :; do
    [ -f "$d/$nome" ] && { echo "$d/$nome"; return 0; }
    [ "$d" = "$raiz" ] && return 1
    local pai; pai="$(dirname "$d")"
    [ "$pai" = "$d" ] && return 1
    d="$pai"
  done
}

pubspecs=()
while IFS= read -r -d '' f; do pubspecs+=("$f"); done < <(
  find "$raiz" -type f -name 'pubspec.yaml' \
    -not -path '*/.dart_tool/*' -not -path '*/build/*' -not -path '*/.git/*' \
    -not -path '*/versions/*' -not -path '*/node_modules/*' -not -path '*/.symlinks/*' -print0 2>/dev/null
)
for ps in "${pubspecs[@]}"; do
  dir="$(dirname "$ps")"; rel="${ps#"$raiz"/}"; [ "$rel" = "$ps" ] && rel="pubspec.yaml"
  # app = depende do SDK Flutter, NÃO é plugin e (publish_to none OU tem lib/main.dart).
  # package/plugin NÃO commita lock (plataforma.md secao 1).
  ehFlutter=0; ehPlugin=0; ehApp=0
  grep -qE '^\s*sdk:\s*flutter' "$ps" && ehFlutter=1
  grep -qE '^\s+plugin:\s*$' "$ps" && ehPlugin=1
  if [ "$ehFlutter" = 1 ] && [ "$ehPlugin" = 0 ]; then
    if grep -qE "^\s*publish_to:\s*['\"]?none" "$ps" || [ -f "$dir/lib/main.dart" ]; then ehApp=1; fi
  fi
  if [ "$ehApp" = 1 ] && ! acima "$dir" pubspec.lock >/dev/null; then
    erros+=("$rel: pubspec.lock ausente numa APLICAÇÃO — sem lock, duas máquinas resolvem versões diferentes (plataforma.md secao 1)")
  fi
  grep -qE '^\s*environment:' "$ps" \
    || erros+=("$rel: sem \`environment: sdk:\` — a versão do SDK é declarada, não herdada")
  grep -qE '^\s*dependency_overrides:' "$ps" \
    && avisos+=("$rel: \`dependency_overrides\` presente — é dívida com data: registre por que existe e quando sai")
  if ao="$(acima "$dir" analysis_options.yaml)"; then
    for lint in "${LINTS[@]}"; do
      grep -qE "^\s*-?\s*$lint\s*:?\s*(true|error|warning)?\s*$" "$ao" \
        || erros+=("${ao#"$raiz"/}: sem \`$lint\` explícito — o piso exige os 8 lints e herdar flutter_lints NÃO basta (stack-versoes.md)")
    done
  else
    erros+=("$rel: sem \`analysis_options.yaml\` — o gate do projeto é o \`flutter analyze\`, e ele precisa das regras do piso ligadas")
  fi
done

# --------------------------------------------------------- piso por arquivo
for f in "${arquivos[@]}"; do
  nome="${f#"$raiz"/}"
  ehTeste=0; case "$nome" in *_test.dart|*/test/*|*/integration_test/*) ehTeste=1 ;; esac
  # ordem: string primeiro, comentário depois
  codigo="$(sed -e "s/'[^']*'/''/g" -e 's/"[^"]*"/""/g' -e 's|//.*$||' "$f")"

  if [ "$ehTeste" = 0 ]; then
    grep -qE '[]A-Za-z_)]![]. ),;]|[]A-Za-z_)]!$' <<< "$codigo" \
      && erros+=("$nome: usa \`!\` (bang) — desliga exatamente a verificação de null safety pela qual você pagou a migração")
    grep -qE '\blate\s+(final\s+)?[A-Z]' <<< "$codigo" \
      && avisos+=("$nome: \`late\` — só onde o ciclo de vida garante inicialização; \`LateInitializationError\` não diz mais que um null")
  fi
  grep -qE '\bdynamic\b' <<< "$codigo" \
    && avisos+=("$nome: \`dynamic\` — desliga a checagem em compilação e vira NoSuchMethodError em produção")
  grep -qE 'catch\s*\([^)]*\)\s*\{\s*\}' <<< "$codigo" \
    && erros+=("$nome: \`catch\` vazio — erro engolido")
  grep -qE 'catch\s*\(\s*[a-z]+\s*\)\s*\{\s*print\(' <<< "$codigo" \
    && avisos+=("$nome: \`catch (e) { print(e); }\` — print não é log de produção e o stack trace some (use \`on X catch (e, s)\`)")
  grep -qE '\bprint\s*\(' <<< "$codigo" && [ "$ehTeste" = 0 ] \
    && avisos+=("$nome: \`print\` — sem nível, sem contexto, some no release; use o logger do projeto")
  # BuildContext depois de await, sem checar mounted: por região (reinicia a cada assinatura de função)
  if grep -qE '\bcontext\b' <<< "$codigo"; then
    achou="$(awk '
      /^[[:space:]]*(@override|(static[[:space:]]+)?(Future|void|Widget|Stream|[A-Z][A-Za-z0-9_]*)(<[^>]*>)?[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\()/ { aw=0 }
      /mounted/ { aw=0 }
      aw && /(^|[^.A-Za-z0-9_])context([^A-Za-z0-9_]|$)/ && !/BuildContext[[:space:]]+context/ { print NR; exit }
      /await[[:space:]]/ { aw=1 }
    ' <<< "$codigo")"
    [ -n "$achou" ] && avisos+=("$nome:$achou: usa \`context\` depois de \`await\` sem \`mounted\`/\`context.mounted\` antes — o widget pode ter sido desmontado (a armadilha nº 1 do Flutter)")
  fi
  # stream sem cancel: por .listen( — a variável que recebe a subscription precisa de <var>.cancel(
  # (Timer.cancel() e afins não contam; stdin/CLI/Process não têm ciclo de vida de tela)
  if grep -qE '\.listen\(' <<< "$codigo"; then
    while IFS= read -r st; do
      grep -qE '\.listen\(' <<< "$st" || continue
      grep -qE '\b(stdin|stdout|stderr|ProcessSignal|Process)\b' <<< "$st" && continue
      grep -qE '(^|[^A-Za-z0-9_])return[[:space:]]' <<< "$st" && continue
      var="$(sed -nE 's/.*[^A-Za-z0-9_.]([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*[^=;(]*\.listen\(.*/\1/p; t; s/^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*[^=;(]*\.listen\(.*/\1/p' <<< "$st" | head -n1)"
      if [ -n "$var" ]; then
        grep -qE "\\b$var\\??\\.cancel\\(" <<< "$codigo" \
          || erros+=("$nome: subscription \`$var\` de \`.listen(\` sem \`$var.cancel()\` — vazamento; dispara setState depois da tela morrer")
      elif grep -qE '\.add\([^;]*\.listen\(' <<< "$st"; then
        grep -qE '\.cancel\(' <<< "$(grep -viE 'timer' <<< "$codigo")" \
          || erros+=("$nome: \`.listen(\` guardado numa coleção, mas nenhum \`cancel()\` de subscription no arquivo — vazamento")
      else
        erros+=("$nome: \`.listen(\` sem guardar a subscription — não há como \`cancel()\`; vazamento e setState depois da tela morrer")
      fi
    done < <(tr '\n' ' ' <<< "$codigo" | tr ';' '\n')
  fi
  grep -qE 'shared_preferences|SharedPreferences' <<< "$codigo" \
    && grep -qiE 'token|senha|password|secret' "$f" \
    && erros+=("$nome: credencial em \`shared_preferences\` — é plist/XML EM CLARO; use flutter_secure_storage")
  grep -qE 'javascriptMode:\s*JavascriptMode\.unrestricted|\.setJavaScriptMode\(\s*JavaScriptMode\.unrestricted' <<< "$codigo" \
    && avisos+=("$nome: WebView com JS irrestrito — só com conteúdo próprio; o canal JS↔Dart é ponte de execução")
done

for a in "${avisos[@]:-}"; do [ -n "$a" ] && echo "  ! $a" >&2; done
if [ "${#erros[@]}" -gt 0 ]; then
  echo "" >&2
  echo "✖ DART REPROVADO — ${#erros[@]} problema(s) em ${#arquivos[@]} arquivo(s):" >&2
  for e in "${erros[@]}"; do echo "  · $e" >&2; done
  exit 1
fi
echo "✔ dart: ${#arquivos[@]} arquivo(s) nas regras textuais do piso."
