#!/usr/bin/env bash
set -euo pipefail

MODE="all"
PROJECT_ROOT="."
TOPIC="Build a web dashboard for operational metrics"
MODEL=""
APP_NAME="S2SGeneratedDashboard"
APP_TEMPLATE="aspnet-dashboard"
FORCE="false"

usage() {
  cat <<'USAGE'
Usage: scripts/s2s-copilot.sh [options]

Options:
  --mode <init|specs|design|plan|code|all>
  --project-root <path>
  --topic <text>
  --model <model>
  --app-name <name>
  --app-template <aspnet-dashboard|node-dashboard>
  --force
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"
      shift 2
      ;;
    --project-root)
      PROJECT_ROOT="$2"
      shift 2
      ;;
    --topic)
      TOPIC="$2"
      shift 2
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    --app-name)
      APP_NAME="$2"
      shift 2
      ;;
    --app-template)
      APP_TEMPLATE="$2"
      shift 2
      ;;
    --force)
      FORCE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

case "$MODE" in
  init|specs|design|plan|code|all) ;;
  *) echo "Unsupported mode: $MODE" >&2; exit 1 ;;
esac

case "$APP_TEMPLATE" in
  aspnet-dashboard|node-dashboard) ;;
  *) echo "Unsupported app template: $APP_TEMPLATE" >&2; exit 1 ;;
esac

PROJECT_ROOT="$(python3 - <<PY
import os
print(os.path.abspath(r'''$PROJECT_ROOT'''))
PY
)"

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Missing required command: $cmd" >&2
    exit 1
  }
}

ensure_dir() {
  mkdir -p "$1"
}

copilot_text() {
  local prompt="$1"
  local clean_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  local args=(copilot -- -p "$prompt" --silent --no-ask-user --no-custom-instructions --allow-all-tools --allow-all-paths --allow-all-urls)
  if [[ -n "${MODEL}" ]]; then
    args+=(--model "${MODEL}")
  fi
  PATH="$clean_path" gh "${args[@]}"
}

copilot_agent() {
  local prompt="$1"
  local clean_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  local args=(copilot -- -p "$prompt" --no-ask-user --no-custom-instructions --allow-all-tools --allow-all-paths --allow-all-urls)
  if [[ -n "${MODEL}" ]]; then
    args+=(--model "${MODEL}")
  fi
  PATH="$clean_path" gh "${args[@]}"
}

normalize_markdown() {
  python3 -c 'import re,sys; data=sys.stdin.read().replace("\r", ""); m=re.search(r"(?m)^#\\s+", data); out=(data[m.start():] if m else data).strip(); print(out)'
}

ensure_s2s_root() {
  local root="$1"
  ensure_dir "$root/.s2s/plans"
  ensure_dir "$root/.s2s/sessions"
  ensure_dir "$root/.s2s/decisions"
  ensure_dir "$root/generated"

  if [[ ! -f "$root/.s2s/CONTEXT.md" ]]; then
    cat > "$root/.s2s/CONTEXT.md" <<EOF
# Project Context

## Business Domain

Web Application

## Project Objectives

- Generate requirements, architecture, and implementation plans using Copilot CLI
- Implement software from generated specification artifacts

## Project Constraints

- Use GitHub Copilot CLI as the primary agent runtime
- Keep compatibility with existing Spec2Ship Claude workflows

## Project Overview

$TOPIC

## Scope

**Type**: MVP - minimal viable, speed over completeness
EOF
  fi

  if [[ ! -f "$root/.s2s/config.yaml" ]]; then
    if [[ -f "$root/templates/project/config.yaml" ]]; then
      sed \
        -e "s/{project-name}/$(basename "$root")/g" \
        -e "s/{standalone | workspace | component}/standalone/g" \
        "$root/templates/project/config.yaml" > "$root/.s2s/config.yaml"
    else
      cat > "$root/.s2s/config.yaml" <<EOF
name: "$(basename "$root")"
type: "standalone"
version: "0.1.0"
EOF
    fi
  fi

  if ! grep -q '^execution:' "$root/.s2s/config.yaml"; then
    cat >> "$root/.s2s/config.yaml" <<EOF

# Execution engine
execution:
  engine: "copilot-cli"           # claude-code | copilot-cli
  copilot_cli:
    enabled: true
    model: "$MODEL"
    command: "gh copilot"
    allow_all_tools: true
    no_ask_user: true
EOF
  fi
}

run_specs() {
  local root="$1"
  local context
  context="$(cat "$root/.s2s/CONTEXT.md")"

  local prompt
  prompt=$(cat <<EOF
You are generating Spec2Ship requirements.

Output ONLY markdown for file .s2s/requirements.md.

Requirements:
- Include sections: Functional Requirements, Non-Functional Requirements, Constraints, Open Questions.
- Use IDs REQ-001.. and NFR-001..
- Make requirements testable and concise.

Project context:
$context
EOF
)

  copilot_text "$prompt" | normalize_markdown > "$root/.s2s/requirements.md"
  echo "Generated: $root/.s2s/requirements.md"
}

run_design() {
  local root="$1"
  local context requirements prompt
  context="$(cat "$root/.s2s/CONTEXT.md")"
  requirements="$(cat "$root/.s2s/requirements.md")"

  prompt=$(cat <<EOF
You are generating Spec2Ship architecture output.

Output ONLY markdown for file .s2s/architecture.md.

Requirements:
- Use arc42-style sections: Context, Solution Strategy, Building Blocks, Runtime View, Deployment View, Risks.
- Reference relevant REQ/NFR IDs where appropriate.
- Keep it implementation-oriented.

Project context:
$context

Requirements:
$requirements
EOF
)

  copilot_text "$prompt" | normalize_markdown > "$root/.s2s/architecture.md"
  echo "Generated: $root/.s2s/architecture.md"
}

