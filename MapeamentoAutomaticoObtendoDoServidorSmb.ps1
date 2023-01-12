$server = 'server1'
$sharedFolders = Get-SmbShare | Where-Object {$_.ServerName -eq $server -and $_.IsHidden -eq $false} | Select-Object -ExpandProperty Path
$driveLetters = [System.IO.DriveInfo]::GetDrives() | Where-Object {$_.DriveType -eq 'Network'} | Select-Object -ExpandProperty Name

foreach ($folder in $sharedFolders) {
    $access = (Get-Acl $folder).Access
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $hasAccess = $access | Where-Object {$_.IdentityReference -eq $currentUser}

    if ($hasAccess) {
        $availableDriveLetter = [char[]](65..90) | Where-Object {$driveLetters -notcontains $_ + ':'} | Select-Object -First 1
        if($availableDriveLetter) {
            New-PSDrive -Name $availableDriveLetter -PSProvider FileSystem -Root $folder -Persist
            Write-Host "O usuário tem acesso à pasta $folder e foi mapeada com a letra $availableDriveLetter em modo persistente:"
        } else {
            Write-Host "Não é possível mapear $folder, nenhuma letra de drive disponível."
        }
    } else {
        Write-Host "O usuário não tem acesso à pasta $folder, então não foi mapeada"
    }
}
