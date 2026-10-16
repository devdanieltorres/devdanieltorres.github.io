<#
.SYNOPSIS
  Gera as imagens de compartilhamento (og:image, 1200x630 JPG) e o apple-touch-icon.

.DESCRIPTION
  Monta um cartão em HTML para a home e para cada case (título + capa em moldura),
  fotografa com o Microsoft Edge headless e salva em assets/img/og/<slug>.jpg.
  Rode de novo sempre que adicionar um case ou trocar uma capa.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\gerar-og.ps1
#>
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$raiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$saida = Join-Path $raiz 'assets\img\og'
New-Item -ItemType Directory -Force $saida | Out-Null
$tmp = Join-Path $env:TEMP 'portfolio-og'
New-Item -ItemType Directory -Force $tmp | Out-Null
$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
$url = { param($p) 'file:///' + ($p -replace '\\', '/') }

$css = @'
<style>
@import url("https://fonts.googleapis.com/css2?family=Geist:wght@400..700&family=Geist+Mono&family=Instrument+Serif:ital@0;1&display=block");
*{margin:0;box-sizing:border-box}
body{width:1200px;height:630px;overflow:hidden;background:#0f0d0a;color:#ece7dc;font-family:Geist,system-ui,sans-serif;position:relative}
.wrap{position:relative;z-index:1;height:100%;padding:60px 72px 56px;display:flex;flex-direction:column}
.brand{display:flex;align-items:center;gap:14px;font-size:24px;font-weight:500;padding-bottom:28px;border-bottom:1px solid rgba(236,231,220,.16)}
.mark{width:46px;height:46px;border-radius:3px;display:grid;place-items:center;font-family:"Instrument Serif",Georgia,serif;font-size:22px;color:#1a0e06;background:#ff5c28}
.eyebrow{font-family:"Geist Mono",monospace;color:#ff5c28;font-size:19px;letter-spacing:.14em;text-transform:uppercase;margin-top:auto}
h1{font-family:"Instrument Serif",Georgia,serif;font-size:88px;line-height:.98;letter-spacing:-.01em;font-weight:400;margin-top:18px;max-width:760px}
h1 em{font-style:italic;color:#ff5c28}
.sub{margin-top:20px;font-family:"Geist Mono",monospace;font-size:20px;letter-spacing:.04em;color:#a49d8f}
.shot{position:absolute;right:-70px;bottom:-50px;width:560px;border-radius:4px;border:1px solid rgba(236,231,220,.25);overflow:hidden;background:#171411;box-shadow:0 40px 90px rgba(0,0,0,.7)}
.bar{height:26px;display:flex;gap:7px;align-items:center;padding:0 14px;border-bottom:1px solid rgba(236,231,220,.12)}
.bar i{display:block;height:1px;background:rgba(236,231,220,.35)}
.bar i:nth-child(1){width:9px}.bar i:nth-child(2){width:14px}.bar i:nth-child(3){width:6px;background:#ff5c28}
.shot img{display:block;width:100%}
</style>
'@

function Shot([string]$slug, [string]$html) {
    $pagina = Join-Path $tmp "$slug.html"
    [IO.File]::WriteAllText($pagina, $html, (New-Object Text.UTF8Encoding($false)))
    $png = Join-Path $tmp "$slug.png"
    $eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    & $edge --headless=new --disable-gpu --hide-scrollbars --allow-file-access-from-files --user-data-dir="$tmp\perfil" `
        --window-size=1200,630 --virtual-time-budget=8000 --screenshot="$png" (& $url $pagina) 2>$null | Out-Null
    $ErrorActionPreference = $eap
    $img = [System.Drawing.Image]::FromFile($png)
    $enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
    $par = New-Object System.Drawing.Imaging.EncoderParameters 1
    $par.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 86L
    $img.Save((Join-Path $saida "$slug.jpg"), $enc, $par); $img.Dispose()
    "og: $slug.jpg"
}

$marca = '<div class="brand"><span class="mark">DT</span>Daniel Torres</div>'

# home
$foto = & $url (Join-Path $raiz 'assets\img\daniel-torres-480.webp')
Shot 'home' "<!doctype html><meta charset=utf-8>$css<div class=wrap>$marca<p class=eyebrow>Desenvolvedor full-stack · Brasília</p><h1>Software que resolve, do banco de dados à <em>interface</em>.</h1><p class=sub>Sistemas web · APIs · Dados · Automação — 19 projetos reais</p></div><div class=shot style=`"width:330px;right:70px;bottom:120px;transform:rotate(3deg)`"><img src=`"$foto`"></div>"

# cases: lê título, categoria e capa de cada página
foreach ($arq in Get-ChildItem $raiz -Filter *.html) {
    $h = [IO.File]::ReadAllText($arq.FullName, [Text.Encoding]::UTF8)
    if ($h -notmatch 'class="case-hero__cover"') { continue }
    $slug = $arq.BaseName
    $titulo = [regex]::Match($h, '<h1>(.*?)</h1>').Groups[1].Value
    $cat = [regex]::Match($h, '<span class="eyebrow">(.*?)</span>').Groups[1].Value
    $capa = [regex]::Match($h, 'case-hero__cover[\s\S]*?<img src="([^"]+)"').Groups[1].Value
    $capaUrl = & $url (Join-Path $raiz ($capa -replace '/', '\'))
    Shot $slug "<!doctype html><meta charset=utf-8>$css<div class=wrap>$marca<p class=eyebrow>$cat</p><h1 style=`"max-width:640px;font-size:68px`">$titulo</h1><p class=sub>Case · projeto em produção</p></div><div class=shot><div class=bar><i></i><i></i><i></i></div><img src=`"$capaUrl`"></div>"
}

# apple-touch-icon (180x180)
$icone = Join-Path $tmp 'icon.html'
[IO.File]::WriteAllText($icone, '<!doctype html><meta charset=utf-8><style>@import url("https://fonts.googleapis.com/css2?family=Instrument+Serif&display=block");*{margin:0}body{width:180px;height:180px;display:grid;place-items:center;background:#ff5c28;font:400 84px "Instrument Serif",Georgia,serif;color:#1a0e06;letter-spacing:-3px}</style>DT', (New-Object Text.UTF8Encoding($false)))
$eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
& $edge --headless=new --disable-gpu --hide-scrollbars --user-data-dir="$tmp\perfil" --window-size=180,180 --virtual-time-budget=5000 --screenshot="$(Join-Path $raiz 'assets\img\apple-touch-icon.png')" (& $url $icone) 2>$null | Out-Null
$ErrorActionPreference = $eap
'apple-touch-icon.png'