run_plan() {
  local root="$1"
  local requirements architecture ts plan_path prompt
  requirements="$(cat "$root/.s2s/requirements.md")"
  architecture="$(cat "$root/.s2s/architecture.md")"
  ts="$(date +"%Y%m%d-%H%M%S")"
  plan_path="$root/.s2s/plans/${ts}-copilot-implementation.md"

  prompt=$(cat <<EOF
You are generating a Spec2Ship implementation plan.

Output ONLY markdown for a plan file.

Requirements:
- Include sections: Goal, Assumptions, Work Breakdown, Dependencies, Risks, Validation.
- Work Breakdown must have task IDs T-001.. and clear completion criteria.
- Keep sequence executable by one developer in 1-2 days.

Requirements doc:
$requirements

Architecture doc:
$architecture
EOF
)

  copilot_text "$prompt" | normalize_markdown > "$plan_path"
  echo "Generated: $plan_path"
}

run_codegen() {
  local root="$1"
  local app_path effective_template
  app_path="$root/generated/$APP_NAME"
  effective_template="$APP_TEMPLATE"

  if [[ -d "$app_path" && "$FORCE" != "true" ]]; then
    echo "Target app already exists: $app_path (use --force)" >&2
    exit 1
  fi

  if [[ -d "$app_path" && "$FORCE" == "true" ]]; then
    rm -rf "$app_path"
  fi

  if [[ ! -f "$root/.s2s/requirements.md" || ! -f "$root/.s2s/architecture.md" ]]; then
    echo "Missing .s2s/requirements.md or .s2s/architecture.md. Run specs/design first." >&2
    exit 1
  fi

  local requirements architecture
  requirements="$(cat "$root/.s2s/requirements.md")"
  architecture="$(cat "$root/.s2s/architecture.md")"

  if [[ "$effective_template" == "aspnet-dashboard" ]] && ! command -v dotnet >/dev/null 2>&1; then
    echo "dotnet SDK not found; falling back to node-dashboard" >&2
    effective_template="node-dashboard"
  fi

  mkdir -p "$app_path"
  pushd "$app_path" >/dev/null

  if [[ "$effective_template" == "aspnet-dashboard" ]]; then
    dotnet new mvc --force --name "$APP_NAME" --output . >/dev/null
  else
    cat > package.json <<EOF
{
  "name": "$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.21.2"
  }
}
EOF
    cat > server.js <<'EOF'
import express from 'express';

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (_, res) => {
  res.send(`<!doctype html>
  <html>
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>Operations Dashboard</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 24px; }
        .grid { display: grid; grid-template-columns: repeat(3, minmax(180px, 1fr)); gap: 16px; }
        .card { border: 1px solid #ddd; border-radius: 8px; padding: 12px; }
        .kpi { font-size: 1.8rem; margin: 6px 0; }
      </style>
    </head>
    <body>
      <h1>Operations Dashboard</h1>
      <div class="grid">
        <div class="card"><h3>Incidents</h3><div class="kpi">3</div><div>Open now</div></div>
        <div class="card"><h3>Uptime</h3><div class="kpi">99.95%</div><div>Last 7 days</div></div>
        <div class="card"><h3>Response Time</h3><div class="kpi">184ms</div><div>P95</div></div>
      </div>
    </body>
  </html>`);
});

app.listen(port, () => {
  console.log(`Dashboard running on http://localhost:${port}`);
});
EOF
  fi

  local code_prompt
  code_prompt=$(cat <<EOF
You are implementing software from Spec2Ship artifacts in the current directory.

Objective:
- Build a working $effective_template app named $APP_NAME.
- Implement a dashboard with at least: overview page, sample data source, and one chart or KPI summary section.

Rules:
- You may use shell commands and edit files directly.
- Keep implementation simple and production-sane.
- Add run instructions to README.md in this app folder.
- Ensure project builds successfully.

Specification inputs:
$requirements

Architecture inputs:
$architecture
EOF
)

  if ! copilot_agent "$code_prompt" >/dev/null; then
    echo "Warning: Copilot agent code-edit step failed; continuing with generated scaffold." >&2
  fi

  if [[ "$effective_template" == "aspnet-dashboard" ]]; then
    dotnet build
  else
    npm install
    npm start >/dev/null 2>&1 &
    local pid=$!
    sleep 2
    kill "$pid" >/dev/null 2>&1 || true
  fi

  popd >/dev/null
  echo "Generated app: $app_path"
}

require_command gh
require_command python3
ensure_dir "$PROJECT_ROOT"
ensure_s2s_root "$PROJECT_ROOT"

LOCK_PATH="$PROJECT_ROOT/.s2s/.s2s-copilot.lock"
if [[ -f "$LOCK_PATH" && "$FORCE" != "true" ]]; then
  echo "Another s2s-copilot run appears to be in progress (lock exists: $LOCK_PATH). Use --force to override." >&2
  exit 1
fi

echo "$$" > "$LOCK_PATH"
trap 'rm -f "$LOCK_PATH"' EXIT

case "$MODE" in
  init)
    echo "Initialized Copilot mode in $PROJECT_ROOT"
    ;;
  specs)
    run_specs "$PROJECT_ROOT"
    ;;
  design)
    run_design "$PROJECT_ROOT"
    ;;
  plan)
    run_plan "$PROJECT_ROOT"
    ;;
  code)
    run_codegen "$PROJECT_ROOT"
    ;;
  all)
    run_specs "$PROJECT_ROOT"
    run_design "$PROJECT_ROOT"
    run_plan "$PROJECT_ROOT"
    run_codegen "$PROJECT_ROOT"
    ;;
esac
