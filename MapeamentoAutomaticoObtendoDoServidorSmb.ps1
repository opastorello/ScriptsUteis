# Especifica o nome do servidor a ser verificado para pastas compartilhadas
$server = 'server1'

# Obtém uma lista de pastas compartilhadas no servidor especificado, 
# selecionando somente os caminhos das pastas compartilhadas
$sharedFolders = Get-SmbShare | Where-Object {$_.ServerName -eq $server} | Select-Object -ExpandProperty Path

# Obtém uma lista de letras de unidade atualmente em uso e filtra para incluir somente unidades de rede
# Armazena as letras das unidades de rede na variável $driveLetters
$driveLetters = [System.IO.DriveInfo]::GetDrives() | Where-Object {$_.DriveType -eq 'Network'} | Select-Object -ExpandProperty Name

# Itera sobre cada pasta na lista de pastas compartilhadas
foreach ($folder in $sharedFolders) {

    # Obtém a lista de controle de acesso (ACL) da pasta atual
    $access = (Get-Acl $folder).Access
    
    # Obtém o nome do usuário atual
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    
    # Filtra a lista de permissões de acesso para incluir somente permissões para o usuário atual
    $hasAccess = $access | Where-Object {$_.IdentityReference -eq $currentUser}
    
    # Verifica se o usuário atual tem acesso à pasta
    if ($hasAccess) {
        
        # Verifica qual é a primeira letra de unidade disponível
        $availableDriveLetter = [char[]](65..90) | Where-Object {$driveLetters -notcontains $_ + ':'} | Select-Object -First 1
        
        # Se houver uma letra de unidade disponível,
        # cria uma nova unidade de rede para a pasta atual,
        # usando a letra de unidade disponível e o switch -Persist,
        # que faz com que a unidade seja persistente
        if($availableDriveLetter) {
            New-PSDrive -Name $availableDriveLetter -PSProvider FileSystem -Root $folder -Persist
            Write-Host "O usuário tem acesso à pasta $folder e foi mapeada com a letra $availableDriveLetter:"
        } else {
            # Se não houver uma letra de unidade disponível,
            # imprime uma mensagem dizendo que a pasta não pôde ser mapeada
            Write-Host "O usuário não tem acesso à pasta $folder, então não foi mapeada"
        }
    }
}
