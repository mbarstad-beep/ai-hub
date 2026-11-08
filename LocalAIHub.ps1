. "$PSScriptRoot\Part2-Hardware-MCP.ps1"
. "$PSScriptRoot\Part3-Tools.ps1"
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$XAML = @"
<Window
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="LocalAI Hub"
Height="700"
Width="1000"
WindowStartupLocation="CenterScreen"
Background="#202020"
Foreground="White">

<Grid Margin="10">

<Grid.RowDefinitions>
<RowDefinition Height="Auto"/>
<RowDefinition Height="Auto"/>
<RowDefinition Height="*"/>
<RowDefinition Height="Auto"/>
</Grid.RowDefinitions>

<TextBlock
Grid.Row="0"
Text="LocalAI Hub"
FontSize="28"
FontWeight="Bold"
Margin="0,0,0,10"/>

<ProgressBar
Grid.Row="1"
Name="pbMain"
Height="25"
Maximum="100"
Value="0"/>

<Grid Grid.Row="2">

<Grid.ColumnDefinitions>
<ColumnDefinition Width="250"/>
<ColumnDefinition Width="*"/>
</Grid.ColumnDefinitions>

<StackPanel Grid.Column="0" Margin="5">

<Button
Name="btnScan"
Content="Escanear Sistema"
Height="40"
Margin="0,0,0,5"/>

<Button
Name="btnRefresh"
Content="Atualizar"
Height="40"
Margin="0,0,0,5"/>

<Button
Name="btnConsole"
Content="Abrir Console"
Height="40"
Margin="0,0,0,5"/>

<Button
Name="btnExport"
Content="Exportar Logs"
Height="40"
Margin="0,0,0,5"/>

<GroupBox Header="Sistema" Margin="0,10,0,0">

<StackPanel>

<TextBlock Name="txtCPU"/>
<TextBlock Name="txtRAM"/>
<TextBlock Name="txtOS"/>
<TextBlock Name="txtUser"/>

</StackPanel>

</GroupBox>

</StackPanel>

<TabControl Grid.Column="1" Margin="5">

<TabItem Header="IAs">
<ListBox Name="lstAI"/>
</TabItem>

<TabItem Header="Dependencias">
<ListBox Name="lstDeps"/>
</TabItem>

<TabItem Header="Logs">
<TextBox
Name="txtLog"
Background="Black"
Foreground="Lime"
FontFamily="Consolas"
AcceptsReturn="True"
VerticalScrollBarVisibility="Auto"/>
</TabItem>

</TabControl>

</Grid>

<TextBlock
Grid.Row="3"
Text="LocalAI Hub v1"
HorizontalAlignment="Center"
Margin="0,10,0,0"/>

</Grid>
</Window>
"@

$Reader = New-Object System.Xml.XmlNodeReader $XAML
$Window = [Windows.Markup.XamlReader]::Load($Reader)

$btnScan = $Window.FindName("btnScan")
$btnRefresh = $Window.FindName("btnRefresh")
$btnConsole = $Window.FindName("btnConsole")
$btnExport = $Window.FindName("btnExport")

$lstAI = $Window.FindName("lstAI")
$lstDeps = $Window.FindName("lstDeps")
$txtLog = $Window.FindName("txtLog")

$txtCPU = $Window.FindName("txtCPU")
$txtRAM = $Window.FindName("txtRAM")
$txtOS = $Window.FindName("txtOS")
$txtUser = $Window.FindName("txtUser")

$pbMain = $Window.FindName("pbMain")

function Add-Log {

param([string]$Texto)

$Hora = Get-Date -Format "HH:mm:ss"

$txtLog.AppendText("[$Hora] $Texto`r`n")
$txtLog.ScrollToEnd()

}

function Atualizar-Sistema {

try {

$OS = Get-CimInstance Win32_OperatingSystem

$txtOS.Text = "Sistema: " + $OS.Caption
$txtUser.Text = "Usuario: " + $env:USERNAME

$CPU = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples[0].CookedValue
$CPU = :Round($CPU,0)

$txtCPU.Text = "CPU: $CPU %"

$TotalRAM = :Round($OS.TotalVisibleMemorySize / 1024 / 1024,2)
$LivreRAM = :Round($OS.FreePhysicalMemory / 1024 / 1024,2)
$UsadaRAM = :Round($TotalRAM - $LivreRAM,2)

$txtRAM.Text = "RAM: $UsadaRAM GB / $TotalRAM GB"

}
catch {

Add-Log $_.Exception.Message

}

}

function Detectar-IAs {

$lstAI.Items.Clear()

if(Get-Command ollama -ErrorAction SilentlyContinue){
    $lstAI.Items.Add("Ollama")
    Add-Log "Ollama encontrado"
}
else{
    $lstAI.Items.Add("Ollama nao encontrado")
}

if(Test-Path "$env:LOCALAPPDATA\Programs\LM Studio"){
    $lstAI.Items.Add("LM Studio")
    Add-Log "LM Studio encontrado"
}
else{
    $lstAI.Items.Add("LM Studio nao encontrado")
}

if(Test-Path "$env:LOCALAPPDATA\Programs\Jan"){
    $lstAI.Items.Add("Jan AI")
    Add-Log "Jan AI encontrado"
}
else{
    $lstAI.Items.Add("Jan AI nao encontrado")
}

}

function Detectar-Dependencias {

$lstDeps.Items.Clear()

if(Get-Command python -ErrorAction SilentlyContinue){
    $lstDeps.Items.Add("Python")
}
else{
    $lstDeps.Items.Add("Python ausente")
}

if(Get-Command git -ErrorAction SilentlyContinue){
    $lstDeps.Items.Add("Git")
}
else{
    $lstDeps.Items.Add("Git ausente")
}

if(Get-Command node -ErrorAction SilentlyContinue){
    $lstDeps.Items.Add("NodeJS")
}
else{
    $lstDeps.Items.Add("NodeJS ausente")
}

if(Get-Command docker -ErrorAction SilentlyContinue){
    $lstDeps.Items.Add("Docker")
}
else{
    $lstDeps.Items.Add("Docker ausente")
}

}

$btnScan.Add_Click({

Add-Log "Iniciando escaneamento"

for($i=0;$i -le 100;$i+=10){

$pbMain.Value = $i
Start-Sleep -Milliseconds 50

}

Detectar-IAs
Detectar-Dependencias

Add-Log "Escaneamento concluido"

})

$btnRefresh.Add_Click({

Atualizar-Sistema
Add-Log "Sistema atualizado"

})

$btnConsole.Add_Click({

Start-Process powershell

})

$btnExport.Add_Click({

$Arquivo = "$env:USERPROFILE\Desktop\LocalAIHub.log"

$txtLog.Text | Set-Content $Arquivo

Add-Log "Logs exportados"

[System.Windows.MessageBox]::Show(
"Logs exportados para:`n$Arquivo"
)

})

Atualizar-Sistema
Detectar-IAs
Detectar-Dependencias

Add-Log "LocalAI Hub iniciado"
$btnDino.Add_Click({
    Start-DinoGame
})

$btnOpenWebUI.Add_Click({
    Test-OpenWebUI
})

$btnTerminal.Add_Click({
    Open-AITerminal
})

$btnDiag.Add_Click({
    Run-AdvancedDiagnostics
})
$null = $Window.ShowDialog()
