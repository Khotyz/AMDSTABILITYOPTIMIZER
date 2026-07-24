<#
.SYNOPSIS
    Modern WPF Graphical Interface to check and disable AMD ULPS (Ultra Low Power State).
.DESCRIPTION
    Launches a clean, dark-themed UI window. Auto-elevates to Admin if needed.
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
# 2. XAML INTERFACE DESIGN
# ==========================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AMD ULPS Manager" Height="360" Width="480"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        Background="#0F172A" Foreground="#F8FAFC" FontFamily="Segoe UI">
    <Grid Margin="24">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <StackPanel Grid.Row="0" Margin="0,0,0,20">
            <TextBlock Text="AMD ULPS DISABLER" FontSize="20" FontWeight="Bold" Foreground="#38BDF8"/>
            <TextBlock Text="Manage Ultra Low Power State for AMD Graphics" FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0"/>
        </StackPanel>

        <!-- Status Card -->
        <Border Grid.Row="1" Background="#1E293B" CornerRadius="12" Padding="20" VerticalAlignment="Center">
            <StackPanel Name="StatusPanel">
                <TextBlock Text="SYSTEM STATUS" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,8"/>
                <TextBlock Name="TxtStatus" Text="Checking ULPS Status..." FontSize="16" FontWeight="SemiBold" Foreground="#FACC15"/>
                <TextBlock Name="TxtDetail" Text="Scanning Windows Registry for active AMD display adapters..." FontSize="12" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,6,0,0"/>
            </StackPanel>
        </Border>

        <!-- Action Buttons -->
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,20,0,0">
            <Button Name="BtnAction" Content="Disable ULPS" Width="130" Height="38" Margin="0,0,10,0"
                    Background="#0284C7" Foreground="White" FontWeight="Bold" FontSize="13" BorderThickness="0" Cursor="Hand" IsEnabled="False">
                <Button.Resources>
                    <Style TargetType="Border">
                        <Setter Property="CornerRadius" Value="8"/>
                    </Style>
                </Button.Resources>
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

# Render XAML Window
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Element References
$TxtStatus = $Window.FindName("TxtStatus")
$TxtDetail = $Window.FindName("TxtDetail")
$BtnAction = $Window.FindName("BtnAction")
$BtnClose  = $Window.FindName("BtnClose")

# ==========================================
# 3. ULPS DETECTION LOGIC
# ==========================================
function Get-ULPSKeys {
    Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Recurse -ErrorAction SilentlyContinue |
    Get-ItemProperty -Name "EnableUlps" -ErrorAction SilentlyContinue
}

$script:ulpsKeys = Get-ULPSKeys
$script:activeKeys = $script:ulpsKeys | Where-Object { $_.EnableUlps -eq 1 }

if (-not $script:ulpsKeys) {
    $TxtStatus.Text = "No AMD GPU Found"
    $TxtStatus.Foreground = "#EF4444"
    $TxtDetail.Text = "No AMD ULPS registry keys were detected on this computer."
} elseif ($script:activeKeys.Count -eq 0) {
    $TxtStatus.Text = "ULPS is Disabled"
    $TxtStatus.Foreground = "#22C55E"
    $TxtDetail.Text = "AMD Ultra Low Power State is already inactive on your system."
} else {
    $TxtStatus.Text = "ULPS is Active"
    $TxtStatus.Foreground = "#FACC15"
    $TxtDetail.Text = "Found $($script:activeKeys.Count) active registry entry/entries. Disabling it can improve system stability."
    $BtnAction.IsEnabled = $true
}

# ==========================================
# 4. BUTTON EVENTS & ACTIONS
# ==========================================
$BtnAction.Add_Click({
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
        $TxtStatus.Text = "ULPS Disabled Successfully!"
        $TxtStatus.Foreground = "#22C55E"
        $TxtDetail.Text = "Registry entries updated. Would you like to restart your PC now?"
        $BtnAction.Content = "Restart PC"
        $BtnAction.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#DC2626")
        
        # Switch button functionality to restart system
        $BtnAction.Remove_Click($_)
        $BtnAction.Add_Click({
            Restart-Computer -Force
        })
    } else {
        $TxtStatus.Text = "Failed to Disable"
        $TxtStatus.Foreground = "#EF4444"
        $TxtDetail.Text = "Could not modify registry keys."
        $BtnAction.IsEnabled = $false
    }
})

$BtnClose.Add_Click({
    $Window.Close()
})

# Show UI Window
$Window.ShowDialog() | Out-Null
