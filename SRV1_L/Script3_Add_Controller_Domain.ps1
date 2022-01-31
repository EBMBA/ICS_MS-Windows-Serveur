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

$DomainConfiguration = @{
    '-DatabasePath'= 'C:\Windows\NTDS';
    '-DomainName' = $DomainNameDNS;
    '-NoGlobalCatalog' = $false;
    '-SiteName' = 'Default-First-Site-Name';
    '-CriticalReplicationOnly' =$false;
    '-InstallDns' = $true;
    '-LogPath' = 'C:\Windows\NTDS';
    '-NoRebootOnCompletion' = $false;
    '-Readonlyreplica' = $true;
    '-ReplicationSourceDC' = 'CD.ESN.dom';
    '-SysvolPath' = 'C:\Windows\SYSVOL';
    '-Force' = $true;
    '-CreateDnsDelegation' = $false }

Import-Module ADDSDeployment
Install-ADDSDomainController @DomainConfiguration  -Credential (Get-Credential $DomaineNameNetbios\Administrator)