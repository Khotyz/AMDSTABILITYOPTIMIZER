<#
.SYNOPSIS
    Modern WPF Graphical Interface to optimize Windows/AMD Radeon stability.
.DESCRIPTION
    Modular, dark-themed Windows 11 style UI with ULPS, MPO, TDR and Fast Startup
    optimizations for AMD RDNA2 GPUs. Auto-elevates to Admin, backs up affected
    registry keys (and attempts a System Restore Point) before any change, and
    supports en-US, pt-BR, es-ES and zh-CN with automatic OS-language detection.
.NOTES
    Requires: Windows, PowerShell 5.1+, Administrator privileges.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==========================================
# 1. AUTO ADMIN ELEVATION
# ==========================================
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdministrator) {
    if ($PSCommandPath) {
        # Local file execution: relaunch the same file elevated
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        # Online execution (iwr | iex): there is no local file to relaunch, so
        # the elevated process must re-download and re-run the full script from
        # its source URL. Re-running just "[Console]::OutputEncoding=..." here
        # silently discarded the entire tool instead of launching it.
        $scriptUrl = "https://raw.githubusercontent.com/Khotyz/AMDSTABILITYOPTIMIZER/main/AMD-Stability-Optimizer.ps1"
        $elevatedCommand = "iwr -useb '$scriptUrl' | iex"
        $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($elevatedCommand))
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand $encodedCommand" -Verb RunAs
    }
    exit
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# ==========================================
# 2. LOCALIZATION DICTIONARY (encoding-safe: every non-ASCII
#    character is built from its Unicode code point via [char],
#    so the visible text never depends on how this .ps1 file
#    itself is saved/read/encoded)
# ==========================================
$script:Messages = @{
    'en-US' = @{
        'AppTitle'          = "AMD STABILITY OPTIMIZER"
        'AppSubtitle'       = "RDNA2 Reliability Toolkit for AMD Radeon Graphics"
        'AdminBadge'        = "Running as Administrator"
        'StatusApplied'     = "Applied"
        'StatusNotApplied'  = "Not Applied"
        'StatusUnavailable' = "Not Available"
        'BtnApply'          = "Apply"
        'BtnRevert'         = "Revert"
        'ULPSTitle'         = "ULPS - Ultra Low Power State"
        'ULPSDesc'          = "Prevents the GPU from entering an unstable low-power state on multi-GPU or hybrid setups."
        'MPOTitle'          = "MPO - Multi-Plane Overlay"
        'MPODesc'           = "Disables Multi-Plane Overlay, fixing flickering and black-screen issues in some games and apps."
        'TDRTitle'          = "TDR Delay"
        'TDRDesc'           = "Extends the driver timeout before Windows resets a GPU that seems unresponsive."
        'FSTitle'           = "Fast Startup & Hibernation"
        'FSDesc'            = "Disables Fast Startup and Hibernation, avoiding driver state corruption after shutdown."
        'BtnApplyAll'       = "Apply All Fixes"
        'BtnRevertAll'      = "Revert All (Restore Defaults)"
        'BtnCloseWin'       = "Close"
        'FooterReady'       = "Ready."
        'FooterBackingUp'   = "Backing up registry keys..."
        'FooterBackupOk'    = "Backup saved to {0}."
        'FooterBackupWarn'  = "Backup completed with warnings."
        'FooterRestorePointOk'   = "System Restore Point created."
        'FooterRestorePointWarn' = "Could not create a Restore Point (System Protection may be off). Registry backup only."
        'FooterApplyingAll' = "Applying all fixes..."
        'FooterApplyAllDone'= "All fixes applied. A restart is recommended."
        'FooterRevertingAll'= "Reverting all changes..."
        'FooterRevertAllDone' = "All changes reverted to Windows defaults. A restart is recommended."
        'FooterModuleApplied'  = "{0} applied successfully."
        'FooterModuleReverted' = "{0} reverted to default."
        'FooterModuleFailed'   = "Failed to change {0}."
        'FooterRestartPrompt'  = "Restart now to apply all changes?"
        'BtnRestartNow'     = "Restart Now"
        'BtnLater'          = "Later"
    }
    'pt-BR' = @{
        'AppTitle'          = "OTIMIZADOR DE ESTABILIDADE AMD"
        'AppSubtitle'       = "Kit de Confiabilidade RDNA2 para GPUs AMD Radeon"
        'AdminBadge'        = "Executando como Administrador"
        'StatusApplied'     = "Aplicado"
        'StatusNotApplied'  = "N" + [char]0x00E3 + "o Aplicado"
        'StatusUnavailable' = "Indispon" + [char]0x00ED + "vel"
        'BtnApply'          = "Aplicar"
        'BtnRevert'         = "Reverter"
        'ULPSTitle'         = "ULPS - Ultra Low Power State"
        'ULPSDesc'          = "Evita que a GPU entre em um estado de baixa energia inst" + [char]0x00E1 + "vel em configura" + [char]0x00E7 + [char]0x00F5 + "es multi-GPU ou h" + [char]0x00ED + "bridas."
        'MPOTitle'          = "MPO - Multi-Plane Overlay"
        'MPODesc'           = "Desativa o Multi-Plane Overlay, corrigindo telas pretas e piscadas em alguns jogos e aplicativos."
        'TDRTitle'          = "TDR Delay"
        'TDRDesc'           = "Aumenta o tempo limite do driver antes que o Windows reinicie uma GPU que parece travada."
        'FSTitle'           = "Fast Startup e Hiberna" + [char]0x00E7 + [char]0x00E3 + "o"
        'FSDesc'            = "Desativa o Fast Startup e a Hiberna" + [char]0x00E7 + [char]0x00E3 + "o, evitando corrup" + [char]0x00E7 + [char]0x00E3 + "o do estado do driver ap" + [char]0x00F3 + "s desligar."
        'BtnApplyAll'       = "Aplicar Todas as Corre" + [char]0x00E7 + [char]0x00F5 + "es"
        'BtnRevertAll'      = "Reverter Tudo (Restaurar Padr" + [char]0x00E3 + "o)"
        'BtnCloseWin'       = "Fechar"
        'FooterReady'       = "Pronto."
        'FooterBackingUp'   = "Fazendo backup das chaves de registro..."
        'FooterBackupOk'    = "Backup salvo em {0}."
        'FooterBackupWarn'  = "Backup conclu" + [char]0x00ED + "do com avisos."
        'FooterRestorePointOk'   = "Ponto de Restaura" + [char]0x00E7 + [char]0x00E3 + "o criado."
        'FooterRestorePointWarn' = "N" + [char]0x00E3 + "o foi poss" + [char]0x00ED + "vel criar o Ponto de Restaura" + [char]0x00E7 + [char]0x00E3 + "o (Prote" + [char]0x00E7 + [char]0x00E3 + "o do Sistema pode estar desativada). Apenas backup do registro."
        'FooterApplyingAll' = "Aplicando todas as corre" + [char]0x00E7 + [char]0x00F5 + "es..."
        'FooterApplyAllDone'= "Todas as corre" + [char]0x00E7 + [char]0x00F5 + "es foram aplicadas. Reiniciar " + [char]0x00E9 + " recomendado."
        'FooterRevertingAll'= "Revertendo todas as altera" + [char]0x00E7 + [char]0x00F5 + "es..."
        'FooterRevertAllDone' = "Todas as altera" + [char]0x00E7 + [char]0x00F5 + "es foram revertidas para o padr" + [char]0x00E3 + "o. Reiniciar " + [char]0x00E9 + " recomendado."
        'FooterModuleApplied'  = "{0} aplicado com sucesso."
        'FooterModuleReverted' = "{0} revertido ao padr" + [char]0x00E3 + "o."
        'FooterModuleFailed'   = "Falha ao alterar {0}."
        'FooterRestartPrompt'  = "Reiniciar agora para aplicar todas as altera" + [char]0x00E7 + [char]0x00F5 + "es?"
        'BtnRestartNow'     = "Reiniciar Agora"
        'BtnLater'          = "Depois"
    }
    'es-ES' = @{
        'AppTitle'          = "OPTIMIZADOR DE ESTABILIDAD AMD"
        'AppSubtitle'       = "Kit de Fiabilidad RDNA2 para GPUs AMD Radeon"
        'AdminBadge'        = "Ejecutando como Administrador"
        'StatusApplied'     = "Aplicado"
        'StatusNotApplied'  = "No Aplicado"
        'StatusUnavailable' = "No Disponible"
        'BtnApply'          = "Aplicar"
        'BtnRevert'         = "Revertir"
        'ULPSTitle'         = "ULPS - Ultra Low Power State"
        'ULPSDesc'          = "Evita que la GPU entre en un estado de bajo consumo inestable en configuraciones multi-GPU o h" + [char]0x00ED + "bridas."
        'MPOTitle'          = "MPO - Multi-Plane Overlay"
        'MPODesc'           = "Desactiva el Multi-Plane Overlay, corrigiendo parpadeos y pantallas negras en algunos juegos y apps."
        'TDRTitle'          = "TDR Delay"
        'TDRDesc'           = "Aumenta el tiempo de espera del controlador antes de que Windows reinicie una GPU que parece bloqueada."
        'FSTitle'           = "Fast Startup e Hibernaci" + [char]0x00F3 + "n"
        'FSDesc'            = "Desactiva Fast Startup e Hibernaci" + [char]0x00F3 + "n, evitando la corrupci" + [char]0x00F3 + "n del estado del controlador tras apagar."
        'BtnApplyAll'       = "Aplicar Todas las Correcciones"
        'BtnRevertAll'      = "Revertir Todo (Restaurar Predeterminados)"
        'BtnCloseWin'       = "Cerrar"
        'FooterReady'       = "Listo."
        'FooterBackingUp'   = "Realizando copia de seguridad del registro..."
        'FooterBackupOk'    = "Copia de seguridad guardada en {0}."
        'FooterBackupWarn'  = "Copia de seguridad completada con advertencias."
        'FooterRestorePointOk'   = "Punto de Restauraci" + [char]0x00F3 + "n creado."
        'FooterRestorePointWarn' = "No se pudo crear el Punto de Restauraci" + [char]0x00F3 + "n (la Protecci" + [char]0x00F3 + "n del Sistema puede estar desactivada). Solo copia de registro."
        'FooterApplyingAll' = "Aplicando todas las correcciones..."
        'FooterApplyAllDone'= "Se aplicaron todas las correcciones. Se recomienda reiniciar."
        'FooterRevertingAll'= "Revirtiendo todos los cambios..."
        'FooterRevertAllDone' = "Todos los cambios se revirtieron a los valores predeterminados. Se recomienda reiniciar."
        'FooterModuleApplied'  = "{0} aplicado con " + [char]0x00E9 + "xito."
        'FooterModuleReverted' = "{0} revertido al valor predeterminado."
        'FooterModuleFailed'   = "Fall" + [char]0x00F3 + " al cambiar {0}."
        'FooterRestartPrompt'  = [char]0x00BF + "Reiniciar ahora para aplicar todos los cambios?"
        'BtnRestartNow'     = "Reiniciar Ahora"
        'BtnLater'          = "M" + [char]0x00E1 + "s Tarde"
    }
    'zh-CN' = @{
        # Every Chinese string is built from verified Unicode code points so the
        # visible text never depends on the source file's byte encoding.
        'AppTitle'          = "AMD " + [char]0x7A33 + [char]0x5B9A + [char]0x6027 + [char]0x4F18 + [char]0x5316 + [char]0x5DE5 + [char]0x5177
        'AppSubtitle'       = [char]0x9002 + [char]0x7528 + [char]0x4E8E + " AMD Radeon " + [char]0x663E + [char]0x5361 + [char]0x7684 + " RDNA2 " + [char]0x53EF + [char]0x9760 + [char]0x6027 + [char]0x5DE5 + [char]0x5177 + [char]0x5305
        'AdminBadge'        = [char]0x6B63 + [char]0x5728 + [char]0x4EE5 + [char]0x7BA1 + [char]0x7406 + [char]0x5458 + [char]0x8EAB + [char]0x4EFD + [char]0x8FD0 + [char]0x884C
        'StatusApplied'     = [char]0x5DF2 + [char]0x5E94 + [char]0x7528
        'StatusNotApplied'  = [char]0x672A + [char]0x5E94 + [char]0x7528
        'StatusUnavailable' = [char]0x4E0D + [char]0x53EF + [char]0x7528
        'BtnApply'          = [char]0x5E94 + [char]0x7528
        'BtnRevert'         = [char]0x6062 + [char]0x590D
        'ULPSTitle'         = "ULPS - Ultra Low Power State"
        'ULPSDesc'          = [char]0x9632 + [char]0x6B62 + [char]0x663E + [char]0x5361 + [char]0x5728 + [char]0x591A + [char]0x663E + [char]0x5361 + [char]0x6216 + [char]0x6DF7 + [char]0x5408 + [char]0x914D + [char]0x7F6E + [char]0x4E2D + [char]0x8FDB + [char]0x5165 + [char]0x4E0D + [char]0x7A33 + [char]0x5B9A + [char]0x7684 + [char]0x4F4E + [char]0x529F + [char]0x8017 + [char]0x72B6 + [char]0x6001 + [char]0x3002
        'MPOTitle'          = "MPO - Multi-Plane Overlay"
        'MPODesc'           = [char]0x7981 + [char]0x7528 + [char]0x591A + [char]0x5C42 + [char]0x53E0 + [char]0x52A0 + [char]0xFF0C + [char]0x4FEE + [char]0x590D + [char]0x90E8 + [char]0x5206 + [char]0x6E38 + [char]0x620F + [char]0x548C + [char]0x5E94 + [char]0x7528 + [char]0x4E2D + [char]0x7684 + [char]0x95EA + [char]0x70C1 + [char]0x548C + [char]0x9ED1 + [char]0x5C4F + [char]0x95EE + [char]0x9898 + [char]0x3002
        'TDRTitle'          = "TDR Delay"
        'TDRDesc'           = [char]0x5EF6 + [char]0x957F + [char]0x9A71 + [char]0x52A8 + [char]0x8D85 + [char]0x65F6 + [char]0x65F6 + [char]0x95F4 + [char]0xFF0C + [char]0x907F + [char]0x514D + " Windows " + [char]0x8FC7 + [char]0x65E9 + [char]0x91CD + [char]0x7F6E + [char]0x770B + [char]0x4F3C + [char]0x65E0 + [char]0x54CD + [char]0x5E94 + [char]0x7684 + [char]0x663E + [char]0x5361 + [char]0x3002
        'FSTitle'           = "Fast Startup " + [char]0x4E0E + [char]0x4F11 + [char]0x7720
        'FSDesc'            = [char]0x7981 + [char]0x7528 + " Fast Startup " + [char]0x548C + [char]0x4F11 + [char]0x7720 + [char]0xFF0C + [char]0x907F + [char]0x514D + [char]0x5173 + [char]0x673A + [char]0x540E + [char]0x9A71 + [char]0x52A8 + [char]0x72B6 + [char]0x6001 + [char]0x635F + [char]0x574F + [char]0x3002
        'BtnApplyAll'       = [char]0x5E94 + [char]0x7528 + [char]0x6240 + [char]0x6709 + [char]0x4FEE + [char]0x590D
        'BtnRevertAll'      = [char]0x6062 + [char]0x590D + [char]0x5168 + [char]0x90E8 + "(" + [char]0x6062 + [char]0x590D + [char]0x9ED8 + [char]0x8BA4 + [char]0x503C + ")"
        'BtnCloseWin'       = [char]0x5173 + [char]0x95ED
        'FooterReady'       = [char]0x5C31 + [char]0x7EEA + [char]0x3002
        'FooterBackingUp'   = [char]0x6B63 + [char]0x5728 + [char]0x5907 + [char]0x4EFD + [char]0x6CE8 + [char]0x518C + [char]0x8868 + [char]0x9879 + "..."
        'FooterBackupOk'    = [char]0x5907 + [char]0x4EFD + [char]0x5DF2 + [char]0x4FDD + [char]0x5B58 + [char]0x81F3 + " {0}" + [char]0x3002
        'FooterBackupWarn'  = [char]0x5907 + [char]0x4EFD + [char]0x5B8C + [char]0x6210 + [char]0xFF0C + [char]0x4F46 + [char]0x6709 + [char]0x8B66 + [char]0x544A + [char]0x3002
        'FooterRestorePointOk'   = [char]0x7CFB + [char]0x7EDF + [char]0x8FD8 + [char]0x539F + [char]0x70B9 + [char]0x5DF2 + [char]0x521B + [char]0x5EFA + [char]0x3002
        'FooterRestorePointWarn' = [char]0x65E0 + [char]0x6CD5 + [char]0x521B + [char]0x5EFA + [char]0x8FD8 + [char]0x539F + [char]0x70B9 + "(" + [char]0x7CFB + [char]0x7EDF + [char]0x4FDD + [char]0x62A4 + [char]0x53EF + [char]0x80FD + [char]0x5DF2 + [char]0x7981 + [char]0x7528 + ")" + [char]0x3002 + [char]0x4EC5 + [char]0x4F7F + [char]0x7528 + [char]0x6CE8 + [char]0x518C + [char]0x8868 + [char]0x5907 + [char]0x4EFD + [char]0x3002
        'FooterApplyingAll' = [char]0x6B63 + [char]0x5728 + [char]0x5E94 + [char]0x7528 + [char]0x6240 + [char]0x6709 + [char]0x4FEE + [char]0x590D + "..."
        'FooterApplyAllDone'= [char]0x6240 + [char]0x6709 + [char]0x4FEE + [char]0x590D + [char]0x5DF2 + [char]0x5E94 + [char]0x7528 + [char]0x3002 + [char]0x5EFA + [char]0x8BAE + [char]0x91CD + [char]0x542F + [char]0x3002
        'FooterRevertingAll'= [char]0x6B63 + [char]0x5728 + [char]0x6062 + [char]0x590D + [char]0x6240 + [char]0x6709 + [char]0x66F4 + [char]0x6539 + "..."
        'FooterRevertAllDone' = [char]0x6240 + [char]0x6709 + [char]0x66F4 + [char]0x6539 + [char]0x5DF2 + [char]0x6062 + [char]0x590D + [char]0x4E3A + [char]0x9ED8 + [char]0x8BA4 + [char]0x503C + [char]0x3002 + [char]0x5EFA + [char]0x8BAE + [char]0x91CD + [char]0x542F + [char]0x3002
        'FooterModuleApplied'  = "{0} " + [char]0x5DF2 + [char]0x6210 + [char]0x529F + [char]0x5E94 + [char]0x7528 + [char]0x3002
        'FooterModuleReverted' = "{0} " + [char]0x5DF2 + [char]0x6062 + [char]0x590D + [char]0x4E3A + [char]0x9ED8 + [char]0x8BA4 + [char]0x503C + [char]0x3002
        'FooterModuleFailed'   = [char]0x66F4 + [char]0x6539 + " {0} " + [char]0x5931 + [char]0x8D25 + [char]0x3002
        'FooterRestartPrompt'  = [char]0x662F + [char]0x5426 + [char]0x73B0 + [char]0x5728 + [char]0x91CD + [char]0x542F + [char]0x4EE5 + [char]0x5E94 + [char]0x7528 + [char]0x6240 + [char]0x6709 + [char]0x66F4 + [char]0x6539 + [char]0xFF1F
        'BtnRestartNow'     = [char]0x7ACB + [char]0x5373 + [char]0x91CD + [char]0x542F
        'BtnLater'          = [char]0x7A0D + [char]0x540E
    }
}

