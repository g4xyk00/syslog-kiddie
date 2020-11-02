cls
$ErrorActionPreference = 'SilentlyContinue'
$syslogIP = '10.0.8.193'
$udpClient = New-Object System.Net.Sockets.UdpClient
$UDPCLient.Connect($syslogIP, 514)
$hostname= $env:computername
$time = Get-Date -Format "MMM dd HH:mm:ss"
$priority = 4 #Warning

# SYSTEM
# 104 - The Application or System log was cleared
# 7045 - A service was installed in the system

# SECURITY
# 1102 - The audit log was cleared
# 2003 - Disable firewall
# 4698 - A scheduled task was created
# 4720 - A user account was created
# 4728 - A user was assigned with Administrator rights

function Get-EventLogDetails {
    param (
        [string] $EventType,
        [string[]] $EventId
    )
    
    ForEach ($id in $EventId) {
        $today = $(Get-Date).AddDays(-1) #-1 equal to 1 day
        $securityLog = Get-EventLog $EventType -After $today | where {$_.EventID -eq $id}
        
        if($securityLog -ne $null){
            ForEach ($log in $securityLog) {
                $log_time = ($log.TimeGenerated).tostring()
                $log_msg = $log.Message.split("`n")
                $msg = 'Windows Logs: ' + $log_time + "|" + $id + "|" + $log_msg 
                $record = "<{0}>{1} {2} {3}" -f $priority, $time, $hostname, $msg
                $encode = [System.Text.Encoding]::ASCII
                $byte = $encode.GetBytes($record)
                $UDPCLient.Send($byte, $byte.Length)
            }
        }
        
    }
}

Get-EventLogDetails -EventType "Security" -EventId 1102,2003,4698,4720,4728 | Out-Null
Get-EventLogDetails -EventType "System" -EventId 104,7045 | Out-Null