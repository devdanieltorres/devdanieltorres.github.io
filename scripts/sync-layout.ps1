<#
.SYNOPSIS
  Replica head, header e footer de partials/ em todas as páginas HTML da raiz.

.DESCRIPTION
  Cada página tem marcadores, por exemplo:
    <!-- layout:header -->  ...conteúdo gerado...  <!-- /layout:header -->
  O que estiver entre eles é substituído pelo partial correspondente
  (partials/head.html, partials/header.html, partials/footer.html).
  Na index.html os links "index.html#secao" viram "#secao" (rolagem sem recarregar).
  404.html é ignorada (usa caminhos absolutos e é mantida à mão).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\sync-layout.ps1
#>
$ErrorActionPreference = 'Stop'
$raiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$utf8 = New-Object System.Text.UTF8Encoding($false)

$partials = @{}
foreach ($nome in 'head', 'header', 'footer') {
    $partials[$nome] = [IO.File]::ReadAllText((Join-Path $raiz "partials\$nome.html"), $utf8).TrimEnd()
}

$total = 0
foreach ($arq in Get-ChildItem -Path $raiz -Filter *.html -File) {
    if ($arq.Name -eq '404.html') { continue }
    $html = [IO.File]::ReadAllText($arq.FullName, $utf8)
    $original = $html
    foreach ($nome in $partials.Keys) {
        $conteudo = $partials[$nome]
        if ($arq.Name -eq 'index.html') { $conteudo = $conteudo.Replace('href="index.html#', 'href="#') }
        $padrao = "(?s)(<!-- layout:$nome -->).*?(<!-- /layout:$nome -->)"
        $html = [regex]::Replace($html, $padrao, { param($m) $m.Groups[1].Value + "`n    " + $conteudo + "`n    " + $m.Groups[2].Value })
    }
    if ($html -ne $original) {
        [IO.File]::WriteAllText($arq.FullName, $html, $utf8)
        $total++
        Write-Host "atualizada: $($arq.Name)"
    }
}
Write-Host "$total página(s) sincronizada(s)."