$script:LangNameEN = "English"
$script:LangNamePT = "Portugu" + [char]0x00EA + "s"
$script:LangNameES = "Espa" + [char]0x00F1 + "ol"
$script:LangNameZH = [char]0x4E2D + [char]0x6587

# ==========================================
# 3. AUTOMATIC LANGUAGE DETECTION
# ==========================================
function Get-PreferredLanguageTag {
    try {
        $cultureName = [System.Globalization.CultureInfo]::CurrentCulture.Name
    } catch {
        $cultureName = "en-US"
    }
    switch -Wildcard ($cultureName) {
        "pt*" { return "pt-BR" }
        "es*" { return "es-ES" }
        "zh*" { return "zh-CN" }
        default { return "en-US" }
    }
}

$script:CurrentLang = Get-PreferredLanguageTag
if (-not $script:Messages.ContainsKey($script:CurrentLang)) {
    $script:CurrentLang = "en-US"
}

function Get-Str {
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [object[]]$FormatArgs
    )
    $dict = $script:Messages[$script:CurrentLang]
    if (-not $dict.ContainsKey($Key)) { $dict = $script:Messages['en-US'] }
    $text = $dict[$Key]
    if ($FormatArgs -and $FormatArgs.Count -gt 0) { return ($text -f $FormatArgs) }
    return $text
}

