
<#PSScriptInfo

.VERSION 1.0

.GUID 2a8e7dbe-40cf-4b37-97d4-d8ef21be3be1

.AUTHOR Rodrigo Silva

.COMPANYNAME rdgo.dev

.COPYRIGHT (c) 2019 Rodrigo Silva. All rights reserved.

.TAGS IP, ipconfig

.LICENSEURI https://github.com/crodrigocs/Get-IPList/blob/master/LICENSE

.PROJECTURI https://github.com/crodrigocs/Get-IPList

.ICONURI

.EXTERNALMODULEDEPENDENCIES ActiveDirectory

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES Initial release


#>

<#

.DESCRIPTION
 This script runs ipconfig on local and remote computers and outputs the filtered list of IPs for each server.
.SYNOPSIS
 List IPs from remote servers
.LINK
 https://rdgo.dev
 https://github.com/crodrigocs/Get-IPList
.PARAMETER ComputerName
 Specify the computer or computers to be queried, separated by comma.
.PARAMETER OU
 Specify the Active Directory OU that contains the servers to be queried.
.PARAMETER File
 Specify the text file that contains the servers to be queried.
.PARAMETER IPv6
 Switch to IPv6. IPv4 is the default.
.EXAMPLE
 .\Get-IPList.ps1
 This will list all the IPv4 addresses on the localhost.
.EXAMPLE
 .\Get-IPList.ps1 -ComputerName server1,server2
 This will list all the IPv4 addresses for server1 and server2
.EXAMPLE
 .\Get-IPList.ps1 -file .\servers.txt
 This will list all the IPv4 addresses for the servers listed in the servers.txt file. Please note the txt format is 1 server per line.
.EXAMPLE
 .\Get-IPList.ps1 -OU "OU=Servers,OU=Corp,DC=contoso,DC=com" -IPv6
 This will list all the IPv6 addresses for the servers listed in the specified OU.

#>

param(
    [Parameter()]
    [string[]] $ComputerName,
    [Parameter()]
    [string[]] $OU,
    [Parameter()]
    [string[]] $File,
    [Parameter()]
    [switch] $IPv6
)

$bgDefColor = $host.ui.RawUI.BackgroundColor
$fgDefColor = $host.ui.RawUI.ForegroundColor

function outputColor {

    Param ([string]$bgcolor, [string]$fgcolor, [switch]$reset)

    if ($bgcolor) {
        $host.ui.RawUI.BackgroundColor = $bgcolor
    }

    if ($fgcolor) {
        $host.ui.RawUI.ForegroundColor = $fgcolor
    }

    if ($reset) {
        $host.ui.RawUI.BackgroundColor = $bgDefColor
        $host.ui.RawUI.ForegroundColor = $fgDefColor
    }
}

if ($IPv6) {
    $IPversion = "IPv6"
    $split = "Link-local IPv6 Address . . . . . : "
}
else {
    $IPversion = "IPv4"
    $split = "IPv4 Address. . . . . . . . . . . : "
}

if ($OU) {
    $ComputerName = Get-ADComputer -SearchBase "$OU" -filter {enabled -eq $True} | Sort-Object -Property Name | Select-Object -ExpandProperty Name
}

if ($File) {
    $ComputerName = Get-Content $File
}

if ($ComputerName) {

    Clear-Host

    foreach ($Computer in $ComputerName) {

        outputColor -bgcolor "White" -fgcolor "Black"
        Write-Output `n$Computer
        outputColor -reset

        try {
            $IPs = (Invoke-Command -ScriptBlock {ipconfig} -ComputerName $Computer -ErrorAction Stop) | select-string -pattern $IPversion
            foreach ($IP in $IPs) {
                ($IP -split $split)[1]
            }
        }

        catch {
            outputColor -fgcolor "Yellow"
            Write-Output "Server is not reachable. Error details:"
            outputColor -fgcolor "DarkGray"
            Write-Output $_`n
            outputColor -reset
        }
    }

    Write-Output `n
}

else {

    Clear-Host

    outputColor -bgcolor "Gray" -fgcolor "Black"
    Write-Output `n"localhost"
    outputColor -reset
    $IPs = ipconfig | select-string -pattern $IPversion
    foreach ($IP in $IPs) {
        ($IP -split $split)[1]
    }

    Write-Output `n
}