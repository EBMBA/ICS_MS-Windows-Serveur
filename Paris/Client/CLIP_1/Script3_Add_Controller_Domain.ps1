$DomainNameDNS = "ESN.dom"
$DomaineNameNetbios = "ESN"
$FeatureList = @("RSAT-AD-Tools","AD-Domain-Services","DNS")

Foreach($Feature in $FeatureList){

   if(((Get-WindowsFeature -Name $Feature).InstallState)-eq"Available"){

     Write-Output "Feature $Feature will be installed now !"

     Try{

        Add-WindowsFeature -Name $Feature -IncludeManagementTools -IncludeAllSubFeature

        Write-Output "$Feature : Installation is a success !"

     }Catch{

        Write-Output "$Feature : Error during installation !"
     }
   } 
} # Foreach($Feature in $FeatureList)

Import-Module ADDSDeployment
Install-ADDSDomainController -Credential (Get-Credential $DomaineNameNetbios\Administrator) -DomainName $DomainNameDNS -InstallDNS:$true -ReadOnlyReplica:$true -SiteName "Default-First-Site-Name" -Force:$true