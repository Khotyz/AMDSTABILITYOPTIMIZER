<#
.SYNOPSIS
    Modern WPF Graphical Interface to check and disable AMD ULPS (Ultra Low Power State).
.DESCRIPTION
    Launches a clean, dark-themed UI window with manual language selection and UTF-8 encoding support.
    Auto-elevates to Admin if needed.
#>

# Force UTF-8 encoding for the PowerShell console session
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"[Console]::OutputEncoding=[System.Text.Encoding]::UTF8; iwr -useb '$scriptUrl' | iex`"" -Verb RunAs
    }
    exit
}

# Load Assemblies for WPF GUI
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# ==========================================
# 2. LOCALIZATION DICTIONARY (encoding-safe: every non-ASCII
#    character is built from its Unicode code point via [char],
#    so the visible text never depends on how this .ps1 file
#    itself is saved/read/encoded)
# ==========================================
$script:Messages = @{
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
    'pt-BR' = @{
        'Title'         = "AMD ULPS DISABLER"
        'Subtitle'      = "Gerencie o Ultra Low Power State para GPUs AMD"
        'SysStatus'     = "STATUS DO SISTEMA"
        'NoGpu'         = "Nenhuma GPU AMD Encontrada"
        'NoGpuDetail'   = "Nenhuma chave de registro do AMD ULPS foi detectada neste computador."
        'Disabled'      = "ULPS est" + [char]0x00E1 + " Desativado"
        'DisabledDetail'= "O AMD Ultra Low Power State j" + [char]0x00E1 + " est" + [char]0x00E1 + " inativo no seu sistema."
        'Active'        = "ULPS est" + [char]0x00E1 + " Ativo"
        'ActiveDetail'  = "Encontrada(s) {0} entrada(s) de registro ativa(s). Desativar pode melhorar a estabilidade."
        'BtnDisable'    = "Desativar ULPS"
        'BtnClose'      = "Fechar"
        'Success'       = "ULPS Desativado com Sucesso!"
        'SuccessDetail' = "Chaves de registro atualizadas. Deseja reiniciar o PC agora?"
        'BtnRestart'    = "Reiniciar PC"
        'Error'         = "Falha ao Desativar"
        'ErrorDetail'   = "N" + [char]0x00E3 + "o foi poss" + [char]0x00ED + "vel modificar as chaves do registro."
    }
    'es-ES' = @{
        'Title'         = "GESTOR AMD ULPS"
        'Subtitle'      = "Gestione Ultra Low Power State para gr" + [char]0x00E1 + "ficas AMD"
        'SysStatus'     = "ESTADO DEL SISTEMA"
        'NoGpu'         = "GPU AMD No Encontrada"
        'NoGpuDetail'   = "No se encontraron claves de registro de AMD ULPS en este equipo."
        'Disabled'      = "ULPS est" + [char]0x00E1 + " Desactivado"
        'DisabledDetail'= "AMD Ultra Low Power State ya est" + [char]0x00E1 + " inactivo en su sistema."
        'Active'        = "ULPS est" + [char]0x00E1 + " Activo"
        'ActiveDetail'  = "Se encontr" + [char]0x00F3 + "/aron {0} entrada(s) activa(s). Desactivarlo puede mejorar la estabilidad."
        'BtnDisable'    = "Desactivar ULPS"
        'BtnClose'      = "Cerrar"
        'Success'       = [char]0x00A1 + "ULPS Desactivado con " + [char]0x00C9 + "xito!"
        'SuccessDetail' = [char]0x00BF + "Desea reiniciar el equipo ahora?"
        'BtnRestart'    = "Reiniciar PC"
        'Error'         = "Error al Desactivar"
        'ErrorDetail'   = "No se pudieron modificar las claves del registro."
    }
    'zh-CN' = @{
        # Chinese strings are built entirely from verified Unicode code points.
        'Title'         = "AMD ULPS " + [char]0x7981 + [char]0x7528 + [char]0x5DE5 + [char]0x5177                                    # "AMD ULPS Disable Tool"
        'Subtitle'      = [char]0x7BA1 + [char]0x7406 + " AMD " + [char]0x663E + [char]0x5361 + [char]0x7684 + " Ultra Low Power State" # "Manage the Ultra Low Power State of AMD graphics"
        'SysStatus'     = [char]0x7CFB + [char]0x7EDF + [char]0x72B6 + [char]0x6001                                                   # "System Status"
        'NoGpu'         = [char]0x672A + [char]0x627E + [char]0x5230 + " AMD " + [char]0x663E + [char]0x5361                          # "No AMD GPU Found"
        'NoGpuDetail'   = [char]0x5728 + [char]0x6B64 + [char]0x8BA1 + [char]0x7B97 + [char]0x673A + [char]0x4E0A + [char]0x672A + [char]0x68C0 + [char]0x6D4B + [char]0x5230 + " AMD ULPS " + [char]0x6CE8 + [char]0x518C + [char]0x8868 + [char]0x9879 + [char]0x3002 # "No AMD ULPS registry key detected on this computer."
        'Disabled'      = "ULPS " + [char]0x5DF2 + [char]0x7981 + [char]0x7528                                                        # "ULPS is Disabled"
        'DisabledDetail'= "AMD Ultra Low Power State " + [char]0x5728 + [char]0x60A8 + [char]0x7684 + [char]0x7CFB + [char]0x7EDF + [char]0x4E2D + [char]0x5DF2 + [char]0x5904 + [char]0x4E8E + [char]0x975E + [char]0x6D3B + [char]0x52A8 + [char]0x72B6 + [char]0x6001 + [char]0x3002 # "...is already inactive on your system."
        'Active'        = "ULPS " + [char]0x5F53 + [char]0x524D + [char]0x5904 + [char]0x4E8E + [char]0x542F + [char]0x7528 + [char]0x72B6 + [char]0x6001 # "ULPS is Active"
        'ActiveDetail'  = [char]0x627E + [char]0x5230 + " {0} " + [char]0x4E2A + [char]0x6D3B + [char]0x52A8 + [char]0x6CE8 + [char]0x518C + [char]0x8868 + [char]0x9879 + [char]0x3002 + [char]0x7981 + [char]0x7528 + [char]0x5B83 + [char]0x53EF + [char]0x4EE5 + [char]0x63D0 + [char]0x9AD8 + [char]0x7CFB + [char]0x7EDF + [char]0x7A33 + [char]0x5B9A + [char]0x6027 + [char]0x3002 # "Found {0} active registry entries. Disabling can improve stability."
        'BtnDisable'    = [char]0x7981 + [char]0x7528 + " ULPS"                                                                        # "Disable ULPS"
        'BtnClose'      = [char]0x5173 + [char]0x95ED                                                                                  # "Close"
        'Success'       = [char]0x5DF2 + [char]0x6210 + [char]0x529F + [char]0x7981 + [char]0x7528 + " ULPS!"                          # "Successfully Disabled ULPS!"
        'SuccessDetail' = [char]0x6CE8 + [char]0x518C + [char]0x8868 + [char]0x9879 + [char]0x5DF2 + [char]0x66F4 + [char]0x65B0 + [char]0x3002 + [char]0x60A8 + [char]0x60F3 + [char]0x73B0 + [char]0x5728 + [char]0x91CD + [char]0x542F + [char]0x5417 + "?" # "Registry updated. Restart now?"
        'BtnRestart'    = [char]0x91CD + [char]0x542F + " PC"                                                                          # "Restart PC"
        'Error'         = [char]0x7981 + [char]0x7528 + [char]0x5931 + [char]0x8D25                                                    # "Failed to Disable"
        'ErrorDetail'   = [char]0x65E0 + [char]0x6CD5 + [char]0x4FEE + [char]0x6539 + [char]0x6CE8 + [char]0x518C + [char]0x8868 + [char]0x9879 + [char]0x3002 # "Could not modify registry keys."
    }
}

