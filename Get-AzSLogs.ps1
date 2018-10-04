#WinRM
#at first, you should run "winrm set winrm/config/client '@{TrustedHosts="xxx.xxx.xxx"} E command.

$scriptPath = Split-Path -Parent ($MyInvocation.MyCommand.Path)
$configScript = Join-Path $scriptPath "Config.ps1"
. $configScript

# Get Password
$passwordFile = Join-Path $scriptPath "password.txt"
if((Test-Path $passwordFile) -eq $false){
    Write-Host "generate password file to $passwordFile ."
    $credential = Get-Credential -UserName "cloudadmin" -Message "Plase type password of cloudadmin."
    $credential.Password | ConvertFrom-SecureString | Set-Content $passwordFile
} else {
    Write-Host "using password from $passwordFile ."
}

# Create Credentials for CloudAdmin
$password = Get-Content $passwordFile | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential $cloudadminUserName,$password

# Create session to PEP
$session = New-PSSession -ComputerName $ErcsVmIP -ConfigurationName PrivilegedEndpoint -Credential $credential


#shareCred
$shareCred = Get-Credential


$fromDate = [DateTime]::ParseExact("2018/10/04 06:25:00","yyyy/MM/dd hh:mm:ss", $null)
$toDate = [DateTime]::ParseExact("2018/10/04 06:52:00","yyyy/MM/dd hh:mm:ss", $null)
$share = "\\172.22.16.114\AzSLog"

Invoke-Command -Session $session {
    Get-AzureStackLog -OutputSharePath $using:share -OutputShareCredential $using:shareCred  -FromDate $using:fromDate -ToDate $using:toDate
}

if($s)
{
    Remove-PSSession $s
}