# ==========================================
# 4. REGISTRY HELPERS
# ==========================================
$script:UlpsBasePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
$script:DwmPath      = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
$script:GfxPath      = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
$script:PowerPath    = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$script:BackupRoot   = Join-Path $env:ProgramData "AMD-Stability-Optimizer\Backups"

function Get-UlpsEntries {
    Get-ChildItem -Path $script:UlpsBasePath -Recurse -ErrorAction SilentlyContinue |
        Get-ItemProperty -Name "EnableUlps" -ErrorAction SilentlyContinue
}

function New-SafetyBackup {
    $result = @{ Success = $true; Path = $null }
    try {
        $freqPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
        if (-not (Test-Path $freqPath)) { New-Item -Path $freqPath -Force | Out-Null }
        Set-ItemProperty -Path $freqPath -Name "SystemRestorePointCreationFrequency" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "AMD Stability Optimizer" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        $result.RestorePoint = $true
    } catch {
        $result.RestorePoint = $false
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = Join-Path $script:BackupRoot $timestamp
    try {
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        $targets = @(
            @{ Path = "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"; File = "ULPS.reg" },
            @{ Path = "HKLM\SOFTWARE\Microsoft\Windows\Dwm"; File = "MPO.reg" },
            @{ Path = "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"; File = "TDR.reg" },
            @{ Path = "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power"; File = "FastStartup.reg" }
        )
        foreach ($target in $targets) {
            $outFile = Join-Path $backupDir $target.File
            reg.exe export "$($target.Path)" "$outFile" /y 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) { $result.Success = $false }
        }
        $result.Path = $backupDir
    } catch {
        $result.Success = $false
    }
    return $result
}

