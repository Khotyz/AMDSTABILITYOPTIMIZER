<#
.SYNOPSIS
    Modular PowerShell script to check and disable AMD ULPS (Ultra Low Power State).
.DESCRIPTION
    Supports multiple languages (pt-BR, en-US, es-ES, zh-CN).
    Requires Administrator privileges.
#>

# ==========================================
# 1. LOCALIZATION DICTIONARY
# ==========================================
$script:Messages = @{
    'pt-BR' = @{
        'Title'             = "==========================================`n      GERENCIADOR DE AMD ULPS            `n=========================================="
        'ReqAdmin'          = "Requisitando permissões de Administrador..."
        'CheckingULPS'      = "Verificando o status do ULPS no sistema..."
        'NotFound'          = "Nenhuma chave de registro do AMD ULPS foi encontrada neste sistema.`nIsso pode significar que você não possui uma GPU AMD compatível instalada."
        'AlreadyDisabled'   = "O AMD ULPS já está DESATIVADO no sistema."
        'ULPSActive'        = "O AMD ULPS está atualmente ATIVO."
        'AskDisable'        = "Deseja desativar o ULPS?"
        'Disabling'         = "`nDesativando ULPS no Registro..."
        'Success'           = "ULPS desativado com sucesso em {0} entrada(s) do registro!"
        'Error'             = "Falha ao alterar as configurações do ULPS."
        'AskReboot'         = "Deseja reiniciar o computador agora para aplicar as alterações?"
        'Rebooting'         = "`nReiniciando o sistema em 5 segundos..."
        'RebootLater'       = "`nLembre-se de reiniciar o computador mais tarde para que as alterações façam efeito."
        'Canceled'          = "`nOperação cancelada pelo usuário. O ULPS permanece ativo."
        'PressEnter'        = "Pressione Enter para fechar esta janela..."
    }
    'en-US' = @{
        'Title'             = "==========================================`n        AMD ULPS MANAGER                `n=========================================="
        'ReqAdmin'          = "Requesting Administrator privileges..."
        'CheckingULPS'      = "Checking ULPS status on the system..."
        'NotFound'          = "No AMD ULPS registry keys were found on this system.`nThis may mean you do not have a compatible AMD GPU installed."
        'AlreadyDisabled'   = "AMD ULPS is already DISABLED on the system."
        'ULPSActive'        = "AMD ULPS is currently ACTIVE."
        'AskDisable'        = "Do you want to disable ULPS?"
        'Disabling'         = "`nDisabling ULPS in Registry..."
        'Success'           = "ULPS successfully disabled in {0} registry entry/entries!"
        'Error'             = "Failed to modify ULPS settings."
        'AskReboot'         = "Do you want to restart the computer now to apply changes?"
        'Rebooting'         = "`nRestarting system in 5 seconds..."
        'RebootLater'       = "`nRemember to restart your computer later for changes to take effect."
        'Canceled'          = "`nOperation canceled by user. ULPS remains active."
        'PressEnter'        = "Press Enter to close this window..."
    }
    'es-ES' = @{
        'Title'             = "==========================================`n      GESTOR DE AMD ULPS                 `n=========================================="
        'ReqAdmin'          = "Solicitando permisos de Administrador..."
        'CheckingULPS'      = "Verificando el estado de ULPS en el sistema..."
        'NotFound'          = "No se encontraron claves de registro de AMD ULPS en este sistema.`nEsto puede significar que no tiene una GPU AMD compatible instalada."
        'AlreadyDisabled'   = "AMD ULPS ya está DESACTIVADO en el sistema."
        'ULPSActive'        = "AMD ULPS está actualmente ACTIVO."
        'AskDisable'        = "¿Desea desactivar ULPS?"
        'Disabling'         = "`nDesactivando ULPS en el Registro..."
        'Success'           = "¡ULPS desactivado con éxito en {0} entrada(s) del registro!"
        'Error'             = "Error al modificar la configuración de ULPS."
        'AskReboot'         = "¿Desea reiniciar el equipo ahora para aplicar los cambios?"
        'Rebooting'         = "`nReiniciando el sistema en 5 segundos..."
        'RebootLater'       = "`nRecuerde reiniciar su equipo más tarde para que los cambios surtan efecto."
        'Canceled'          = "`nOperación cancelada por el usuario. ULPS permanece activo."
        'PressEnter'        = "Presione Enter para cerrar esta ventana..."
    }
    'zh-CN' = @{
        'Title'             = "==========================================`n        AMD ULPS 管理器                 `n=========================================="
        'ReqAdmin'          = "正在请求管理员权限..."
        'CheckingULPS'      = "正在检查系统中的 ULPS 状态..."
        'NotFound'          = "未在此系统中找到 AMD ULPS 注册表项。`n这可能意味着您未安装兼容的 AMD 显卡。"
        'AlreadyDisabled'   = "系统中的 AMD ULPS 已经处于禁用状态。"
        'ULPSActive'        = "AMD ULPS 当前处于启用状态。"
        'AskDisable'        = "是否要禁用 ULPS？"
        'Disabling'         = "`n正在注册表中禁用 ULPS..."
        'Success'           = "已成功在 {0} 个注册表项中禁用 ULPS！"
        'Error'             = "修改 ULPS 设置失败。"
        'AskReboot'         = "是否立即重启计算机以应用更改？"
        'Rebooting'         = "`n系统将在 5 秒内重启..."
        'RebootLater'       = "`n请记得稍后重启计算机以使更改生效。"
        'Canceled'          = "`n用户已取消操作。ULPS 仍保持启用状态。"
        'PressEnter'        = "按 Enter 键关闭此窗口..."
    }
}

