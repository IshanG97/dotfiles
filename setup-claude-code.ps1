# Claude Code Configuration Setup (PowerShell)
# Supports bidirectional sync between repo/.claude and ~/.claude

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('export', 'import')]
    [string]$Command
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoClaudeDir = Join-Path $ScriptDir ".claude"
$GlobalClaudeDir = Join-Path $env:USERPROFILE ".claude"

function Show-Usage {
    Write-Host "Usage: .\setup-claude-code.ps1 <command>" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  export    Copy .claude from this repo to ~/.claude"
    Write-Host "  import    Copy ~/.claude into this repo"
    Write-Host ""
}

# Export: repo -> ~/.claude
function Do-Export {
    Write-Host "Exporting .claude from repo to ~/.claude..." -ForegroundColor Cyan

    if (-not (Test-Path $RepoClaudeDir)) {
        Write-Host "Error: $RepoClaudeDir does not exist" -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path $GlobalClaudeDir)) {
        New-Item -ItemType Directory -Path $GlobalClaudeDir -Force | Out-Null
    }

    # Backup and copy CLAUDE.md
    $SourceClaudeMd = Join-Path $RepoClaudeDir "CLAUDE.md"
    $DestClaudeMd = Join-Path $GlobalClaudeDir "CLAUDE.md"
    if (Test-Path $SourceClaudeMd) {
        if (Test-Path $DestClaudeMd) {
            $BackupName = "CLAUDE.md.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item -Path $DestClaudeMd -Destination (Join-Path $GlobalClaudeDir $BackupName) -Force
        }
        Copy-Item -Path $SourceClaudeMd -Destination $DestClaudeMd -Force
        Write-Host "Copied CLAUDE.md"
    }

    # Backup and copy settings.json
    $SourceSettings = Join-Path $RepoClaudeDir "settings.json"
    $DestSettings = Join-Path $GlobalClaudeDir "settings.json"
    if (Test-Path $SourceSettings) {
        if (Test-Path $DestSettings) {
            $BackupName = "settings.json.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item -Path $DestSettings -Destination (Join-Path $GlobalClaudeDir $BackupName) -Force
        }
        Copy-Item -Path $SourceSettings -Destination $DestSettings -Force
        Write-Host "Copied settings.json"
    }

    # Copy skills directory
    $SourceSkills = Join-Path $RepoClaudeDir "skills"
    $DestSkills = Join-Path $GlobalClaudeDir "skills"
    if (Test-Path $SourceSkills) {
        if (Test-Path $DestSkills) {
            Remove-Item -Path $DestSkills -Recurse -Force
        }
        Copy-Item -Path $SourceSkills -Destination $DestSkills -Recurse -Force
        Write-Host "Copied skills/"
    }

    Write-Host "Export complete" -ForegroundColor Green
}

# Import: ~/.claude -> repo
function Do-Import {
    Write-Host "Importing ~/.claude into repo..." -ForegroundColor Cyan

    if (-not (Test-Path $GlobalClaudeDir)) {
        Write-Host "Error: ~/.claude does not exist" -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path $RepoClaudeDir)) {
        New-Item -ItemType Directory -Path $RepoClaudeDir -Force | Out-Null
    }

    # Copy CLAUDE.md
    $SourceClaudeMd = Join-Path $GlobalClaudeDir "CLAUDE.md"
    $DestClaudeMd = Join-Path $RepoClaudeDir "CLAUDE.md"
    if (Test-Path $SourceClaudeMd) {
        Copy-Item -Path $SourceClaudeMd -Destination $DestClaudeMd -Force
        Write-Host "Copied CLAUDE.md"
    }

    # Copy settings.json
    $SourceSettings = Join-Path $GlobalClaudeDir "settings.json"
    $DestSettings = Join-Path $RepoClaudeDir "settings.json"
    if (Test-Path $SourceSettings) {
        Copy-Item -Path $SourceSettings -Destination $DestSettings -Force
        Write-Host "Copied settings.json"
    }

    # Copy skills directory
    $SourceSkills = Join-Path $GlobalClaudeDir "skills"
    $DestSkills = Join-Path $RepoClaudeDir "skills"
    if (Test-Path $SourceSkills) {
        if (Test-Path $DestSkills) {
            Remove-Item -Path $DestSkills -Recurse -Force
        }
        Copy-Item -Path $SourceSkills -Destination $DestSkills -Recurse -Force
        Write-Host "Copied skills/"
    }

    Write-Host "Import complete" -ForegroundColor Green
}

switch ($Command) {
    "export" { Do-Export }
    "import" { Do-Import }
    default {
        Show-Usage
        exit 1
    }
}