# ==========================================
# 5. MODULE LOGIC: ULPS / MPO / TDR / FAST STARTUP
# ==========================================
function Get-UlpsState {
    $entries = Get-UlpsEntries
    if (-not $entries) { return 'unavailable' }
    $stillActive = $entries | Where-Object { $_.EnableUlps -ne 0 }
    if ($stillActive) { return 'notapplied' } else { return 'applied' }
}

function Set-UlpsState {
    param([bool]$Revert)
    $entries = Get-UlpsEntries
    if (-not $entries) { return $false }
    $targetValue = if ($Revert) { 1 } else { 0 }
    $ok = $true
    foreach ($entry in $entries) {
        try {
            Set-ItemProperty -Path $entry.PSPath -Name "EnableUlps" -Value $targetValue -ErrorAction Stop
            if (Get-ItemProperty -Path $entry.PSPath -Name "EnableUlps_NA" -ErrorAction SilentlyContinue) {
                Set-ItemProperty -Path $entry.PSPath -Name "EnableUlps_NA" -Value $targetValue -ErrorAction Stop
            }
        } catch { $ok = $false }
    }
    return $ok
}

function Get-MpoState {
    if (-not (Test-Path $script:DwmPath)) { return 'notapplied' }
    $val = (Get-ItemProperty -Path $script:DwmPath -Name "OverlayTestMode" -ErrorAction SilentlyContinue).OverlayTestMode
    if ($val -eq 5) { return 'applied' } else { return 'notapplied' }
}

