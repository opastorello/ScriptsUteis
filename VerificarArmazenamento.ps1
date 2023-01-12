# Define a lista de servidores
$servers = "Server1", "Server2", "Server3"

#Solicita credenciais do usuário
$credentials = Get-Credential

# Loop através da lista de servidores
foreach ($server in $servers) {
    try {
        # Loop enquanto credenciais estão inválidas
        do {        
            # Testa as credenciais
            $connection = Test-WsMan -ComputerName $server -Credential $credentials -ErrorAction Stop
        } while (!$connection)
        
        # Obter informações de armazenamento do servidor atual usando as credenciais do usuário
        $storage = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $server -Credential $credentials -Filter "DeviceID='C:'"

        # Exibir o nome do servidor e o espaço de armazenamento disponível
        Write-Host "Servidor: $server`nArmazenamento disponível: $(($storage.FreeSpace/1GB)) GB"
    }
    catch {
        # Exibir uma mensagem de erro se não for possível obter informações do servidor
        Write-Host "Não é possível obter informações de armazenamento do servidor: $server. Erro: $($_.Exception.Message)"
    }
}