# ==========================================
# 2. LANGUAGE DETECTION MODULE
# ==========================================
function Get-LocalizedText {
    param ([string]$Key)

    $lang = (Get-UICulture).Name

    if (-not $script:Messages.ContainsKey($lang)) {
        if ($lang.StartsWith("pt")) { $lang = 'pt-BR' }
        elseif ($lang.StartsWith("es")) { $lang = 'es-ES' }
        elseif ($lang.StartsWith("zh")) { $lang = 'zh-CN' }
        else { $lang = 'en-US' }
    }

    return $script:Messages[$lang][$Key]
}

# ==========================================
# 3. PRIVILEGE ELEVATION MODULE
# ==========================================
function Ensure-AdminPrivileges {
    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdministrator) {
        Write-Host (Get-LocalizedText -Key 'ReqAdmin') -ForegroundColor Yellow
        
        $scriptUrl = "https://raw.githubusercontent.com/Khotyz/ULPSDISABLER/main/Disable-ULPS.ps1"
        
        if ($PSCommandPath) {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        } else {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb '$scriptUrl' | iex`"" -Verb RunAs
        }
        exit
    }
}

# ==========================================
# 4. ULPS VERIFICATION MODULE
# ==========================================
function Get-ULPSStatus {
    $ulpsKeys = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Recurse -ErrorAction SilentlyContinue |
                Get-ItemProperty -Name "EnableUlps" -ErrorAction SilentlyContinue

    if (-not $ulpsKeys) {
        return @{ Found = $false; IsActive = $false; Keys = @() }
    }

    $activeKeys = $ulpsKeys | Where-Object { $_.EnableUlps -eq 1 }

    return @{
        Found    = $true
        IsActive = ($activeKeys.Count -gt 0)
        Keys     = $ulpsKeys
    }
}

# ==========================================
# 5. ULPS DISABLE MODULE
# ==========================================
function Disable-ULPS {
    param ([array]$Keys)

    Write-Host (Get-LocalizedText -Key 'Disabling') -ForegroundColor Cyan
    $successCount = 0

    foreach ($key in $Keys) {
        try {
            Set-ItemProperty -Path $key.PSPath -Name "EnableUlps" -Value 0 -ErrorAction Stop
            
            if (Get-ItemProperty -Path $key.PSPath -Name "EnableUlps_NA" -ErrorAction SilentlyContinue) {
                Set-ItemProperty -Path $key.PSPath -Name "EnableUlps_NA" -Value 0 -ErrorAction Stop
            }

            $successCount++
        }
        catch {
        }
    }

    if ($successCount -gt 0) {
        $msg = (Get-LocalizedText -Key 'Success') -f $successCount
        Write-Host $msg -ForegroundColor Green
        return $true
    } else {
        Write-Host (Get-LocalizedText -Key 'Error') -ForegroundColor Red
        return $false
    }
}

# ==========================================
# 6. USER CONFIRMATION MODULE
# ==========================================
function Confirm-Choice {
    param ([string]$Message)

    do {
        $response = Read-Host -Prompt "$Message [Y/N or S/N]"
        $cleanResponse = $response.Trim().ToUpper()
    } while ($cleanResponse -ne 'S' -and $cleanResponse -ne 'N' -and $cleanResponse -ne 'Y')

    return ($cleanResponse -eq 'S' -or $cleanResponse -eq 'Y')
}

# ==========================================
# 7. SYSTEM REBOOT MODULE
# ==========================================
function Request-SystemReboot {
    $reboot = Confirm-Choice -Message (Get-LocalizedText -Key 'AskReboot')
    
    if ($reboot) {
        Write-Host (Get-LocalizedText -Key 'Rebooting') -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        Restart-Computer -Force
    } else {
        Write-Host (Get-LocalizedText -Key 'RebootLater') -ForegroundColor Cyan
    }
}

# ==========================================
# MAIN EXECUTION FLOW MODULE
# ==========================================
function Main {
    # Force UTF-8 Encoding for input, output, and console pipeline
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding           = [System.Text.Encoding]::UTF8

    Ensure-AdminPrivileges

    Clear-Host
    Write-Host (Get-LocalizedText -Key 'Title') -ForegroundColor Cyan
    Write-Host ""

    Write-Host (Get-LocalizedText -Key 'CheckingULPS') -ForegroundColor Yellow
    $ulpsState = Get-ULPSStatus

    if (-not $ulpsState.Found) {
        Write-Host (Get-LocalizedText -Key 'NotFound') -ForegroundColor Red
        Read-Host "`n$(Get-LocalizedText -Key 'PressEnter')"
        return
    }

    if (-not $ulpsState.IsActive) {
        Write-Host (Get-LocalizedText -Key 'AlreadyDisabled') -ForegroundColor Green
        Read-Host "`n$(Get-LocalizedText -Key 'PressEnter')"
        return
    }

    Write-Host (Get-LocalizedText -Key 'ULPSActive') -ForegroundColor Yellow
    $shouldDisable = Confirm-Choice -Message (Get-LocalizedText -Key 'AskDisable')

    if ($shouldDisable) {
        $result = Disable-ULPS -Keys $ulpsState.Keys
        if ($result) {
            Write-Host ""
            Request-SystemReboot
        }
    } else {
        Write-Host (Get-LocalizedText -Key 'Canceled') -ForegroundColor Yellow
    }

    Write-Host ""
    Read-Host (Get-LocalizedText -Key 'PressEnter')
}

Main
