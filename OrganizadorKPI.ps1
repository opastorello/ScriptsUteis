#Por Nícolas Pastorello VER.1.2

# Função para verificar e criar diretórios
function CriarDiretorio {
    param(
        [string]$caminho
    )
    
    if (-not (Test-Path -Path $caminho -PathType Container)) {
        New-Item -Path $caminho -ItemType Directory
    }
}

# Função para organizar e renomear arquivos CSV
function OrganizarRenomearCSV {
    param(
        [string]$origem,
        [string]$destino
    )
    
    CriarDiretorio -caminho $destino
    
    $arquivosCSV = Get-ChildItem -Path $origem -Filter "*.csv"
    $dataAtual = Get-Date -Format "dd - MM"
    
    foreach ($arquivo in $arquivosCSV) {
        $prefixo = $arquivo.BaseName.Substring(0, 4)
        $diretorioPrefixo = Join-Path -Path $destino -ChildPath $prefixo
        
        CriarDiretorio -caminho $diretorioPrefixo
        
        Move-Item -Path $arquivo.FullName -Destination $diretorioPrefixo
        $novoNome = "$dataAtual - $($arquivo.Name)"
        Rename-Item -Path (Join-Path -Path $diretorioPrefixo -ChildPath $arquivo.Name) -NewName $novoNome
    }
   
}

# Função para analisar arquivos CSV
function AnalisarCSV {
    param(
        [string]$caminho,
        [int]$tamanhoMax
    )
    
    Clear-Host

    $dataAtual = Get-Date -Format "yyyy-MM-dd"
    $csvFiles = Get-ChildItem -Path $caminho -Filter *.csv -File -Recurse | Where-Object { $_.CreationTime.Date -eq $dataAtual }
    
    foreach ($csvFile in $csvFiles) {
        if ($csvFile.Length -le $tamanhoMax) {
            $csvContent = Get-Content $csvFile.FullName
            $computerNames = @()

            foreach ($line in $csvContent) {
                if ($line -match '^(.*\.group\.wan)') {
                    $computerNames += $Matches[1]
                }
            }

            if ($computerNames.Count -gt 0) {
                Write-Host "`n$($csvFile.Name)`n"
                $computerNames | ForEach-Object { Write-Host "- $_" }
            }
        }
    }
}

# Função para remover arquivos PDF
function RemoverPDF {
    param(
        [string]$caminho
    )
    
    $pdfFiles = Get-ChildItem -Path $caminho -Filter *.pdf
    
    foreach ($pdfFile in $pdfFiles) {
        Remove-Item -Path $pdfFile.FullName
    }
}

# Diretórios e parâmetros
$diretorioOrigem = ""
$diretorioDestino = ""
$tamanhoMaximo = 10KB

# Remover arquivos PDF se existirem
RemoverPDF -caminho $diretorioOrigem

# Chama as funções
OrganizarRenomearCSV -origem $diretorioOrigem -destino $diretorioDestino
AnalisarCSV -caminho $diretorioDestino -tamanhoMax $tamanhoMaximo

Read-Host "`nProcesso concluído. Pressione Enter para sair"
