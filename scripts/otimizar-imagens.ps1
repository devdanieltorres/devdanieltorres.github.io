<#
.SYNOPSIS
  Converte capturas (PNG/JPG) para WebP em dois tamanhos usando o Microsoft Edge headless.

.DESCRIPTION
  Para cada pasta de origem gera em assets/projetos/<slug>/:
    01.webp      (largura original, até 1900px)  -> galeria e lightbox
    01-960.webp  (960px)                         -> cards e grades
  Não precisa instalar nada: usa o Edge (já presente no Windows) para decodificar,
  redimensionar com alta qualidade e codificar em WebP.

.EXAMPLE
  # converte tudo que está em ..\portfolio-originais\tarjadas
  powershell -ExecutionPolicy Bypass -File scripts\otimizar-imagens.ps1

  # converte uma pasta nova para o slug "meu-projeto"
  powershell -ExecutionPolicy Bypass -File scripts\otimizar-imagens.ps1 -Pasta "C:\capturas\meu projeto" -Slug meu-projeto
#>
param(
    [string]$Origem = (Join-Path $PSScriptRoot '..\..\portfolio-originais\tarjadas'),
    [string]$Pasta  = '',
    [string]$Slug   = '',
    [double]$Qualidade = 0.86,
    [int]$Pequena = 960
)

$ErrorActionPreference = 'Stop'
$raiz    = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$destino = Join-Path $raiz 'assets\projetos'

# pasta de origem -> slug (nome da página)
$mapa = [ordered]@{
    'Psicosocial'               = 'psicosocial'
    'Atendimento'               = 'central-atendimentos'
    'atestados'                 = 'gestao-atestados'
    'Avaliação de atendimento'  = 'avaliacao-atendimento'
    'anotacoes do colaborador'  = 'anotacoes-colaborador'
    'assinatura de documentos'  = 'assinatura-documentos'
    'banco de horas'            = 'banco-horas'
    'batidas atrasadas'         = 'batidas-atrasadas'
    'batidas de ponto'          = 'batidas-ponto'
    'cadastro de assinatura'    = 'cadastro-assinatura'
    'controle de quadro'        = 'controle-quadro'
    'documentos a assinar'      = 'documentos-assinar'
    'documentos assinados'      = 'documentos-assinados'
    'escala de folgas'          = 'escala-folgas'
    'gestao de projetos'        = 'gestao-projetos'
    'indicação para vagas'      = 'indicacao-vagas'
    'modulo social'             = 'modulo-social'
    'Tela inicial colab'        = 'tela-inicial-colab'
    'Tela inicial RH'           = 'tela-inicial-rh'
}

# imagens que não vão para o site (em branco ou sem valor depois das tarjas)
$ignorar = @('Avaliação de atendimento\7.png', 'banco de horas\1.png')

$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
          "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw 'Microsoft Edge não encontrado.' }

$tmp = Join-Path $env:TEMP 'portfolio-webp'
New-Item -ItemType Directory -Force $tmp | Out-Null

