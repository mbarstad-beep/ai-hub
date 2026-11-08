# ====================================
# LocalAI Hub - Parte 3
# Ferramentas Extras
# ====================================

function Add-LogSafe {

param([string]$Text)

if($txtLog)
{
    $time = Get-Date -Format "HH:mm:ss"

    $txtLog.AppendText(
        "[$time] $Text`r`n"
    )

    $txtLog.ScrollToEnd()
}

}

# ====================================
# OPEN WEBUI
# ====================================

function Find-OpenWebUI {

$paths = @(
"$env:USERPROFILE\AppData\Local\Programs",
"C:\Program Files",
"C:\Program Files (x86)"
)

foreach($path in $paths)
{
    try {

        $result =
        Get-ChildItem $path `
        -Directory `
        -Recurse `
        -ErrorAction SilentlyContinue |
        Where-Object {

            $_.Name -match "open.?webui"

        } |
        Select-Object -First 1

        if($result)
        {
            return $result.FullName
        }

    }
    catch{}
}

return $null

}

function Test-OpenWebUI {

$path = Find-OpenWebUI

if($path)
{
    Add-LogSafe "Open WebUI encontrado"
    Add-LogSafe $path
}
else
{
    Add-LogSafe "Open WebUI nao encontrado"
}

}

# ====================================
# TEMA PROFISSIONAL
# ====================================

function Create-ThemeFolder {

$themeFolder =
Join-Path $PSScriptRoot "themes"

if(!(Test-Path $themeFolder))
{
    New-Item `
    -ItemType Directory `
    -Path $themeFolder |
    Out-Null
}

}

function Create-ProTheme {

Create-ThemeFolder

$css = @"

body{
background:#111827;
color:white;
}

.card{
background:#1F2937;
border-radius:10px;
}

.sidebar{
background:#0F172A;
}

"@

$css |
Set-Content `
"$PSScriptRoot\themes\Professional.css"

Add-LogSafe "Tema Professional criado"

}

# ====================================
# TERMINAL IA
# ====================================

function Open-AITerminal {

Add-LogSafe "Abrindo terminal"

Start-Process powershell

}

# ====================================
# DINO GAME
# ====================================

function Start-DinoGame {

Add-Type -AssemblyName System.Windows.Forms

$form =
New-Object System.Windows.Forms.Form

$form.Text = "Dino"

$form.Width = 800
$form.Height = 250

$label =
New-Object System.Windows.Forms.Label

$label.Dock = "Fill"

$label.Font =
New-Object Drawing.Font(
"Consolas",
20
)

$form.Controls.Add($label)

$global:dinoPos = 0
$global:score = 0

$timer =
New-Object System.Windows.Forms.Timer

$timer.Interval = 100

$timer.Add_Tick({

$global:dinoPos++
$global:score++

$gap =
20 - ($global:dinoPos % 20)

$line =
"🦖" +
(" " * $gap) +
"🌵"

$label.Text =
"$line`r`n`r`nScore: $global:score"

})

$timer.Start()

$form.ShowDialog()

}

# ====================================
# DIAGNOSTICO
# ====================================

function Run-AdvancedDiagnostics {

Add-LogSafe ""
Add-LogSafe "==== RELATORIO ===="

try {

$os =
Get-CimInstance `
Win32_OperatingSystem

Add-LogSafe $os.Caption

}
catch{}

try {

$cpu =
Get-CimInstance `
Win32_Processor

Add-LogSafe $cpu.Name

}
catch{}

try {

$gpu =
Get-CimInstance `
Win32_VideoController |
Select-Object -First 1

Add-LogSafe $gpu.Name

}
catch{}

Test-OpenWebUI

Add-LogSafe "==================="

}

# ====================================
# DASHBOARD JSON
# ====================================

function Export-SystemReport {

$report = [PSCustomObject]@{

Date = Get-Date

User = $env:USERNAME

Computer = $env:COMPUTERNAME

MCPs =
(Get-ChildItem `
"$PSScriptRoot\mcps" `
-Directory `
-ErrorAction SilentlyContinue).Count

Extensions =
(Get-ChildItem `
"$PSScriptRoot\extensions" `
-Directory `
-ErrorAction SilentlyContinue).Count

}

$report |
ConvertTo-Json |
Set-Content `
"$PSScriptRoot\report.json"

Add-LogSafe "Relatorio salvo"

}

Create-ProTheme
