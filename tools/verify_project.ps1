param(
    [Parameter(Mandatory = $true)][string]$GodotPath,
    [string]$PythonPath = 'python'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engineExecutable = (Resolve-Path -LiteralPath $GodotPath).Path
$logRoot = Join-Path $PSScriptRoot 'logs'
New-Item -ItemType Directory -Path $logRoot -Force | Out-Null

function Invoke-GodotCheck {
    param([string]$Name, [string[]]$Arguments)
    $outputFile = Join-Path $logRoot "$Name.log"
    & $engineExecutable @Arguments *> $outputFile
    $engineExitCode = $LASTEXITCODE
    Get-Content -LiteralPath $outputFile -Tail 18
    $diagnostics = Select-String -LiteralPath $outputFile -Pattern 'SCRIPT ERROR:|ERROR:|WARNING:|invalid UID|failed to load|Failed loading'
    if ($engineExitCode -ne 0 -or $diagnostics) {
        throw "$Name failed (exit $engineExitCode). See $outputFile"
    }
    Write-Host "PASS: $Name"
}

Invoke-GodotCheck -Name 'editor_import' -Arguments @('--headless', '--path', $projectRoot, '--editor', '--import')
& $PythonPath (Join-Path $PSScriptRoot 'verify_references.py') *> (Join-Path $logRoot 'references.json')
if ($LASTEXITCODE -ne 0) { Get-Content (Join-Path $logRoot 'references.json'); throw 'Resource reference checks failed' }
Get-Content -LiteralPath (Join-Path $logRoot 'references.json')
Invoke-GodotCheck -Name 'main_scene' -Arguments @('--headless', '--path', $projectRoot, '--quit-after', '180')
Invoke-GodotCheck -Name 'project_smoke' -Arguments @('--headless', '--path', $projectRoot, '--scene', 'res://tests/project_smoke.tscn')
Write-Host 'PASS: all resource, import, main scene and gameplay flow checks'
