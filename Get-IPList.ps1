param(
    [Parameter()]
    [string[]] $ComputerName,
    [Parameter()]
    [string[]] $OU,
    [Parameter()]
    [string[]] $file,
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

if ($file) {
    $ComputerName = Get-Content $file
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
            outputColor -reset
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