function Convert-Lote([object[]]$jobs) {
    # $jobs: @{ src = caminho; out = caminho base sem extensão }
    # As <img> seguram o evento "load"; a conversão roda de forma síncrona no onload,
    # garantindo que termine antes do --dump-dom.
    $imgs = ($jobs | ForEach-Object { '<img src="' + [Uri]::new($_.src).AbsoluteUri + '">' }) -join ''
    $html = @"
<!doctype html><meta charset="utf-8"><body><pre id="out"></pre>$imgs<script>
function reduz(img, w) {
  // reduções grandes em etapas de no máximo 2x preservam a nitidez do texto
  let src = img, sw = img.naturalWidth, sh = img.naturalHeight;
  const h = Math.round(sh * w / sw);
  while (sw / 2 > w) {
    const c = document.createElement('canvas'); c.width = Math.round(sw / 2); c.height = Math.round(sh / 2);
    const g = c.getContext('2d'); g.imageSmoothingQuality = 'high'; g.drawImage(src, 0, 0, c.width, c.height);
    src = c; sw = c.width; sh = c.height;
  }
  const c = document.createElement('canvas'); c.width = w; c.height = h;
  const g = c.getContext('2d'); g.imageSmoothingQuality = 'high'; g.drawImage(src, 0, 0, w, h);
  return c;
}
window.onload = () => {
  try {
    const res = [];
    for (const img of document.querySelectorAll('img')) {
      for (const w of [img.naturalWidth, $Pequena]) {
        const c = w === img.naturalWidth ? reduz(img, w) : reduz(img, Math.min(w, img.naturalWidth));
        res.push({w: c.width, full: w === img.naturalWidth, h: c.height, data: c.toDataURL('image/webp', $Qualidade)});
      }
    }
    document.getElementById('out').textContent = JSON.stringify(res);
  } catch (e) { document.getElementById('out').textContent = 'ERR ' + e; }
  document.querySelectorAll('img').forEach(i => i.remove());
};
</script>
"@
    $pagina = Join-Path $tmp 'conv.html'
    [IO.File]::WriteAllText($pagina, $html, (New-Object Text.UTF8Encoding($false)))
    $eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'   # o Edge escreve logs no stderr
    $dom = & $edge --headless=new --disable-gpu --allow-file-access-from-files --user-data-dir="$tmp\perfil" `
        --virtual-time-budget=60000 --dump-dom ("file:///" + ($pagina -replace '\\', '/')) 2>$null | Out-String
    $ErrorActionPreference = $eap
    $m = [regex]::Match($dom, '<pre id="out">(.*?)</pre>', 'Singleline')
    $txt = [System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
    if (-not $txt -or $txt.StartsWith('ERR')) { throw "Falha na conversão: $txt" }
    $res = $txt | ConvertFrom-Json
    for ($k = 0; $k -lt $jobs.Count; $k++) {
        foreach ($r in @($res[2 * $k], $res[2 * $k + 1])) {
            $sufixo = if ($r.full) { '' } else { "-$($r.w)" }
            $arq = "$($jobs[$k].out)$sufixo.webp"
            [IO.File]::WriteAllBytes($arq, [Convert]::FromBase64String(($r.data -split ',')[1]))
            "{0,-60} {1,5}x{2,-4} {3,6:N0} KB" -f ($arq.Substring($raiz.Length + 1)), $r.w, $r.h, ((Get-Item $arq).Length / 1KB)
        }
    }
}

function Get-Numero([string]$nome) {
    $base = [IO.Path]::GetFileNameWithoutExtension($nome)
    if ($base -match '^\d+$') { return '{0:D2}' -f [int]$base }
    return '01'
}

$pares = @()
if ($Pasta) {
    if (-not $Slug) { throw 'Informe -Slug junto com -Pasta.' }
    $pares += ,@((Resolve-Path $Pasta).Path, $Slug)
} else {
    $Origem = (Resolve-Path $Origem).Path
    foreach ($k in $mapa.Keys) { $pares += ,@((Join-Path $Origem $k), $mapa[$k]) }
}

foreach ($p in $pares) {
    $src = $p[0]; $slug = $p[1]
    if (-not (Test-Path $src)) { Write-Warning "pasta não encontrada: $src"; continue }
    $out = Join-Path $destino $slug
    New-Item -ItemType Directory -Force $out | Out-Null
    $jobs = @()
    foreach ($f in Get-ChildItem -File $src -Include *.png, *.jpg, *.jpeg -Recurse) {
        $rel = $f.FullName.Substring((Split-Path $src).Length + 1)
        if ($ignorar -contains $rel) { continue }
        $jobs += @{ src = $f.FullName; out = (Join-Path $out (Get-Numero $f.Name)) }
    }
    # lotes pequenos para manter a saída do Edge leve
    for ($i = 0; $i -lt $jobs.Count; $i += 4) {
        Convert-Lote @($jobs[$i..([Math]::Min($i + 3, $jobs.Count - 1))])
    }
}
