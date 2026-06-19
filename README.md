# Resilient Sunshine Headless Windows Setup

A complete Windows configuration for a Sunshine host that starts automatically,
recovers from Sunshine crashes, and remains manageable remotely through Tailscale
and SSH.

## Security Tradeoff

This setup prioritizes unattended availability. Windows signs in automatically
and UAC is set to **Never notify**, so use it only for a dedicated computer in a
physically controlled location. Anyone with physical access may be able to reach
the signed-in desktop. Never publish your password, username, computer name,
Tailscale address, Sunshine credentials, certificates, or configuration files.

Replace values such as `<WINDOWS_USER>` and `<TAILSCALE_IP>` with values from your
own system.

## 1. Sunshine Installation

Install Sunshine in:

```text
C:\Sunshine
```

Required executable:

```text
C:\Sunshine\sunshine.exe
```

Sunshine web interface:

```text
https://localhost:47990
```

Configure Sunshine, pair Moonlight, and complete one successful local stream
before continuing.

Official Sunshine setup documentation:
https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2getting__started.html

## 2. Windows Automatic Sign-In

Automatic sign-in ensures that Windows reaches an interactive desktop after a
reboot.

Open Registry Editor as Administrator and go to:

```text
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
```

Create or verify these `REG_SZ` values for a Microsoft account:

```text
AutoAdminLogon     = 1
DefaultUserName   = <MICROSOFT_ACCOUNT_EMAIL>
DefaultPassword   = <WINDOWS_ACCOUNT_PASSWORD>
DefaultDomainName = MicrosoftAccount
```

If required on the system, also set:

```text
ForceAutoLogon = 1
```

For a local Windows account, use its username and the appropriate local computer
name instead of `MicrosoftAccount`.

The password stored for automatic sign-in must never be included in screenshots,
registry exports, logs, or a public repository.

Expected result:

- no PIN or password prompt after reboot
- Windows automatically loads the dedicated desktop

## 3. UAC Configuration

Set the UAC slider to:

```text
Never notify
```

Path:

```text
Control Panel -> User Accounts -> Change User Account Control settings
```

This avoids unattended startup or maintenance being blocked by an elevation
dialog. It also reduces local security, as described at the beginning of this
guide.

## 4. Sunshine Watchdog

Copy the supplied scripts beside `sunshine.exe`:

```text
scripts\sunshine-watchdog.ps1 -> C:\Sunshine\sunshine-watchdog.ps1
scripts\sunshine-watchdog.vbs -> C:\Sunshine\sunshine-watchdog.vbs
scripts\stop-watchdog.ps1     -> C:\Sunshine\stop-watchdog.ps1
```

The watchdog:

- allows only one watchdog instance
- checks every 15 seconds whether Sunshine is running
- starts Sunshine from the correct working directory
- writes its PID to `C:\Sunshine\watchdog.pid`
- records activity in `C:\Sunshine\watchdog.log`
- rotates the log at 1 MB
- removes its PID file when it exits cleanly

The supplied scripts determine the installation directory from their own
location. Keep them in the same directory as `sunshine.exe`.

## 5. Silent Startup Launcher

The VBS file launches the PowerShell watchdog invisibly and then exits. It does
not stop Sunshine.

Press `Win+R`, enter:

```text
shell:startup
```

Create a shortcut in the Startup folder:

```text
Target:   C:\Sunshine\sunshine-watchdog.vbs
Start in: C:\Sunshine
Name:     Sunshine Watchdog
```

Startup behavior:

```text
Windows signs in
-> Startup runs the VBS launcher
-> VBS starts PowerShell invisibly
-> PowerShell starts the watchdog
-> watchdog starts or maintains Sunshine
```

## 6. Tailscale Remote Network

Install Tailscale on the Windows host and on each trusted client. Sign the devices
into the same tailnet.

The host will have a private Tailscale address similar to:

```text
<TAILSCALE_IP>
```

Test it from the client:

```text
ping <TAILSCALE_IP>
```

Do not publish the real address. Do not forward Sunshine or SSH ports on the
internet router; remote access uses Tailscale.

Tailscale Windows installation documentation:
https://tailscale.com/kb/1347/installation

## 7. Windows OpenSSH Server

