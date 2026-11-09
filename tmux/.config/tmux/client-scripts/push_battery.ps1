# push_battery.ps1
#
# Reads laptop battery and pushes it to your remote workstation via SSH.
# Runs as a self-looping background process — no admin or Task Scheduler needed.
#
# SETUP (one-time):
#   1. Replace $RemoteHost below with your SSH alias/hostname
#   2. Save this file somewhere, e.g. C:\Users\<you>\scripts\push_battery.ps1
#   3. Add it to your Windows Startup folder so it runs at every login:
#        a. Press Win+R, type: shell:startup, press Enter
#        b. Right-click > New > Shortcut
#        c. Target:
#             powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Users\<you>\scripts\push_battery.ps1"
#        d. Click OK — it will auto-start hidden on next login
#   4. To start it right now without rebooting, just double-click the shortcut
#
# HOW TO STOP IT:
#   Open Task Manager > Details tab > find powershell.exe > End Task
#   Or from PowerShell: Stop-Process -Id <process-id>
#
# REMOTE MACHINE NOT REACHABLE:
#   SSH calls use -o ConnectTimeout=5 and -o BatchMode=yes so they fail fast
#   and silently when the workstation is off or unreachable. The loop simply
#   skips that cycle and retries after $IntervalSeconds.
#
# SSH KEY AUTH (required — no password prompts in background):
#   If not set up yet, run in PowerShell:
#     ssh-keygen                          # generate key if you don't have one
#     ssh-copy-id <RemoteHost>            # copy public key to remote
#   Or manually append ~/.ssh/id_*.pub to ~/.ssh/authorized_keys on the remote.

param(
    [string]$RemoteHost      = "workstation",  # <-- change to your SSH host alias
    [int]$IntervalSeconds    = 60
)

while ($true) {
    try {
        $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction Stop

        if ($battery) {
            $pct    = $battery.EstimatedChargeRemaining
            # BatteryStatus 2 = Charging/Full; anything else = Discharging
            $status = if ($battery.BatteryStatus -eq 2) { "charging" } else { "discharging" }

            "$pct $status" | ssh `
                -o BatchMode=yes `
                -o ConnectTimeout=5 `
                -o StrictHostKeyChecking=accept-new `
                $RemoteHost "mkdir -p ~/.local/share && cat > ~/.local/share/laptop_battery.tmp && mv ~/.local/share/laptop_battery.tmp ~/.local/share/laptop_battery" `
                2>$null
        }
    }
    catch {
        # No battery detected or SSH error — skip silently, retry next cycle
    }

    Start-Sleep -Seconds $IntervalSeconds
}
