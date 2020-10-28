# syslog-kiddie

## Syslog Server
[Visual Syslog Server](https://github.com/MaxBelkov/visualsyslog/releases/)

## Test Syslog Connection

```powershell
$syslogIP = '192.168.127.56'
$udpClient = New-Object System.Net.Sockets.UdpClient
$UDPCLient.Connect($syslogIP, 514)
$hostname= $env:computername
$time = Get-Date -Format "MMM dd HH:mm:ss"

For ($i=0; $i -le 7; $i++) {
    $priority = $i
    $msg = 'Test Priority: ' + $i

    $record = "<{0}>{1} {2} {3}" -f $priority, $time, $hostname, $msg
    $encode = [System.Text.Encoding]::ASCII
    $byte = $encode.GetBytes($record)

    $UDPCLient.Send($byte, $byte.Length)
}
```