# ==========================================
# 2b. LANGUAGE SELECTOR DISPLAY NAMES
#     (built via [char] codes so the combo box never
#     depends on the source file's byte encoding)
# ==========================================
$script:LangNameEN = "English"
$script:LangNamePT = "Portugu" + [char]0x00EA + "s"
$script:LangNameES = "Espa" + [char]0x00F1 + "ol"
$script:LangNameZH = [char]0x4E2D + [char]0x6587

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
                <TextBlock Name="TxtSubtitle" Text="Manage Ultra Low Power State for AMD Graphics" FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0"/>
            </StackPanel>

            <ComboBox Name="CmbLanguage" Grid.Column="1" Width="110" Height="28" VerticalAlignment="Top"
                      Background="#1E293B" Foreground="#F8FAFC" BorderBrush="#334155" FontSize="12"
                      SelectedIndex="0">
                <ComboBox.Resources>
                    <!-- Explicit contrast colors for the dropdown items: readable text
                         in normal, highlighted (hover) and selected states, avoiding
                         the near-invisible default system colors on a dark theme. -->
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
                <ComboBoxItem Content="$LangNameEN" Tag="en-US" IsSelected="True"/>
                <ComboBoxItem Content="$LangNamePT" Tag="pt-BR"/>
                <ComboBoxItem Content="$LangNameES" Tag="es-ES"/>
                <ComboBoxItem Content="$LangNameZH" Tag="zh-CN"/>
            </ComboBox>
        </Grid>

        <!-- Status Card -->
        <Border Grid.Row="1" Background="#1E293B" CornerRadius="12" Padding="20" VerticalAlignment="Center">
            <StackPanel Name="StatusPanel">
                <TextBlock Name="TxtSysStatus" Text="SYSTEM STATUS" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,8"/>
                <TextBlock Name="TxtStatus" Text="..." FontSize="16" FontWeight="SemiBold" Foreground="#FACC15"/>
                <TextBlock Name="TxtDetail" Text="..." FontSize="12" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,6,0,0"/>
            </StackPanel>
        </Border>

        <!-- Action Buttons -->
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,20,0,0">
            <Button Name="BtnAction" Content="Disable ULPS" Width="140" Height="38" Margin="0,0,10,0"
                    Background="#0284C7" Foreground="White" FontWeight="Bold" FontSize="13" BorderThickness="0" Cursor="Hand" IsEnabled="False">
                <Button.Resources>
                    <Style TargetType="Border">
                        <Setter Property="CornerRadius" Value="8"/>
                    </Style>
                </Button.Resources>
                <Button.Style>
                    <!-- Overrides WPF's default washed-out disabled-button text color,
                         which is nearly unreadable on the blue background. -->
                    <Style TargetType="Button">
                        <Setter Property="Opacity" Value="1"/>
                        <Style.Triggers>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Background" Value="#1E293B"/>
                                <Setter Property="Foreground" Value="#94A3B8"/>
                                <Setter Property="BorderBrush" Value="#334155"/>
                            </Trigger>
                        </Style.Triggers>
                    </Style>
                </Button.Style>
            </Button>
            
            <Button Name="BtnClose" Content="Close" Width="90" Height="38"
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

