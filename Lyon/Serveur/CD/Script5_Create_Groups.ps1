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
<#
foreach($site in $sites){
    Write-Host "Creations des groupes Globaux et Groupes de Domaines Locaux" -ForegroundColor Magenta
    Write-Host ""

    foreach ($item in $services) {
            $i=$item.Replace(" ","_")
    
            Write-Host "Creation des groupes de Domaine Locaux DL_$i`_$site`_L , DL_$i`_$site`_LM DL_$i`_$site`_CT pour le service $i du site $site" -ForegroundColor Magenta
            Write-Host ""
            
            New-ADGroup -Name  "DL_$i`_$site`_L" -DisplayName  "DL_$i`_$site`_L" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture"

            New-ADGroup -Name  "DL_$i`_$site`_LM" -DisplayName  "DL_$i`_$site`_LM" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture et Modification"

            New-ADGroup -Name  "DL_$i`_$site`_CT" -DisplayName  "DL_$i`_$site`_CT" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Domaine Locaux $i Controle Totale"
    }
    Write-Host "Creation des groupes de Domaine Locaux DL_$site`_L , DL_$site`_LM DL_$site`_CT pour le site $site" -ForegroundColor Magenta
    
    New-ADGroup -Name  "DL_$site`_L" -DisplayName  "DL_$site`_L" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $site Lecture"

    New-ADGroup -Name  "DL_$site`_LM" -DisplayName  "DL_$site`_LM" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $site Lecture et Modification"

    New-ADGroup -Name  "DL_$site`_CT" -DisplayName  "DL_$site`_CT" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Domaine Locaux $site Controle Totale"
}


#>

New-ADGroup -Name  "DL_Total_Ressources" -DisplayName  "DL_Total_Ressources" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"
Get-ADGroup -LDAPFilter "(cn= G_Responsables*)" | Add-ADPrincipalGroupMembership -MemberOf  "DL_Total_Ressources"
Get-ADGroup -LDAPFilter "(cn= G_*_Direction)"| Add-ADPrincipalGroupMembership -MemberOf  "DL_Total_Ressources"

New-ADGroup -Name  "DL_Lecture_Ressources" -DisplayName  "DL_Lecture_Ressources" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" 
Get-ADGroup -LDAPFilter "(cn= G_*_Administration)" | Add-ADPrincipalGroupMembership -MemberOf  "DL_Lecture_Ressources"
Get-ADGroup -LDAPFilter "(cn= G_*_Accueil)" | Add-ADPrincipalGroupMembership -MemberOf  "DL_Lecture_Ressources"
Get-ADGroup -LDAPFilter "(cn= G_*_Informatique)"| Add-ADPrincipalGroupMembership -MemberOf  "DL_Lecture_Ressources"

New-ADGroup -Name  "DL_Refuser_Ressources" -DisplayName  "DL_Refuser_Ressources" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" 
Get-ADGroup -LDAPFilter "(cn= G_*_Recherche_et_Developpement)"| Add-ADPrincipalGroupMembership -MemberOf  "DL_Refuser_Ressources"

Get-ADUser -LDAPFilter "(&(title=Manager*)(department=Informatique))"  | Add-ADPrincipalGroupMembership -MemberOf "Domain Admins"

$Groups = ("Print Operators","Server Operators", "Account Operators", "Backup Operators")
foreach ($Group in $Groups) {
    $(Get-ADUser -LDAPFilter "(&(title=Employé*)(department=Informatique))")[0] | Add-ADPrincipalGroupMembership -MemberOf "$Group"
}

$Groups = ("Event Log Readers","Performance Monitor Users", "Performance Log Users")
foreach ($Group in $Groups) {
    $(Get-ADUser -LDAPFilter "(&(title=Employé*)(department=Informatique))")[1] | Add-ADPrincipalGroupMembership -MemberOf "$Group"
}
