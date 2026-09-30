# Initialise the local .company-skill workspace in the current repository.
# LOCAL ONLY - the created tree must never be committed.
#
# Usage:  .\init-company-skill.ps1 -SkillDir <path> [-Repos ServiceA,ServiceB]

param(
    [Parameter(Mandatory = $true)] [string]   $SkillDir,
    [string[]] $Repos = @()
)

$ErrorActionPreference = 'Stop'

$tpl  = Join-Path $SkillDir 'templates'
$root = '.company-skill'

if (-not (Test-Path $tpl)) { throw "templates/ not found under $SkillDir" }

foreach ($d in @("$root/memory/global", "$root/memory/shared", "$root/memory/repositories", "$root/issues", "$root/temp")) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}

function Copy-IfAbsent($src, $dst) {
    if (-not (Test-Path $dst)) { Copy-Item $src $dst }
}

Get-ChildItem "$tpl/memory/global/*.md" | ForEach-Object { Copy-IfAbsent $_.FullName "$root/memory/global/$($_.Name)" }
Get-ChildItem "$tpl/memory/shared/*.md" | ForEach-Object { Copy-IfAbsent $_.FullName "$root/memory/shared/$($_.Name)" }

Copy-IfAbsent "$tpl/unknowns.md"    "$root/unknowns.md"
Copy-IfAbsent "$tpl/corrections.md" "$root/corrections.md"

foreach ($repo in $Repos) {
    $dir = "$root/memory/repositories/$repo"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Get-ChildItem "$tpl/memory/repositories/_REPO_TEMPLATE/*.md" | ForEach-Object {
        $target = Join-Path $dir $_.Name
        if (-not (Test-Path $target)) {
            (Get-Content $_.FullName -Raw).Replace('<RepoName>', $repo) |
                Out-File -FilePath $target -Encoding utf8
        }
    }
    Write-Output "seeded repository memory: $repo"
}

# .company-skill must never be committed.
# Use .git/info/exclude (local, never committed) - NOT .gitignore, so installing
# the skill produces zero diff in the repository.
$exclude = $null
try { $exclude = (& git rev-parse --git-path info/exclude 2>$null) } catch {}

if ($LASTEXITCODE -eq 0 -and $exclude) {
    $excludeDir = Split-Path $exclude -Parent
    if ($excludeDir -and -not (Test-Path $excludeDir)) { New-Item -ItemType Directory -Force -Path $excludeDir | Out-Null }
    if (-not (Test-Path $exclude)) { New-Item -ItemType File -Path $exclude | Out-Null }
    $lines = Get-Content $exclude
    if (-not ($lines -contains '.company-skill/')) {
        Add-Content $exclude "`n.company-skill/" -Encoding ascii
    }
    Write-Output "excluded via $exclude"
} else {
    Write-Warning "not a git repository - add '.company-skill/' to .git/info/exclude once it is."
}

Write-Output "done. .company-skill/ initialised (local only, .gitignore untouched)."
Write-Output "NOTE: existing files were never overwritten."
