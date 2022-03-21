$fqdn = Get-ADDomain
$fulldomain = $fqdn.DNSRoot
$domain = $fulldomain.split(".")
$Dom = $domain[0]
$Ext = $domain[1]

# The purpose is to ensure that all Administrator Accounts have the configuration flag "this account is sensitive and cannot be delegated"
Get-ADGroupMember -Identity "Domain Admins" | Set-ADUser -AccountNotDelegated $true

#Recyble bin
Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target ESN.dom

# The purpose is to ensure that all privileged accounts are in the Protected User security group
Get-ADGroupMember -Identity  "Domain Admins" | Add-ADPrincipalGroupMembership -MemberOf  "Protected Users"

# The purpose is to ensure that the operator groups, which can have indirect control to the domain, are empty
foreach ($GroupOperators in $($(Get-ADGroup -LDAPFilter "(cn=*Operators)" -SearchBase "CN=Builtin,DC=$Dom,DC=$Ext").SamAccountName)) {
    foreach ($user in $($(Get-ADGroupMember -Identity $GroupOperators).SamAccountName)) {
        Remove-ADGroupMember  -Identity $GroupOperators -Members $user 
    }
}

Get-ADGroup -LDAPFilter "(cn=*Operators)" -SearchBase "CN=Builtin,DC=$Dom,DC=$Ext" | Get-ADGroupMember 