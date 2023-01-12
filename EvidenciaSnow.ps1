$folder = "C:\Program Files\Snow\Snow Agent"
$screenshotFolder = "C:\screenshots"
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

#Executa dois comandos como administrador
Start-Process PowerShell -Verb RunAs -ArgumentList "-Command &{snowagent.exe scan; snowagent.exe send}"

#Efetua screenshot da tela inteira e salva na pasta especificada com o nome do computador
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{PRTSC}")
$image = [System.Windows.Forms.Clipboard]::GetImage()
$image.Save("$screenshotFolder\$computerName.png", [System.Drawing.Imaging.ImageFormat]::Png)

#Obtenha o PID da janela do script
$pid = (Get-Process -Name powershell).Id

#Fechando janela específica via PID após salvar o screenshot
Stop-Process -Id $pid
