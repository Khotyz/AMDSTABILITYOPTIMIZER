<#
.SYNOPSIS
    Modern WPF Graphical Interface to check and disable AMD ULPS (Ultra Low Power State).
.DESCRIPTION
    Launches a clean, dark-themed UI window with manual language selection.
    Auto-elevates to Admin if needed.
#>

# ==========================================
# 1. AUTO ADMIN ELEVATION
# ==========================================
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdministrator) {
    $scriptUrl = "https://raw.githubusercontent.com/Khotyz/ULPSDISABLER/main/Disable-ULPS.ps1"
    if ($PSCommandPath) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb '$scriptUrl' | iex`"" -Verb RunAs
    }
    exit
}

# Load Assemblies for WPF GUI
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# ==========================================
# 2. LOCALIZATION DICTIONARY
# ==========================================
$script:Messages = @{
    'pt-BR' = @{
        'Title'         = "AMD ULPS DISABLER"
        'Subtitle'      = "Gerencie o Ultra Low Power State para GPUs AMD"
        'SysStatus'     = "STATUS DO SISTEMA"
        'NoGpu'         = "Nenhuma GPU AMD Encontrada"
        'NoGpuDetail'   = "Nenhuma chave de registro do AMD ULPS foi detectada neste computador."
        'Disabled'      = "ULPS está Desativado"
        'DisabledDetail'= "O AMD Ultra Low Power State já está inativo no seu sistema."
        'Active'        = "ULPS está Ativo"
        'ActiveDetail'  = "Encontrada(s) {0} entrada(s) de registro ativa(s). Desativar pode melhorar a estabilidade."
        'BtnDisable'    = "Desativar ULPS"
        'BtnClose'      = "Fechar"
        'Success'       = "ULPS Desativado com Sucesso!"
        'SuccessDetail' = "Chaves de registro atualizadas. Deseja reiniciar o PC agora?"
        'BtnRestart'    = "Reiniciar PC"
        'Error'         = "Falha ao Desativar"
        'ErrorDetail'   = "Não foi possível modificar as chaves do registro."
    }
    'en-US' = @{
        'Title'         = "AMD ULPS DISABLER"
        'Subtitle'      = "Manage Ultra Low Power State for AMD Graphics"
        'SysStatus'     = "SYSTEM STATUS"
        'NoGpu'         = "No AMD GPU Found"
        'NoGpuDetail'   = "No AMD ULPS registry keys were detected on this computer."
        'Disabled'      = "ULPS is Disabled"
        'DisabledDetail'= "AMD Ultra Low Power State is already inactive on your system."
        'Active'        = "ULPS is Active"
        'ActiveDetail'  = "Found {0} active registry entry/entries. Disabling it can improve system stability."
        'BtnDisable'    = "Disable ULPS"
        'BtnClose'      = "Close"
        'Success'       = "ULPS Disabled Successfully!"
        'SuccessDetail' = "Registry entries updated. Would you like to restart your PC now?"
        'BtnRestart'    = "Restart PC"
        'Error'         = "Failed to Disable"
        'ErrorDetail'   = "Could not modify registry keys."
    }
    'es-ES' = @{
        'Title'         = "GESTOR AMD ULPS"
        'Subtitle'      = "Gestione Ultra Low Power State para gráficas AMD"
        'SysStatus'     = "ESTADO DEL SISTEMA"
        'NoGpu'         = "GPU AMD No Encontrada"
        'NoGpuDetail'   = "No se encontraron claves de registro de AMD ULPS en este equipo."
        'Disabled'      = "ULPS está Desactivado"
        'DisabledDetail'= "AMD Ultra Low Power State ya está inactivo en su sistema."
        'Active'        = "ULPS está Activo"
        'ActiveDetail'  = "Se encontró/aron {0} entrada(s) activa(s). Desactivarlo puede mejorar la estabilidad."
        'BtnDisable'    = "Desactivar ULPS"
        'BtnClose'      = "Cerrar"
        'Success'       = "¡ULPS Desactivado con Éxito!"
        'SuccessDetail' = "Registro actualizado. ¿Desea reiniciar el equipo ahora?"
        'BtnRestart'    = "Reiniciar PC"
        'Error'         = "Error al Desactivar"
        'ErrorDetail'   = "No se pudieron modificar las claves del registro."
    }
    'zh-CN' = @{
        'Title'         = "AMD ULPS 管理器"
        'Subtitle'      = "管理 AMD 显卡的 Ultra Low Power State"
        'SysStatus'     = "系统状态"
        'NoGpu'         = "未找到 AMD 显卡"
        'NoGpuDetail'   = "在此计算机上未检测到 AMD ULPS 注册表项。"
        'Disabled'      = "ULPS 已禁用"
        'DisabledDetail'= "AMD Ultra Low Power State 在您的系统中已处于非活动状态。"
        'Active'        = "ULPS 当前处于启用状态"
        'ActiveDetail'  = "找到 {0} 个活动注册表项。禁用它可以提高系统稳定性。"
        'BtnDisable'    = "禁用 ULPS"
        'BtnClose'      = "关闭"
        'Success'       = "已成功禁用 ULPS！"
        'SuccessDetail' = "注册表项已更新。您想立即重启计算机吗？"
        'BtnRestart'    = "重启 PC"
        'Error'         = "禁用失败"
        'ErrorDetail'   = "无法修改注册表项。"
    }
}

# ==========================================
# 3. XAML INTERFACE DESIGN
# ==========================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AMD ULPS Manager" Height="380" Width="500"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        Background="#0F172A" Foreground="#F8FAFC" FontFamily="Segoe UI">
    <Grid Margin="24">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header + Language Selector -->
        <Grid Grid.Row="0" Margin="0,0,0,20">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <StackPanel Grid.Column="0">
                <TextBlock Name="TxtTitle" Text="AMD ULPS DISABLER" FontSize="20" FontWeight="Bold" Foreground="#38BDF8"/>
                <TextBlock Name="TxtSubtitle" Text="Gerencie o Ultra Low Power State para GPUs AMD" FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0"/>
            </StackPanel>

            <ComboBox Name="CmbLanguage" Grid.Column="1" Width="100" Height="28" VerticalAlignment="Top"
                      Background="#1E293B" Foreground="#F8FAFC" BorderBrush="#334155" FontSize="12">
                <ComboBoxItem Content="Português" Tag="pt-BR" IsSelected="True"/>
                <ComboBoxItem Content="English" Tag="en-US"/>
                <ComboBoxItem Content="Español" Tag="es-ES"/>
                <ComboBoxItem Content="中文" Tag="zh-CN"/>
            </ComboBox>
        </Grid>

        <!-- Status Card -->
        <Border Grid.Row="1" Background="#1E293B" CornerRadius="12" Padding="20" VerticalAlignment="Center">
            <StackPanel Name="StatusPanel">
                <TextBlock Name="TxtSysStatus" Text="STATUS DO SISTEMA" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,8"/>
                <TextBlock Name="TxtStatus" Text="..." FontSize="16" FontWeight="SemiBold" Foreground="#FACC15"/>
                <TextBlock Name="TxtDetail" Text="..." FontSize="12" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,6,0,0"/>
            </StackPanel>
        </Border>

        <!-- Action Buttons -->
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,20,0,0">
            <Button Name="BtnAction" Content="Desativar ULPS" Width="140" Height="38" Margin="0,0,10,0"
                    Background="#0284C7" Foreground="White" FontWeight="Bold" FontSize="13" BorderThickness="0" Cursor="Hand" IsEnabled="False">
                <Button.Resources>
                    <Style TargetType="Border">
                        <Setter Property="CornerRadius" Value="8"/>
                    </Style>
                </Button.Resources>
            </Button>
            
            <Button Name="BtnClose" Content="Fechar" Width="90" Height="38"
                    Background="#334155" Foreground="White" FontWeight="SemiBold" FontSize="13" BorderThickness="0" Cursor="Hand">
                <Button.Resources>
                    <Style TargetType="Border">
                        <Setter Property="CornerRadius" Value="8"/>
                    </Style>
                </Button.Resources>
            </Button>
        </StackPanel>
    </Grid>
</Window>
"@

# Render XAML Window
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Element References
$TxtTitle     = $Window.FindName("TxtTitle")
$TxtSubtitle  = $Window.FindName("TxtSubtitle")
$TxtSysStatus = $Window.FindName("TxtSysStatus")
$TxtStatus    = $Window.FindName("TxtStatus")
$TxtDetail    = $Window.FindName("TxtDetail")
$BtnAction    = $Window.FindName("BtnAction")
$BtnClose     = $Window.FindName("BtnClose")
$CmbLanguage  = $Window.FindName("CmbLanguage")

# Global script variables for status track
$script:isFinished = $false

# ==========================================
# 4. ULPS DETECTION & DYNAMIC UI REFRESH
# ==========================================
function Get-ULPSKeys {
    Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Recurse -ErrorAction SilentlyContinue |
    Get-ItemProperty -Name "EnableUlps" -ErrorAction SilentlyContinue
}

$script:ulpsKeys = Get-ULPSKeys
$script:activeKeys = $script:ulpsKeys | Where-Object { $_.EnableUlps -eq 1 }

function Update-UIStrings {
    $selectedTag = $CmbLanguage.SelectedItem.Tag
    $dict = $script:Messages[$selectedTag]

    $TxtTitle.Text     = $dict['Title']
    $TxtSubtitle.Text  = $dict['Subtitle']
    $TxtSysStatus.Text = $dict['SysStatus']
    $BtnClose.Content  = $dict['BtnClose']

    if ($script:isFinished) {
        $TxtStatus.Text = $dict['Success']
        $TxtDetail.Text = $dict['SuccessDetail']
        $BtnAction.Content = $dict['BtnRestart']
    } elseif (-not $script:ulpsKeys) {
        $TxtStatus.Text = $dict['NoGpu']
        $TxtStatus.Foreground = "#EF4444"
        $TxtDetail.Text = $dict['NoGpuDetail']
        $BtnAction.Content = $dict['BtnDisable']
    } elseif ($script:activeKeys.Count -eq 0) {
        $TxtStatus.Text = $dict['Disabled']
        $TxtStatus.Foreground = "#22C55E"
        $TxtDetail.Text = $dict['DisabledDetail']
        $BtnAction.Content = $dict['BtnDisable']
    } else {
        $TxtStatus.Text = $dict['Active']
        $TxtStatus.Foreground = "#FACC15"
        $TxtDetail.Text = $dict['ActiveDetail'] -f $script:activeKeys.Count
        $BtnAction.Content = $dict['BtnDisable']
        $BtnAction.IsEnabled = $true
    }
}

# Change Language Event
$CmbLanguage.Add_SelectionChanged({
    Update-UIStrings
})

# Initial UI Population
Update-UIStrings

# ==========================================
# 5. BUTTON EVENTS & ACTIONS
# ==========================================
$BtnAction.Add_Click({
    if ($script:isFinished) {
        Restart-Computer -Force
        return
    }

    $success = 0
    foreach ($key in $script:ulpsKeys) {
        try {
            Set-ItemProperty -Path $key.PSPath -Name "EnableUlps" -Value 0 -ErrorAction Stop
            if (Get-ItemProperty -Path $key.PSPath -Name "EnableUlps_NA" -ErrorAction SilentlyContinue) {
                Set-ItemProperty -Path $key.PSPath -Name "EnableUlps_NA" -Value 0 -ErrorAction Stop
            }
            $success++
        } catch {}
    }

    if ($success -gt 0) {
        $script:isFinished = $true
        $TxtStatus.Foreground = "#22C55E"
        $BtnAction.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#DC2626")
        Update-UIStrings
    } else {
        $selectedTag = $CmbLanguage.SelectedItem.Tag
        $dict = $script:Messages[$selectedTag]
        $TxtStatus.Text = $dict['Error']
        $TxtStatus.Foreground = "#EF4444"
        $TxtDetail.Text = $dict['ErrorDetail']
        $BtnAction.IsEnabled = $false
    }
})

$BtnClose.Add_Click({
    $Window.Close()
})

# Show UI Window
$Window.ShowDialog() | Out-Null
