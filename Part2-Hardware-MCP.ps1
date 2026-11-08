# =====================================
# LocalAI Hub - Parte 2
# Hardware, MCP e Extensoes
# =====================================

function Add-LogSafe {

param([string]$Text)

if($txtLog)
{
    $time = Get-Date -Format "HH:mm:ss"
    $txtLog.AppendText("[$time] $Text`r`n")
    $txtLog.ScrollToEnd()
}

}

function Get-GPUInfo {

try {

$gpu = Get-CimInstance Win32_VideoController |
Select-Object -First 1

return $gpu.Name

}
catch {

return "GPU nao detectada"

}

}

function Update-HardwareInfo {

try {

$cpuObj = Get-CimInstance Win32_Processor

$cpuName = $cpuObj.Name

$gpuName = Get-GPUInfo

$ram = Get-CimInstance Win32_ComputerSystem

$totalRam = [Math]::Round(
$ram.TotalPhysicalMemory / 1GB,2
)

Add-LogSafe "CPU: $cpuName"
Add-LogSafe "GPU: $gpuName"
Add-LogSafe "RAM: $totalRam GB"

}
catch {

Add-LogSafe $_.Exception.Message

}

}

function Detect-MCPs {

$Global:MCPs = @()

$mcpFolder = Join-Path $PSScriptRoot "mcps"

if(!(Test-Path $mcpFolder))
{
    New-Item -ItemType Directory `
    -Path $mcpFolder | Out-Null
}

Get-ChildItem $mcpFolder -Directory |
ForEach-Object {

$Global:MCPs += $_.Name

}

Add-LogSafe "MCPs encontrados: $($Global:MCPs.Count)"

}

function Install-MCP {

param(
[string]$Name
)

$mcpFolder = Join-Path $PSScriptRoot "mcps"

$newFolder = Join-Path $mcpFolder $Name

if(!(Test-Path $newFolder))
{
    New-Item `
    -ItemType Directory `
    -Path $newFolder | Out-Null

    Add-LogSafe "MCP instalado: $Name"
}
else
{
    Add-LogSafe "MCP ja existe: $Name"
}

}

function List-MCPs {

Add-LogSafe "====== MCPs ======"

foreach($mcp in $Global:MCPs)
{
    Add-LogSafe "$mcp"
}

}

function Detect-Extensions {

$Global:Extensions = @()

$extFolder = Join-Path `
$PSScriptRoot `
"extensions"

if(!(Test-Path $extFolder))
{
    New-Item `
    -ItemType Directory `
    -Path $extFolder | Out-Null
}

Get-ChildItem $extFolder `
-Directory |
ForEach-Object {

$Global:Extensions += $_.Name

}

Add-LogSafe `
"Extensoes encontradas: $($Global:Extensions.Count)"

}

function Install-Extension {

param(
[string]$Name
)

$extFolder = Join-Path `
$PSScriptRoot `
"extensions\$Name"

if(!(Test-Path $extFolder))
{
    New-Item `
    -ItemType Directory `
    -Path $extFolder | Out-Null

    Add-LogSafe "Extensao instalada: $Name"
}
else
{
    Add-LogSafe "Extensao existente: $Name"
}

}

function List-Extensions {

Add-LogSafe "====== EXTENSOES ======"

foreach($ext in $Global:Extensions)
{
    Add-LogSafe "$ext"
}

}

function Run-SystemDiagnostics {

Add-LogSafe ""
Add-LogSafe "===== Diagnostico ====="

Update-HardwareInfo

Detect-MCPs

Detect-Extensions

Add-LogSafe "======================="

}

function Create-ProjectFolders {

$folders = @(
"mcps",
"extensions",
"models",
"projects",
"logs",
"themes"
)

foreach($folder in $folders)
{

$path = Join-Path `
$PSScriptRoot `
$folder

if(!(Test-Path $path))
{
    New-Item `
    -ItemType Directory `
    -Path $path | Out-Null

    Add-LogSafe "Criado: $folder"
}

}

}

Create-ProjectFolders
Detect-MCPs
Detect-Extensions
