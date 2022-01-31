$IPAddress = "172.31.2.1"
$Prefix = "24"
$Gateway = "172.31.2.254"
$IPAddressDNS = "127.0.0.1"

New-NetIPAddress -IPAddress $IPAddress -PrefixLength $Prefix -InterfaceIndex (Get-NetAdapter).ifIndex -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).ifIndex -ServerAddresses ($IPAddressDNS)