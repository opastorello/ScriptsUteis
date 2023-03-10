$folder = "C:\Program Files\Snow Software\Inventory\Agent"
$screenshotFolder = "\\server\evidencias"
$computerName = hostname

#Abre uma sessão como administrador
$session = New-Object -ComObject Shell.Application
$shell = $session.ShellWindows

#Entra na pasta especificada
cd $folder

#Maximizando a janela antes de executar os comandos
$window = (Get-Process -Name powershell).MainWindowHandle
$Win32API = Add-Type -MemberDefinition '
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' -Name 'Win32API' -Namespace Win32Functions -PassThru
$Win32API::ShowWindow($window, 3)

#Isso irá mostrar uma janela para que o usuário insira suas credenciais
$credentials = Get-Credential

#Executa três comandos utilizando as credenciais
Start-Process PowerShell -Verb RunAs -Credential $credentials -ArgumentList "-Command &{snowagent.exe scan; snowagent.exe send; hostname}"

#Efetua screenshot da tela inteira e salva na pasta especificada com o nome do computador
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{PRTSC}")
$image = [System.Windows.Forms.Clipboard]::GetImage()
$image.Save("$screenshotFolder\$computerName.png", [System.Drawing.Imaging.ImageFormat]::Png)

#Obtenha o PID da janela do script
$pid = (Get-Process -Name powershell).Id

#Fechando janela específica via PID após salvar o screenshot
Stop-Process -Id $pid