# Render XAML Window using UTF-8 Stream Reader
$bytes = [System.Text.Encoding]::UTF8.GetBytes($xaml.OuterXml)
$stream = New-Object System.IO.MemoryStream(,$bytes)
$Window = [Windows.Markup.XamlReader]::Load($stream)

# Element References
$TxtTitle     = $Window.FindName("TxtTitle")
$TxtSubtitle  = $Window.FindName("TxtSubtitle")
$TxtSysStatus = $Window.FindName("TxtSysStatus")
$TxtStatus    = $Window.FindName("TxtStatus")
$TxtDetail    = $Window.FindName("TxtDetail")
$BtnAction    = $Window.FindName("BtnAction")
$BtnClose     = $Window.FindName("BtnClose")
$CmbLanguage  = $Window.FindName("CmbLanguage")

# ==========================================
# 3b. AUTOMATIC LANGUAGE DETECTION
#     Detects the Windows display language (UI culture) and pre-selects
#     the matching entry in the combo box. Falls back to English whenever
#     the detected language isn't one of the four supported locales, or
#     detection fails for any reason. The user can still change it manually.
# ==========================================
function Get-PreferredLanguageTag {
    try {
        $uiCulture = [System.Globalization.CultureInfo]::CurrentUICulture.Name  # e.g. "pt-BR", "es-MX", "zh-Hans-CN"
    } catch {
        $uiCulture = "en-US"
    }

    switch -Wildcard ($uiCulture) {
        "pt*" { return "pt-BR" }   # pt-BR, pt-PT, etc.
        "es*" { return "es-ES" }   # es-ES, es-MX, es-AR, etc.
        "zh*" { return "zh-CN" }   # zh-CN, zh-Hans, zh-TW, zh-Hant, etc.
        default { return "en-US" }
    }
}

$script:detectedLangTag = Get-PreferredLanguageTag

$itemToSelect = $CmbLanguage.Items | Where-Object { $_.Tag -eq $script:detectedLangTag } | Select-Object -First 1
if ($itemToSelect) {
    $CmbLanguage.SelectedItem = $itemToSelect
} else {
    # Safety net: language not supported or detection failed -> default to English
    $CmbLanguage.SelectedIndex = 0
}

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
