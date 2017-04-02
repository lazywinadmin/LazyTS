function Set-TSGlobalServerName
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$ComputerName
	)
	
	if ($ComputerName -eq "." -OR $ComputerName -eq $env:COMPUTERNAME)
	{
		$ComputerName = 'localhost'
	}
	
	$script:Server = $ComputerName
	$script:Server
}
