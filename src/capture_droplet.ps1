param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_][A-Za-z0-9_.-]*@[A-Za-z0-9][A-Za-z0-9.-]*$')][string]$Pi,
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Sample,
    [string]$OutputDir = (Join-Path $PSScriptRoot '../data/captures')
)
$ErrorActionPreference = 'Stop'
$id = [guid]::NewGuid().ToString('N')
$stem = "$Sample-$(Get-Date -Format yyyyMMdd-HHmmss)-$id"
$remote = "droplet-captures/$stem.jpg"
$null = New-Item -ItemType Directory -Force -Path $OutputDir
$local = Join-Path $OutputDir "$stem.jpg"
& ssh $Pi "mkdir -p droplet-captures && rpicam-still --nopreview --timeout 2000 --quality 95 -o '$remote' && test -s '$remote'"
if ($LASTEXITCODE) { throw 'Capture failed. Check SSH and the camera list on the Pi.' }
& scp "${Pi}:$remote" "$local.part"
if ($LASTEXITCODE) { throw "Transfer failed. The image remains on the Pi at $remote." }
Move-Item -LiteralPath "$local.part" -Destination $local
Write-Output (Resolve-Path -LiteralPath $local).Path