Run PowerShell as Administrator:

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service sshd -StartupType Automatic
```

The OpenSSH Server installation normally creates and enables the inbound rule
`OpenSSH-Server-In-TCP`. Verify it instead of creating a duplicate rule:

```powershell
Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP"
```

This rule makes SSH reachable on connected Windows networks, but it does not by
itself expose port 22 through the internet router. Do not configure router port
forwarding for SSH; connect through the host's Tailscale address.

Verify the service:

```powershell
Get-Service sshd
Get-NetTCPConnection -LocalPort 22 -State Listen
```

Expected service state:

```text
Status:    Running
StartType: Automatic
```

Microsoft OpenSSH documentation:
https://learn.microsoft.com/windows-server/administration/openssh/openssh-server-configuration

## 8. Remote SSH and Reboot

Connect from another device through Tailscale:

```text
ssh <WINDOWS_USER>@<TAILSCALE_IP>
```

Run a single remote command:

```text
ssh <WINDOWS_USER>@<TAILSCALE_IP> "<COMMAND>"
```

Check Sunshine and the watchdog:

```powershell
Get-Process sunshine -ErrorAction SilentlyContinue
Get-Content C:\Sunshine\watchdog.log -Tail 20
Get-Content C:\Sunshine\config\sunshine.log -Tail 50
```

Reboot immediately:

```text
ssh <WINDOWS_USER>@<TAILSCALE_IP> "shutdown /r /f /t 0"
```

After reboot:

```text
Windows boots
-> Tailscale and OpenSSH services start
-> Windows signs in automatically
-> Startup launches the watchdog
-> watchdog starts Sunshine
-> SSH and Moonlight become available again
```

## 9. Stop the Watchdog

Run:

```powershell
PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Sunshine\stop-watchdog.ps1
```

The stop script validates that the PID belongs to the Sunshine watchdog before
terminating it. It does not directly stop `sunshine.exe`.

## 10. Sunshine Certificate Permission Failure

If Sunshine launches and immediately closes, inspect its log:

```powershell
Get-Content C:\Sunshine\config\sunshine.log -Tail 100
```

If it reports:

```text
use_certificate_chain_file: Access is denied
```

run PowerShell as Administrator:

```powershell
$sunshineUser = '<COMPUTER_OR_DOMAIN>\<WINDOWS_USER>'
icacls 'C:\Sunshine\config\credentials\cacert.pem' /grant:r "${sunshineUser}:F"
icacls 'C:\Sunshine\config\credentials\cakey.pem' /grant:r "${sunshineUser}:F"
```

Then launch `C:\Sunshine\sunshine-watchdog.vbs` once. Grant access only to the
account that runs Sunshine.

## 11. Verification Checklist

After a reboot, verify:

- Windows signs in automatically
- no visible PowerShell window remains open
- `sunshine.exe` is running
- exactly one watchdog PowerShell process is active
- `C:\Sunshine\watchdog.pid` exists
- `C:\Sunshine\watchdog.log` shows the watchdog start
- Moonlight connects locally
- Moonlight connects through Tailscale
- SSH connects through Tailscale
- remote reboot completes and the host returns

Test crash recovery:

```powershell
Stop-Process -Name sunshine -Force
```

Sunshine should return within approximately 15 seconds.

## 12. Critical Dependencies

The setup can fail if:

- the Windows account password changes
- Sunshine is moved away from the script directory
- the watchdog files are removed or renamed
- the Startup shortcut is removed
- Tailscale is disabled or loses authorization
- the OpenSSH service is disabled
- the SSH firewall rule is removed
- Windows fails to create an interactive desktop session
- a Sunshine update changes file permissions

## 13. File Map

```text
C:\Sunshine\sunshine.exe
C:\Sunshine\sunshine-watchdog.ps1
C:\Sunshine\sunshine-watchdog.vbs
C:\Sunshine\stop-watchdog.ps1
C:\Sunshine\watchdog.pid
C:\Sunshine\watchdog.log
C:\Sunshine\watchdog.log.old
shell:startup\Sunshine Watchdog.lnk
```

## 14. Final System Capability

The completed machine operates as a:

- headless Sunshine and Moonlight streaming host
- self-recovering Sunshine process
- silent background startup system
- Tailscale-connected remote Windows machine
- SSH-manageable recovery host
- remotely rebootable unattended computer

## License

This guide and its scripts are released under the [MIT License](LICENSE).
