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
@import url("https://fonts.googleapis.com/css2?family=Geist:wght@400..700&family=Geist+Mono&family=Instrument+Serif:ital@1&display=block");
*{margin:0;box-sizing:border-box}
body{width:1200px;height:630px;overflow:hidden;background:#07090d;color:#e8ebf1;font-family:Geist,system-ui,sans-serif;position:relative}
body:before{content:"";position:absolute;inset:0;background-image:linear-gradient(rgba(255,255,255,.04) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.04) 1px,transparent 1px);background-size:56px 56px;mask-image:radial-gradient(ellipse 90% 80% at 30% 0%,#000 30%,transparent 80%)}
body:after{content:"";position:absolute;inset:0;background:radial-gradient(520px 340px at 92% -10%,rgba(34,211,238,.22),transparent 70%),radial-gradient(460px 320px at -5% 110%,rgba(139,156,255,.16),transparent 70%)}
.wrap{position:relative;z-index:1;height:100%;padding:64px 72px;display:flex;flex-direction:column}
.brand{display:flex;align-items:center;gap:14px;font-size:24px;font-weight:600}
.mark{width:48px;height:48px;border-radius:12px;display:grid;place-items:center;font-family:"Geist Mono",monospace;font-size:18px;color:#5ee7ff;background:rgba(94,231,255,.1);border:1px solid rgba(94,231,255,.35)}
.eyebrow{font-family:"Geist Mono",monospace;color:#5ee7ff;font-size:22px;margin-top:auto}
h1{font-size:76px;line-height:1.02;letter-spacing:-.045em;font-weight:600;margin-top:14px;max-width:820px}
h1 em{font-family:"Instrument Serif",serif;font-weight:400;color:#5ee7ff;letter-spacing:-.01em}
.sub{margin-top:18px;font-size:26px;color:#9ba3b4}
.shot{position:absolute;right:-60px;bottom:-40px;width:560px;border-radius:14px;border:1px solid rgba(255,255,255,.16);overflow:hidden;background:#161b25;box-shadow:0 40px 90px rgba(0,0,0,.7);transform:rotate(-4deg)}
.bar{height:26px;display:flex;gap:6px;align-items:center;padding:0 12px}.bar i{width:9px;height:9px;border-radius:50%}
.bar i:nth-child(1){background:#ff5f57}.bar i:nth-child(2){background:#febc2e}.bar i:nth-child(3){background:#28c840}
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
[IO.File]::WriteAllText($icone, '<!doctype html><meta charset=utf-8><style>@import url("https://fonts.googleapis.com/css2?family=Geist+Mono:wght@600&display=block");*{margin:0}body{width:180px;height:180px;display:grid;place-items:center;background:radial-gradient(120px 120px at 80% 0%,rgba(34,211,238,.35),transparent),#0b0e14;font:600 64px "Geist Mono",monospace;color:#5ee7ff;letter-spacing:-2px}</style>DT', (New-Object Text.UTF8Encoding($false)))
$eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
& $edge --headless=new --disable-gpu --hide-scrollbars --user-data-dir="$tmp\perfil" --window-size=180,180 --virtual-time-budget=5000 --screenshot="$(Join-Path $raiz 'assets\img\apple-touch-icon.png')" (& $url $icone) 2>$null | Out-Null
$ErrorActionPreference = $eap
'apple-touch-icon.png'
