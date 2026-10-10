<#
.SYNOPSIS
  Aplica tarjas sólidas (estilo "skeleton") sobre áreas com dados pessoais ou do cliente
  nas capturas originais, antes da conversão para WebP.

.DESCRIPTION
  Lê scripts/tarjas.json:
    {
      "pasta/arquivo.png": {
        "rects": [[x, y, largura, altura], [x, y, w, h, "#rrggbb"]],
        "crop":  [x, y, largura, altura]          (opcional)
      }
    }
  Coordenadas em pixels da imagem original (1900x908).
  Imagens fora do JSON são apenas copiadas. Nada é alterado na origem.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\tarjar-imagens.ps1
#>
param(
    [string]$Origem  = (Join-Path $PSScriptRoot '..\..\portfolio-originais\projetos'),
    [string]$Destino = (Join-Path $PSScriptRoot '..\..\portfolio-originais\tarjadas'),
    [string]$Config  = (Join-Path $PSScriptRoot 'tarjas.json'),
    [string]$Somente = ''   # filtra por trecho do caminho relativo (ex.: "banco de horas")
)

Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

$Origem  = (Resolve-Path $Origem).Path
New-Item -ItemType Directory -Force $Destino | Out-Null
$Destino = (Resolve-Path $Destino).Path

$json = [IO.File]::ReadAllText($Config, [Text.Encoding]::UTF8) | ConvertFrom-Json
$regras = @{}
foreach ($p in $json.PSObject.Properties) { $regras[$p.Name.Replace('\', '/')] = $p.Value }

function New-RoundedPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $r = [Math]::Min($r, [Math]::Min($w, $h) / 2)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

$arquivos = Get-ChildItem -Recurse -File $Origem -Include *.png, *.jpg, *.jpeg
foreach ($f in $arquivos) {
    $rel = $f.FullName.Substring($Origem.Length + 1).Replace('\', '/')
    if ($Somente -and ($rel -notlike "*$Somente*")) { continue }
    $saida = Join-Path $Destino ($rel.Replace('/', '\'))
    New-Item -ItemType Directory -Force (Split-Path $saida) | Out-Null

    $regra = $regras[$rel]
    if (-not $regra) { Copy-Item -Force $f.FullName $saida; continue }

    $src = [System.Drawing.Image]::FromFile($f.FullName)
    $bmp = New-Object System.Drawing.Bitmap $src.Width, $src.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.DrawImage($src, 0, 0, $src.Width, $src.Height)
    $src.Dispose()

    # Cor automática: média do fundo logo ao redor da área, escurecida ~13% (efeito "skeleton").
    $amostras = @()
    foreach ($r in @($regra.rects)) {
        if (-not $r -or $r.Count -ge 5) { $amostras += ,$null; continue }
        $x0 = $r[0] - 4; $x1 = $r[0] + $r[2] + 4; $xm = $r[0] + $r[2] / 2
        $y0 = $r[1] - 4; $y1 = $r[1] + $r[3] + 4; $ym = $r[1] + $r[3] / 2
        $pts = @(@($x0, $y0), @($x1, $y0), @($x0, $y1), @($x1, $y1), @($xm, $y0), @($xm, $y1), @($x0, $ym), @($x1, $ym))
        $cs = foreach ($p in $pts) {
            $x = [Math]::Min([Math]::Max([int]$p[0], 0), $bmp.Width - 1); $y = [Math]::Min([Math]::Max([int]$p[1], 0), $bmp.Height - 1)
            $bmp.GetPixel($x, $y)
        }
        $lum = $cs | Sort-Object { $_.R + $_.G + $_.B }
        $mid = $lum[[int]($lum.Count / 2)]   # mediana, ignora bordas/elementos vizinhos
        $f = 0.87
        $amostras += ,([System.Drawing.Color]::FromArgb([int]($mid.R*$f), [int]($mid.G*$f), [int]([Math]::Min(255, $mid.B*$f + 6))))
    }

    $i = 0
    foreach ($r in @($regra.rects)) {
        if (-not $r) { $i++; continue }
        $cor = if ($r.Count -ge 5) { [System.Drawing.ColorTranslator]::FromHtml($r[4]) } else { $amostras[$i] }
        $i++
        $brush = New-Object System.Drawing.SolidBrush $cor
        $path = New-RoundedPath $r[0] $r[1] $r[2] $r[3] 6
        $g.FillPath($brush, $path)
        $path.Dispose(); $brush.Dispose()
    }
    $g.Dispose()

    if ($regra.crop) {
        $c = $regra.crop
        $rect = New-Object System.Drawing.Rectangle $c[0], $c[1], $c[2], $c[3]
        $cortada = $bmp.Clone($rect, $bmp.PixelFormat)
        $bmp.Dispose(); $bmp = $cortada
    }

    $bmp.Save($saida, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "tarjada: $rel"
}
Write-Host "Concluído -> $Destino"
