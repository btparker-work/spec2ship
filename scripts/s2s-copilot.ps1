param(
  [ValidateSet("init", "specs", "design", "plan", "code", "all")]
  [string]$Mode = "all",
  [string]$ProjectRoot = ".",
  [string]$Topic = "Build a web dashboard for operational metrics",
  [string]$Model = "",
  [string]$AppName = "S2SGeneratedDashboard",
  [ValidateSet("aspnet-dashboard", "node-dashboard")]
  [string]$AppTemplate = "aspnet-dashboard",
  [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-FullPath {
  param([string]$Path)
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Ensure-Directory {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Get-Slug {
  param([string]$Text)
  $value = $Text.ToLowerInvariant()
  $value = [regex]::Replace($value, "[^a-z0-9]+", "-")
  $value = $value.Trim('-')
  if ([string]::IsNullOrWhiteSpace($value)) {
    return "item"
  }
  return $value
}

function Ensure-Command {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Missing required command: $Name"
  }
}

function Invoke-CopilotText {
  param(
    [Parameter(Mandatory = $true)][string]$Prompt,
    [Parameter(Mandatory = $true)][string]$Model
  )

  $args = @(
    "copilot",
    "--",
    "-p",
    $Prompt,
    "--silent",
    "--no-ask-user",
    "--no-custom-instructions",
    "--allow-all-tools",
    "--allow-all-paths",
    "--allow-all-urls"
  )

  if (-not [string]::IsNullOrWhiteSpace($Model)) {
    $args += @("--model", $Model)
  }

  $previousErrorAction = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $output = & gh @args 2>&1
  }
  finally {
    $ErrorActionPreference = $previousErrorAction
  }
  if ($LASTEXITCODE -ne 0) {
    $err = ($output | Out-String)
    throw "Copilot text prompt failed: $err"
  }

  return (($output | Out-String).Trim())
}

function Invoke-CopilotAgent {
  param(
    [Parameter(Mandatory = $true)][string]$Prompt,
    [Parameter(Mandatory = $true)][string]$Model
  )

  $args = @(
    "copilot",
    "--",
    "-p",
    $Prompt,
    "--no-ask-user",
    "--no-custom-instructions",
    "--allow-all-tools",
    "--allow-all-paths",
    "--allow-all-urls"
  )

  if (-not [string]::IsNullOrWhiteSpace($Model)) {
    $args += @("--model", $Model)
  }

  $previousErrorAction = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $output = & gh @args 2>&1
  }
  finally {
    $ErrorActionPreference = $previousErrorAction
  }
  if ($LASTEXITCODE -ne 0) {
    $err = ($output | Out-String)
    throw "Copilot agent prompt failed: $err"
  }

  return ($output | Out-String)
}

function Normalize-MarkdownOutput {
  param([string]$Content)

  $normalized = $Content -replace "`r", ""
  $match = [regex]::Match($normalized, '(?m)^#\s+')
  if ($match.Success) {
    return $normalized.Substring($match.Index).Trim()
  }

  return $normalized.Trim()
}

function Ensure-S2SRoot {
  param(
    [string]$Root,
    [string]$Topic
  )

  $s2sPath = Join-Path $Root ".s2s"
  Ensure-Directory $s2sPath
  Ensure-Directory (Join-Path $s2sPath "plans")
  Ensure-Directory (Join-Path $s2sPath "sessions")
  Ensure-Directory (Join-Path $s2sPath "decisions")
  Ensure-Directory (Join-Path $Root "generated")

  $contextPath = Join-Path $s2sPath "CONTEXT.md"
  if (-not (Test-Path -LiteralPath $contextPath)) {
    $contextContent = @"
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

$Topic

## Scope

**Type**: MVP - minimal viable, speed over completeness
"@
    Set-Content -LiteralPath $contextPath -Value $contextContent -Encoding utf8
  }

  $configPath = Join-Path $s2sPath "config.yaml"
  if (-not (Test-Path -LiteralPath $configPath)) {
    $templatePath = Join-Path $Root "templates/project/config.yaml"
    if (Test-Path -LiteralPath $templatePath) {
      $template = Get-Content -LiteralPath $templatePath -Raw
      $template = $template.Replace("{project-name}", (Split-Path $Root -Leaf))
      $template = $template.Replace("{standalone | workspace | component}", "standalone")
      Set-Content -LiteralPath $configPath -Value $template -Encoding utf8
    }
    else {
      $fallbackConfig = @"
name: """$(Split-Path $Root -Leaf)"""
type: """standalone"""
version: """0.1.0"""
"@
      Set-Content -LiteralPath $configPath -Value $fallbackConfig -Encoding utf8
    }
  }

  $configRaw = Get-Content -LiteralPath $configPath -Raw
  if ($configRaw -notmatch "(?m)^execution:") {
    $configRaw = $configRaw.TrimEnd() + @"

# Execution engine
execution:
  engine: "copilot-cli"           # claude-code | copilot-cli
  copilot_cli:
    enabled: true
    model: "$Model"
    command: "gh copilot"
    allow_all_tools: true
    no_ask_user: true
"@
    Set-Content -LiteralPath $configPath -Value $configRaw -Encoding utf8
  }
}

function Invoke-Specs {
  param([string]$Root, [string]$Model)

  $contextPath = Join-Path $Root ".s2s/CONTEXT.md"
  $context = Get-Content -LiteralPath $contextPath -Raw

  $prompt = @"
You are generating Spec2Ship requirements.

Output ONLY markdown for file .s2s/requirements.md.

Requirements:
- Include sections: Functional Requirements, Non-Functional Requirements, Constraints, Open Questions.
- Use IDs REQ-001.. and NFR-001..
- Make requirements testable and concise.

Project context:
$context
"@

  $requirements = Invoke-CopilotText -Prompt $prompt -Model $Model
  $requirements = Normalize-MarkdownOutput -Content $requirements
  $requirementsPath = Join-Path $Root ".s2s/requirements.md"
  Set-Content -LiteralPath $requirementsPath -Value $requirements -Encoding utf8
  Write-Host "Generated: $requirementsPath"
}

function Invoke-Design {
  param([string]$Root, [string]$Model)

  $context = Get-Content -LiteralPath (Join-Path $Root ".s2s/CONTEXT.md") -Raw
  $requirements = Get-Content -LiteralPath (Join-Path $Root ".s2s/requirements.md") -Raw

  $prompt = @"
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
"@

  $architecture = Invoke-CopilotText -Prompt $prompt -Model $Model
  $architecture = Normalize-MarkdownOutput -Content $architecture
  $architecturePath = Join-Path $Root ".s2s/architecture.md"
  Set-Content -LiteralPath $architecturePath -Value $architecture -Encoding utf8
  Write-Host "Generated: $architecturePath"
}

function Invoke-Plan {
  param([string]$Root, [string]$Model)

  $requirements = Get-Content -LiteralPath (Join-Path $Root ".s2s/requirements.md") -Raw
  $architecture = Get-Content -LiteralPath (Join-Path $Root ".s2s/architecture.md") -Raw
  $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $planPath = Join-Path $Root ".s2s/plans/$timestamp-copilot-implementation.md"

  $prompt = @"
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
"@

  $plan = Invoke-CopilotText -Prompt $prompt -Model $Model
  $plan = Normalize-MarkdownOutput -Content $plan
  Set-Content -LiteralPath $planPath -Value $plan -Encoding utf8
  Write-Host "Generated: $planPath"
}

function Invoke-CodeGen {
  param(
    [string]$Root,
    [string]$Model,
    [string]$AppName,
    [string]$AppTemplate,
    [bool]$Force
  )

  $generatedRoot = Join-Path $Root "generated"
  Ensure-Directory $generatedRoot
  $appPath = Join-Path $generatedRoot $AppName

  if ((Test-Path -LiteralPath $appPath) -and (-not $Force)) {
    throw "Target app already exists: $appPath (use -Force to overwrite after cleanup)"
  }

  if ((Test-Path -LiteralPath $appPath) -and $Force) {
    Remove-Item -LiteralPath $appPath -Recurse -Force
  }

  $requirementsPath = Join-Path $Root ".s2s/requirements.md"
  $architecturePath = Join-Path $Root ".s2s/architecture.md"
  if (-not (Test-Path -LiteralPath $requirementsPath) -or -not (Test-Path -LiteralPath $architecturePath)) {
    throw "Missing .s2s/requirements.md or .s2s/architecture.md. Run specs/design first."
  }

  $requirements = Get-Content -LiteralPath $requirementsPath -Raw
  $architecture = Get-Content -LiteralPath $architecturePath -Raw

  $dotnetExists = [bool](Get-Command dotnet -ErrorAction SilentlyContinue)
  $effectiveTemplate = $AppTemplate
  if (($AppTemplate -eq "aspnet-dashboard") -and (-not $dotnetExists)) {
    Write-Warning "dotnet SDK not found; falling back to node-dashboard"
    $effectiveTemplate = "node-dashboard"
  }

  Ensure-Directory $appPath
  Push-Location $appPath
  try {
    if ($effectiveTemplate -eq "aspnet-dashboard") {
      & dotnet new mvc --force --name $AppName --output . | Out-Null
      if ($LASTEXITCODE -ne 0) {
        throw "dotnet new mvc failed"
      }
    }

    $codePrompt = @"
You are implementing software from Spec2Ship artifacts in the current directory.

Objective:
- Build a working $effectiveTemplate app named $AppName.
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
"@

    try {
      $null = Invoke-CopilotAgent -Prompt $codePrompt -Model $Model
    }
    catch {
      Write-Warning "Copilot agent code-edit step failed; continuing with generated scaffold. Details: $($_.Exception.Message)"
    }

    if ($effectiveTemplate -eq "aspnet-dashboard") {
      & dotnet build | Out-Host
      if ($LASTEXITCODE -ne 0) {
        throw "dotnet build failed"
      }
    }
    else {
      if (Test-Path -LiteralPath (Join-Path $appPath "package.json")) {
        & npm install | Out-Host
        if ($LASTEXITCODE -ne 0) {
          throw "npm install failed"
        }
      }
    }
  }
  finally {
    Pop-Location
  }

  Write-Host "Generated app: $appPath"
}

Ensure-Command -Name "gh"
$root = Resolve-FullPath -Path $ProjectRoot
Ensure-Directory $root

switch ($Mode) {
  "init" {
    Ensure-S2SRoot -Root $root -Topic $Topic
    Write-Host "Initialized Copilot mode in $root"
  }
  "specs" {
    Ensure-S2SRoot -Root $root -Topic $Topic
    Invoke-Specs -Root $root -Model $Model
  }
  "design" {
    Ensure-S2SRoot -Root $root -Topic $Topic
    Invoke-Design -Root $root -Model $Model
  }
  "plan" {
    Ensure-S2SRoot -Root $root -Topic $Topic
    Invoke-Plan -Root $root -Model $Model
  }
  "code" {
    Ensure-S2SRoot -Root $root -Topic $Topic
    Invoke-CodeGen -Root $root -Model $Model -AppName $AppName -AppTemplate $AppTemplate -Force:$Force
  }
  "all" {
    Ensure-S2SRoot -Root $root -Topic $Topic
    Invoke-Specs -Root $root -Model $Model
    Invoke-Design -Root $root -Model $Model
    Invoke-Plan -Root $root -Model $Model
    Invoke-CodeGen -Root $root -Model $Model -AppName $AppName -AppTemplate $AppTemplate -Force:$Force
  }
  default {
    throw "Unsupported mode: $Mode"
  }
}
