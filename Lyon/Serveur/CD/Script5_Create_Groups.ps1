# Informations des Sites et Services
$sites=('Lyon','Paris')
$services=('Informatique','Direction','Recherche et Developpement','Administration','Accueil','Ressources Humaines')
$fqdn = Get-ADDomain
$fulldomain = $fqdn.DNSRoot
$domain = $fulldomain.split(".")
$Dom = $domain[0]
$Ext = $domain[1]


Write-Host "Creations des OU pour les groupes" -ForegroundColor Magenta
Write-Host ""

New-ADOrganizationalUnit -Name "Groupes" -Description "Groupes du Domaine" -Path "OU=Sites,DC=$Dom,DC=$Ext" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Globaux" -Description "Groupes Globaux" -Path "OU=Groupes,OU=Sites,DC=$Dom,DC=$Ext" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Domaines Locaux" -Description "Groupes de Domaines Locaux"  -Path "OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

foreach($site in $sites){
    Write-Host "Creations des groupes Globaux et Groupes de Domaines Locaux" -ForegroundColor Magenta
    Write-Host ""

    foreach ($item in $services) {
            $i=$item.Replace(" ","_")
    
            Write-Host "Creation des groupes Globaux G_$I , G_Employes_$I et G_Responsable_$I le service $i" -ForegroundColor Magenta
            Write-Host ""
            
            New-ADGroup -Name "G_$site`_$i" -DisplayName "G_$site`_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global $i"
            Get-ADUser -LDAPFilter "(&(title=*$item)(l=$site))" | Add-ADPrincipalGroupMembership -MemberOf "G_$site`_$i"

            New-ADGroup -Name "G_Employes_$site`_$i" -DisplayName "G_Employes_$site`_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global Employes $i"
            Get-ADUser -LDAPFilter "(&(title=Employé $item)(l=$site))"  | Add-ADPrincipalGroupMembership -MemberOf "G_Employes_$site`_$i"

            New-ADGroup -Name "G_Responsables_$site`_$i" -DisplayName "G_Responsables_$site`_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global Responsables $i"
            Get-ADUser -LDAPFilter "(&(title=Manager*)(l=$site)(department=$item))"  | Add-ADPrincipalGroupMembership -MemberOf "G_Responsables_$site`_$i"
    }
}

New-ADGroup -Name "G_Responsables" -DisplayName "G_Responsables" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Responsable"
Get-ADUser -LDAPFilter "(title=Manager*)" | Add-ADPrincipalGroupMembership -MemberOf "G_Responsables"

New-ADGroup -Name "G_Employes" -DisplayName "G_Employes" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Employes"
Get-ADUser -LDAPFilter "(title=Employé*)"  | Add-ADPrincipalGroupMembership -MemberOf "G_Employes"  