function Set-MpoState {
    param([bool]$Revert)
    try {
        if ($Revert) {
            if (Test-Path $script:DwmPath) {
                Remove-ItemProperty -Path $script:DwmPath -Name "OverlayTestMode" -ErrorAction SilentlyContinue
            }
        } else {
            if (-not (Test-Path $script:DwmPath)) { New-Item -Path $script:DwmPath -Force | Out-Null }
            Set-ItemProperty -Path $script:DwmPath -Name "OverlayTestMode" -Value 5 -Type DWord -Force -ErrorAction Stop
        }
        return $true
    } catch { return $false }
}

function Get-TdrState {
    if (-not (Test-Path $script:GfxPath)) { return 'notapplied' }
    $props = Get-ItemProperty -Path $script:GfxPath -ErrorAction SilentlyContinue
    if ($props.TdrDelay -eq 10 -and $props.TdrDdiDelay -eq 10) { return 'applied' } else { return 'notapplied' }
}

function Set-TdrState {
    param([bool]$Revert)
    try {
        if ($Revert) {
            if (Test-Path $script:GfxPath) {
                Remove-ItemProperty -Path $script:GfxPath -Name "TdrDelay" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $script:GfxPath -Name "TdrDdiDelay" -ErrorAction SilentlyContinue
            }
        } else {
            if (-not (Test-Path $script:GfxPath)) { New-Item -Path $script:GfxPath -Force | Out-Null }
            Set-ItemProperty -Path $script:GfxPath -Name "TdrDelay" -Value 10 -Type DWord -Force -ErrorAction Stop
            Set-ItemProperty -Path $script:GfxPath -Name "TdrDdiDelay" -Value 10 -Type DWord -Force -ErrorAction Stop
        }
        return $true
    } catch { return $false }
}

function Get-FastStartupState {
    if (-not (Test-Path $script:PowerPath)) { return 'notapplied' }
    $val = (Get-ItemProperty -Path $script:PowerPath -Name "HiberbootEnabled" -ErrorAction SilentlyContinue).HiberbootEnabled
    if ($val -eq 0) { return 'applied' } else { return 'notapplied' }
}

