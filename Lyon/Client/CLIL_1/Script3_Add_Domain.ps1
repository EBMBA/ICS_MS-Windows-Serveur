$DomainNameDNS = "ESN.dom"
$DomaineNameNetbios = "ESN"

Add-Computer -DomainName $DomainNameDNS -Credential (Get-Credential $DomaineNameNetbios\Administrator)