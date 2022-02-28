Install-Module PSWriteWord 
Import-Module PSWriteWord

function New-Password
{

   $Alphabets = 'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z'
    $numbers = 0..9
    $specialCharacters = '~,!,@,#,$,%,^,&,*,(,),>,<,?,\,/,_,-,=,+'
    $array = @()
    $array += $Alphabets.Split(',') | Get-Random -Count 4
    $array[0] = $array[0].ToUpper()
    $array[-1] = $array[-1].ToUpper()
    $array += $numbers | Get-Random -Count 3
    $array += $specialCharacters.Split(',') | Get-Random -Count 3
    ($array | Get-Random -Count $array.Count) -join ""
}

function New-RandomUser {
    <#
        .SYNOPSIS
            Generate random user data from Https://randomuser.me/.
        .DESCRIPTION
            This function uses the free API for generating random user data from https://randomuser.me/
        .EXAMPLE
            Get-RandomUser 10
        .EXAMPLE
            Get-RandomUser -Amount 25 -Nationality us,gb 
        .LINK
            https://randomuser.me/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(1,500)]
        [int] $Amount,

        [Parameter()]
        [ValidateSet('Male','Female')]
        [string] $Gender,

        # Supported nationalities: AU, BR, CA, CH, DE, DK, ES, FI, FR, GB, IE, IR, NL, NZ, TR, US
        [Parameter()]
        [string[]] $Nationality,


        [Parameter()]
        [ValidateSet('json','csv','xml')]
        [string] $Format = 'json',

        # Fields to include in the results.
        # Supported values: gender, name, location, email, login, registered, dob, phone, cell, id, picture, nat
        [Parameter()]
        [string[]] $IncludeFields,

        # Fields to exclude from the the results.
        # Supported values: gender, name, location, email, login, registered, dob, phone, cell, id, picture, nat
        [Parameter()]
        [string[]] $ExcludeFields
    )

    $rootUrl = "http://api.randomuser.me/?format=$($Format)"

    if ($Amount) {
        $rootUrl += "&results=$($Amount)"
    }

    if ($Gender) {
        $rootUrl += "&gender=$($Gender)"
    }


    if ($Nationality) {
        $rootUrl += "&nat=$($Nationality -join ',')"
    }

    if ($IncludeFields) {
        $rootUrl += "&inc=$($IncludeFields -join ',')"
    }

    if ($ExcludeFields) {
        $rootUrl += "&exc=$($ExcludeFields -join ',')"
    }
    
    Invoke-RestMethod -Uri $rootUrl
}

#region declarations des variables
# Recuperations des informations du domaine AD
$fqdn = Get-ADDomain
$fulldomain = $fqdn.DNSRoot
$domain = $fulldomain.split(".")
$Dom = $domain[0]
$Ext = $domain[1]

# Informations des Sites et Services
$sites=('Lyon','Paris')
$services=('Informatique','Direction','Recherche et Developpement','Administration','Accueil','Ressources Humaines','Serveurs')
$materiels=('Ordinateurs Fixes','Ordinateurs Portables','Imprimantes')
$FirstOU ="Sites"
[byte[]]$horaire = @(0,0,128,255,255,255,255,255,255,255,255,255,255,255,255,255,255,127,0,0,0)

#endregions
$sw = [Diagnostics.Stopwatch]::StartNew()

New-ADOrganizationalUnit -Name $FirstOU -Description $FirstOU  -Path "DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

foreach ($S in $sites) {
    New-ADOrganizationalUnit -Name $S -Description "$S"  -Path "OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

    foreach ($Serv in $services) {
        New-ADOrganizationalUnit -Name $Serv -Description "$S $Serv"  -Path "OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

        
            New-ADOrganizationalUnit -Name "Materiels" -Description "$S $Serv Materiels"  -Path "OU=$Serv,OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
            foreach ($Materiel in $materiels) {
                New-ADOrganizationalUnit -Name $Materiel -Description "$S $Serv $Materiel"  -Path "OU=Materiels,OU=$Serv,OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
            }
            
            $Employees = New-RandomUser -Amount 30 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

            foreach ($user in $Employees) 
            {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                                CannotChangePassword = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }

                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                            # Hour : Connection during the week-end are forbiden 
                            Set-ADUser -Identity $($newUserProperties.SamAccountName)  -Replace:@{logonHours=$horaire}
            }

            $Manager = New-RandomUser -Amount 2 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

            foreach ($user in $Manager) 
            {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Manager $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                                CannotChangePassword = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Manager"))
                            {
                                New-Item -Path "c:\$S\$Serv\Manager" -ItemType Directory | Out-Null
                            }

                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Manager\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
            }
    }
}

Write-Host "Nous avons créer  Utilisateurs et $OU OU soit $Object Objects. "
$sw.stop
$sw.Elapsed