function Set-FastStartupState {
    param([bool]$Revert)
    try {
        if ($Revert) {
            powercfg /h on | Out-Null
            if (Test-Path $script:PowerPath) {
                Set-ItemProperty -Path $script:PowerPath -Name "HiberbootEnabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            }
        } else {
            powercfg /h off | Out-Null
            if (Test-Path $script:PowerPath) {
                Set-ItemProperty -Path $script:PowerPath -Name "HiberbootEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            }
        }
        return $true
    } catch { return $false }
}

$script:ModuleDefs = @(
    @{ Id = 'ULPS'; TitleKey = 'ULPSTitle'; DescKey = 'ULPSDesc'; GetState = ${function:Get-UlpsState}; SetState = ${function:Set-UlpsState} }
    @{ Id = 'MPO';  TitleKey = 'MPOTitle';  DescKey = 'MPODesc';  GetState = ${function:Get-MpoState};  SetState = ${function:Set-MpoState} }
    @{ Id = 'TDR';  TitleKey = 'TDRTitle';  DescKey = 'TDRDesc';  GetState = ${function:Get-TdrState};  SetState = ${function:Set-TdrState} }
    @{ Id = 'FS';   TitleKey = 'FSTitle';   DescKey = 'FSDesc';   GetState = ${function:Get-FastStartupState}; SetState = ${function:Set-FastStartupState} }
)

# ==========================================
# 6. XAML INTERFACE DESIGN (Windows 11 style, dark theme)
# ==========================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AMD Stability Optimizer" Height="700" Width="560"
        MinHeight="640" MinWidth="520"
        WindowStartupLocation="CenterScreen" ResizeMode="CanResize"
        Background="#0F172A" Foreground="#F8FAFC" FontFamily="Segoe UI">
    <Grid Margin="24">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header + Language Selector -->
        <Grid Grid.Row="0" Margin="0,0,0,18">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <StackPanel Grid.Column="0">
                <TextBlock Name="TxtTitle" Text="AMD STABILITY OPTIMIZER" FontSize="20" FontWeight="Bold" Foreground="#38BDF8"/>
                <TextBlock Name="TxtSubtitle" Text="RDNA2 Reliability Toolkit" FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0" TextWrapping="Wrap"/>
            </StackPanel>

            <StackPanel Grid.Column="1" HorizontalAlignment="Right">
                <ComboBox Name="CmbLanguage" Width="120" Height="28" HorizontalAlignment="Right"
                          Background="#1E293B" Foreground="#F8FAFC" BorderBrush="#334155" FontSize="12"
                          SelectedIndex="0">
                    <ComboBox.Resources>
                        <Style TargetType="ComboBoxItem">
                            <Setter Property="Background" Value="#1E293B"/>
                            <Setter Property="Foreground" Value="#F8FAFC"/>
                            <Setter Property="Padding" Value="8,4"/>
                            <Style.Triggers>
                                <Trigger Property="IsHighlighted" Value="True">
                                    <Setter Property="Background" Value="#334155"/>
                                    <Setter Property="Foreground" Value="#38BDF8"/>
                                </Trigger>
                                <Trigger Property="IsSelected" Value="True">
                                    <Setter Property="Background" Value="#0284C7"/>
                                    <Setter Property="Foreground" Value="#FFFFFF"/>
                                    <Setter Property="FontWeight" Value="SemiBold"/>
                                </Trigger>
                            </Style.Triggers>
                        </Style>
                    </ComboBox.Resources>
                    <ComboBox.Template>
                        <ControlTemplate TargetType="ComboBox">
                            <Grid>
                                <ToggleButton Name="ToggleBtn" Focusable="False" ClickMode="Press"
                                              IsChecked="{Binding Path=IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}">
                                    <ToggleButton.Template>
                                        <ControlTemplate TargetType="ToggleButton">
                                            <Border Name="ToggleBorder" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6">
                                                <Grid>
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition/>
                                                        <ColumnDefinition Width="20"/>
                                                    </Grid.ColumnDefinitions>
                                                    <Path Grid.Column="1" HorizontalAlignment="Center" VerticalAlignment="Center"
                                                          Data="M 0 0 L 6 0 L 3 5 Z" Fill="#94A3B8"/>
                                                </Grid>
                                            </Border>
                                            <ControlTemplate.Triggers>
                                                <Trigger Property="IsMouseOver" Value="True">
                                                    <Setter TargetName="ToggleBorder" Property="Background" Value="#273449"/>
                                                </Trigger>
                                            </ControlTemplate.Triggers>
                                        </ControlTemplate>
                                    </ToggleButton.Template>
                                </ToggleButton>
                                <ContentPresenter Name="ContentSite" IsHitTestVisible="False"
                                                   Content="{TemplateBinding SelectionBoxItem}"
                                                   ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}"
                                                   Margin="10,0,25,0" VerticalAlignment="Center" HorizontalAlignment="Left"
                                                   TextElement.Foreground="#F8FAFC" TextElement.FontWeight="SemiBold"/>
                                <Popup Name="Popup" Placement="Bottom" IsOpen="{TemplateBinding IsDropDownOpen}"
                                       AllowsTransparency="True" Focusable="False" PopupAnimation="Slide">
                                    <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6"
                                            MinWidth="{Binding ActualWidth, RelativeSource={RelativeSource TemplatedParent}}" MaxHeight="200">
                                        <ScrollViewer SnapsToDevicePixels="True">
                                            <ItemsPresenter/>
                                        </ScrollViewer>
                                    </Border>
                                </Popup>
                            </Grid>
                        </ControlTemplate>
                    </ComboBox.Template>
                    <ComboBoxItem Content="$LangNameEN" Tag="en-US" IsSelected="True"/>
                    <ComboBoxItem Content="$LangNamePT" Tag="pt-BR"/>
                    <ComboBoxItem Content="$LangNameES" Tag="es-ES"/>
                    <ComboBoxItem Content="$LangNameZH" Tag="zh-CN"/>
                </ComboBox>
                <StackPanel Orientation="Horizontal" Margin="0,8,0,0" HorizontalAlignment="Right">
                    <Ellipse Width="7" Height="7" Fill="#22C55E" VerticalAlignment="Center" Margin="0,0,5,0"/>
                    <TextBlock Name="TxtAdminBadge" Text="Running as Administrator" FontSize="10" Foreground="#64748B"/>
                </StackPanel>
            </StackPanel>
        </Grid>

        <!-- Module Cards -->
        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel>

                <Border Background="#1E293B" CornerRadius="12" Padding="16" Margin="0,0,0,12">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Grid.Column="0" Margin="0,0,12,0">
                            <TextBlock Name="TxtULPSTitle" Text="ULPS" FontSize="14" FontWeight="SemiBold" Foreground="#F8FAFC"/>
                            <TextBlock Name="TxtULPSDesc" Text="..." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,4,0,8"/>
                            <StackPanel Orientation="Horizontal">
                                <Ellipse Name="DotULPS" Width="8" Height="8" Fill="#FACC15" VerticalAlignment="Center" Margin="0,0,6,0"/>
                                <TextBlock Name="TxtULPSStatus" Text="..." FontSize="11" FontWeight="SemiBold" Foreground="#FACC15"/>
                            </StackPanel>
                        </StackPanel>
                        <Button Name="BtnULPS" Grid.Column="1" Content="Apply" Width="100" Height="34" VerticalAlignment="Center"
                                Background="#0284C7" Foreground="White" FontWeight="Bold" FontSize="12" BorderThickness="0" Cursor="Hand"/>
                    </Grid>
                </Border>

                <Border Background="#1E293B" CornerRadius="12" Padding="16" Margin="0,0,0,12">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Grid.Column="0" Margin="0,0,12,0">
                            <TextBlock Name="TxtMPOTitle" Text="MPO" FontSize="14" FontWeight="SemiBold" Foreground="#F8FAFC"/>
                            <TextBlock Name="TxtMPODesc" Text="..." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,4,0,8"/>
                            <StackPanel Orientation="Horizontal">
                                <Ellipse Name="DotMPO" Width="8" Height="8" Fill="#FACC15" VerticalAlignment="Center" Margin="0,0,6,0"/>
                                <TextBlock Name="TxtMPOStatus" Text="..." FontSize="11" FontWeight="SemiBold" Foreground="#FACC15"/>
                            </StackPanel>
                        </StackPanel>
                        <Button Name="BtnMPO" Grid.Column="1" Content="Apply" Width="100" Height="34" VerticalAlignment="Center"
                                Background="#0284C7" Foreground="White" FontWeight="Bold" FontSize="12" BorderThickness="0" Cursor="Hand"/>
                    </Grid>
                </Border>

                <Border Background="#1E293B" CornerRadius="12" Padding="16" Margin="0,0,0,12">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Grid.Column="0" Margin="0,0,12,0">
                            <TextBlock Name="TxtTDRTitle" Text="TDR" FontSize="14" FontWeight="SemiBold" Foreground="#F8FAFC"/>
                            <TextBlock Name="TxtTDRDesc" Text="..." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,4,0,8"/>
                            <StackPanel Orientation="Horizontal">
                                <Ellipse Name="DotTDR" Width="8" Height="8" Fill="#FACC15" VerticalAlignment="Center" Margin="0,0,6,0"/>
                                <TextBlock Name="TxtTDRStatus" Text="..." FontSize="11" FontWeight="SemiBold" Foreground="#FACC15"/>
                            </StackPanel>
                        </StackPanel>
                        <Button Name="BtnTDR" Grid.Column="1" Content="Apply" Width="100" Height="34" VerticalAlignment="Center"
                                Background="#0284C7" Foreground="White" FontWeight="Bold" FontSize="12" BorderThickness="0" Cursor="Hand"/>
                    </Grid>
                </Border>

                <Border Background="#1E293B" CornerRadius="12" Padding="16" Margin="0,0,0,12">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Grid.Column="0" Margin="0,0,12,0">
                            <TextBlock Name="TxtFSTitle" Text="Fast Startup" FontSize="14" FontWeight="SemiBold" Foreground="#F8FAFC"/>
                            <TextBlock Name="TxtFSDesc" Text="..." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,4,0,8"/>
                            <StackPanel Orientation="Horizontal">
                                <Ellipse Name="DotFS" Width="8" Height="8" Fill="#FACC15" VerticalAlignment="Center" Margin="0,0,6,0"/>
                                <TextBlock Name="TxtFSStatus" Text="..." FontSize="11" FontWeight="SemiBold" Foreground="#FACC15"/>
                            </StackPanel>
                        </StackPanel>
                        <Button Name="BtnFS" Grid.Column="1" Content="Apply" Width="100" Height="34" VerticalAlignment="Center"
                                Background="#0284C7" Foreground="White" FontWeight="Bold" FontSize="12" BorderThickness="0" Cursor="Hand"/>
                    </Grid>
                </Border>

            </StackPanel>
        </ScrollViewer>

        <!-- Footer status line -->
        <TextBlock Name="TxtFooter" Grid.Row="2" Text="Ready." FontSize="11" Foreground="#64748B" Margin="0,10,0,0" TextWrapping="Wrap"/>

        <!-- Bottom Action Buttons -->
        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,16,0,0">
            <Button Name="BtnRevertAll" Content="Revert All" Width="150" Height="38" Margin="0,0,10,0"
                    Background="#334155" Foreground="White" FontWeight="SemiBold" FontSize="12" BorderThickness="0" Cursor="Hand"/>
            <Button Name="BtnApplyAll" Content="Apply All Fixes" Width="150" Height="38" Margin="0,0,10,0"
                    Background="#0284C7" Foreground="White" FontWeight="Bold" FontSize="12" BorderThickness="0" Cursor="Hand"/>
            <Button Name="BtnCloseWin" Content="Close" Width="90" Height="38"
                    Background="#334155" Foreground="White" FontWeight="SemiBold" FontSize="12" BorderThickness="0" Cursor="Hand"/>
        </StackPanel>
    </Grid>
</Window>
"@

# ==========================================
# 7. RENDER WINDOW (UTF-8 safe stream load)
# ==========================================
$bytes = [System.Text.Encoding]::UTF8.GetBytes($xaml.OuterXml)
$stream = New-Object System.IO.MemoryStream(,$bytes)
$Window = [Windows.Markup.XamlReader]::Load($stream)

$TxtTitle      = $Window.FindName("TxtTitle")
$TxtSubtitle   = $Window.FindName("TxtSubtitle")
$TxtAdminBadge = $Window.FindName("TxtAdminBadge")
$CmbLanguage   = $Window.FindName("CmbLanguage")
$TxtFooter     = $Window.FindName("TxtFooter")
$BtnApplyAll   = $Window.FindName("BtnApplyAll")
$BtnRevertAll  = $Window.FindName("BtnRevertAll")
$BtnCloseWin   = $Window.FindName("BtnCloseWin")

# ==========================================
# 8. SHARED BUTTON TEMPLATE (rounded, hover/press/disabled states)
#    A single template object is reused across every button, colors
#    come from each Button's own Background/Foreground properties.
# ==========================================
[xml]$btnTemplateXaml = @"
<ControlTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" TargetType="Button">
    <Border Name="Bg" Background="{TemplateBinding Background}" CornerRadius="8">
        <ContentPresenter Name="Content" HorizontalAlignment="Center" VerticalAlignment="Center"
                           TextElement.Foreground="{TemplateBinding Foreground}"
                           TextElement.FontWeight="{TemplateBinding FontWeight}"/>
    </Border>
    <ControlTemplate.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
            <Setter TargetName="Bg" Property="Opacity" Value="0.9"/>
        </Trigger>
        <Trigger Property="IsPressed" Value="True">
            <Setter TargetName="Bg" Property="Opacity" Value="0.75"/>
        </Trigger>
        <Trigger Property="IsEnabled" Value="False">
            <Setter TargetName="Bg" Property="Background" Value="#0F172A"/>
            <Setter TargetName="Bg" Property="Opacity" Value="1"/>
            <Setter TargetName="Content" Property="TextElement.Foreground" Value="#475569"/>
        </Trigger>
    </ControlTemplate.Triggers>
</ControlTemplate>
"@
$btnTemplateBytes = [System.Text.Encoding]::UTF8.GetBytes($btnTemplateXaml.OuterXml)
$btnTemplateStream = New-Object System.IO.MemoryStream(,$btnTemplateBytes)
$script:SharedButtonTemplate = [Windows.Markup.XamlReader]::Load($btnTemplateStream)

$script:AllButtons = @($BtnApplyAll, $BtnRevertAll, $BtnCloseWin)
foreach ($moduleDef in $script:ModuleDefs) {
    $script:AllButtons += $Window.FindName("Btn$($moduleDef.Id)")
}
foreach ($btn in $script:AllButtons) {
    $btn.Template = $script:SharedButtonTemplate
}

# ==========================================
# 9. UI STATE + LOCALIZATION REFRESH
# ==========================================
$script:StateColors = @{
    'applied'     = '#22C55E'
    'notapplied'  = '#FACC15'
    'unavailable' = '#EF4444'
}

function Update-ModuleCard {
    param([hashtable]$ModuleDef)

    $id = $ModuleDef.Id
    $txtTitle  = $Window.FindName("Txt${id}Title")
    $txtDesc   = $Window.FindName("Txt${id}Desc")
    $txtStatus = $Window.FindName("Txt${id}Status")
    $dot       = $Window.FindName("Dot${id}")
    $btn       = $Window.FindName("Btn${id}")

    $txtTitle.Text = Get-Str $ModuleDef.TitleKey
    $txtDesc.Text  = Get-Str $ModuleDef.DescKey

    $state = & $ModuleDef.GetState
    $color = $script:StateColors[$state]
    $dot.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString($color)
    $txtStatus.Foreground = $dot.Fill

    switch ($state) {
        'applied'     { $txtStatus.Text = Get-Str 'StatusApplied' }
        'notapplied'  { $txtStatus.Text = Get-Str 'StatusNotApplied' }
        'unavailable' { $txtStatus.Text = Get-Str 'StatusUnavailable' }
    }

    if ($state -eq 'unavailable') {
        $btn.IsEnabled = $false
        $btn.Content = Get-Str 'BtnApply'
        $btn.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#334155')
    } elseif ($state -eq 'applied') {
        $btn.IsEnabled = $true
        $btn.Content = Get-Str 'BtnRevert'
        $btn.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#334155')
    } else {
        $btn.IsEnabled = $true
        $btn.Content = Get-Str 'BtnApply'
        $btn.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#0284C7')
    }
}

function Update-AllUI {
    $Window.Title  = Get-Str 'AppTitle'
    $TxtTitle.Text = Get-Str 'AppTitle'
    $TxtSubtitle.Text = Get-Str 'AppSubtitle'
    $TxtAdminBadge.Text = Get-Str 'AdminBadge'
    $BtnApplyAll.Content = Get-Str 'BtnApplyAll'
    $BtnRevertAll.Content = Get-Str 'BtnRevertAll'
    $BtnCloseWin.Content = Get-Str 'BtnCloseWin'

    foreach ($moduleDef in $script:ModuleDefs) {
        Update-ModuleCard -ModuleDef $moduleDef
    }
}

function Set-Footer {
    param([string]$Text, [string]$Color = '#64748B')
    $TxtFooter.Text = $Text
    $TxtFooter.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($Color)
}

function Set-AllButtonsEnabled {
    param([bool]$Enabled)
    foreach ($btn in $script:AllButtons) { $btn.IsEnabled = $Enabled }
    $CmbLanguage.IsEnabled = $Enabled
}

function Invoke-BackupWithFeedback {
    Set-Footer (Get-Str 'FooterBackingUp')
    $TxtFooter.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Render, [action]{})
    $backupResult = New-SafetyBackup
    if ($backupResult.RestorePoint) {
        Set-Footer (Get-Str 'FooterRestorePointOk') '#22C55E'
    } else {
        Set-Footer (Get-Str 'FooterRestorePointWarn') '#FACC15'
    }
    return $backupResult
}

