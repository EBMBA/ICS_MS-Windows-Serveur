# Installer le service DHCP :
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# Créer un security group :
netsh dhcp add securitygroups 
Restart-Service dhcpserver 

# Vérification de l'existence du serveur DHCP dans le DC : 
Get-DhcpServerInDC

$Scopes = @{
    sites = @{
        'Lyon' = @{
            Mask = "255.255.255.0"
            Network = "172.31.1.0"
            StartRange = "172.31.1.100"
            EndRange = "172.31.1.253"
            Gateway = "172.31.1.254"
        }
        'Paris' = @{
            Mask = "255.255.255.0"
            Network = "172.31.2.0"
            StartRange = "172.31.2.100"
            EndRange = "172.31.2.253"
            Gateway = "172.31.2.254" 
        }
    }
    AdresseDNS = "172.31.2.1"
    NameDomain = "ESN.dom"
}


foreach ($item in $Scopes.sites.Keys) {
    Add-DHCPServerv4Scope -Name $Scopes.sites.$item -StartRange $Scopes.sites.$item.StartRange -EndRange $Scopes.sites.$item.EndRange -SubnetMask $Scopes.sites.$item.Mask -State Active
    Set-DHCPServerv4OptionValue -ScopeID $Scopes.sites.$item.Network  -DnsDomain $Scopes.NameDomain -DnsServer $Scopes.AdresseDNS -Router $Scopes.sites.$item.Gateway
    Add-DhcpServerInDC -DnsName $Scopes.NameDomain -IpAddress $Scopes.AdresseDNS
}

Get-DhcpServerv4Scope
Restart-service dhcpserver