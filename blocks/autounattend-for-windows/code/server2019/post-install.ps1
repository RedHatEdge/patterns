Set-PSDebug -Trace 1
#####################################
# Perform some basic configurations #
#####################################

Write-Host "Performing some basic configurations"
# Configure legacy control panel view
Start-Process reg -Wait -ArgumentList 'add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v StartupPage /t REG_DWORD /d 1 /f'
# Modify control panel icon size
Start-Process reg -Wait -ArgumentList 'add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v AllItemsIconView /t REG_DWORD /d 0 /f'
# Remove automatic admin login
Start-Process reg -Wait -ArgumentList 'add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 0 /f'
# Disable Windows SmartScreen Filter
Start-Process reg -Wait -ArgumentList 'add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 0 /f'
# Prevent password expiration
Start-Process wmic -Wait -ArgumentList 'useraccount where name="Administrator" set PasswordExpires=false'

Write-Host "Installing additional drivers"
# Install all remaining VirtIO drivers
Start-Process msiexec -Wait -ArgumentList "/i E:\virtio-win-gt-x64.msi /qn /passive /norestart ADDLOCAL=FE_balloon_driver,FE_network_driver,FE_vioinput_driver,FE_viorng_driver,FE_vioscsi_driver,FE_vioserial_driver,FE_viostor_driver,FE_viofs_driver,FE_viogpudo_driver"
# Install qemu Guest Agent
Start-Process msiexec -Wait -ArgumentList "/i E:\guest-agent\qemu-ga-x86_64.msi /qn /passive /norestart"

Write-Host "Enabling RDP"
# Enable RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
# Disable NLA
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -value 0
# Open firewall ports
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

{{ if .Values.postInstallPowershell }}
#####################################
# Perform custom post-install steps #
#####################################

Write-Host "Performing custom setup"
{{- tpl .Values.postInstallPowershell $ | nindent 4 }}
{{ end }}

####################################
#     Enable WinRM for Ansible     #
####################################

# Enable PSRemoting
Write-Host "Enabling WinRM service"
Enable-PSRemoting -Force

# Allow unencrypted traffic
Write-Host "Allowing unencrypted traffic"
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true

# Enable Basic Authentication
Write-Host "Enabling Basic Authentication"
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true

# Set the WinRM service to start automatically
Write-Host "Set WinRM service to start automatically"
Set-Service -Name WinRM -StartupType Automatic

# Start the WinRM service
Write-Host "Start WinRM service"
Start-Service -Name WinRM

# Configure firewall to allow WinRM traffic
Write-Host "Configuring firewall"
netsh advfirewall firewall add rule name="Allow WinRM HTTP" dir=in action=allow protocol=TCP localport=5985

# Dump listener config
Write-Host "Dump listener config"
winrm enumerate winrm/config/listener

# Let output be confirmed
Start-Sleep -s 10

#####################################
# Finalize installation via sysprep #
#####################################

Write-Host "Finalizaing"
# Prevent picking up old autounattend.xml
mv C:\Windows\Panther\unattend.xml C:\Windows\Panther\unattend.install.xml
# Eject disk to prevent additional sysprep pickup
(New-Object -COM Shell.Application).NameSpace(17).ParseName('F:').InvokeVerb('Eject')
# Perform full sysprep
# C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown /mode:vm
# Just shut down
Start-Process shutdown -ArgumentList '/s /f /t 5'