# ==========================================
# 10. EVENT HANDLERS
# ==========================================
$CmbLanguage.Add_SelectionChanged({
    if ($CmbLanguage.SelectedItem) {
        $script:CurrentLang = $CmbLanguage.SelectedItem.Tag
        Update-AllUI
    }
})

foreach ($moduleDef in $script:ModuleDefs) {
    $btn = $Window.FindName("Btn$($moduleDef.Id)")
    $capturedDef = $moduleDef
    $btn.Add_Click({
        Set-AllButtonsEnabled $false
        Invoke-BackupWithFeedback | Out-Null

        $state = & $capturedDef.GetState
        $revert = ($state -eq 'applied')
        $ok = & $capturedDef.SetState $revert

        $moduleName = Get-Str $capturedDef.TitleKey
        if ($ok) {
            if ($revert) {
                Set-Footer ((Get-Str 'FooterModuleReverted') -f $moduleName) '#22C55E'
            } else {
                Set-Footer ((Get-Str 'FooterModuleApplied') -f $moduleName) '#22C55E'
            }
        } else {
            Set-Footer ((Get-Str 'FooterModuleFailed') -f $moduleName) '#EF4444'
        }

        Update-AllUI
        Set-AllButtonsEnabled $true
    }.GetNewClosure())
}

$BtnApplyAll.Add_Click({
    Set-AllButtonsEnabled $false
    Set-Footer (Get-Str 'FooterApplyingAll')
    Invoke-BackupWithFeedback | Out-Null

    foreach ($moduleDef in $script:ModuleDefs) {
        $state = & $moduleDef.GetState
        if ($state -ne 'applied') {
            & $moduleDef.SetState $false | Out-Null
        }
    }

    Update-AllUI
    Set-Footer (Get-Str 'FooterApplyAllDone') '#22C55E'
    Set-AllButtonsEnabled $true
})

$BtnRevertAll.Add_Click({
    Set-AllButtonsEnabled $false
    Set-Footer (Get-Str 'FooterRevertingAll')
    Invoke-BackupWithFeedback | Out-Null

    foreach ($moduleDef in $script:ModuleDefs) {
        $state = & $moduleDef.GetState
        if ($state -eq 'applied') {
            & $moduleDef.SetState $true | Out-Null
        }
    }

    Update-AllUI
    Set-Footer (Get-Str 'FooterRevertAllDone') '#22C55E'
    Set-AllButtonsEnabled $true
})

$BtnCloseWin.Add_Click({
    $Window.Close()
})

# ==========================================
# 11. LANGUAGE PRE-SELECTION + INITIAL RENDER
# ==========================================
$itemToSelect = $CmbLanguage.Items | Where-Object { $_.Tag -eq $script:CurrentLang } | Select-Object -First 1
if ($itemToSelect) {
    $CmbLanguage.SelectedItem = $itemToSelect
} else {
    $CmbLanguage.SelectedIndex = 0
}

Set-Footer (Get-Str 'FooterReady')
Update-AllUI

# Show UI Window
$Window.ShowDialog() | Out-Null
