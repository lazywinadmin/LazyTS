function Get-TSServers
{
	
	<#
	.SYNOPSIS
		Enumerates all terminal servers in a given domain.

	.DESCRIPTION
		Enumerates all terminal servers in a given domain.

	.PARAMETER ComputerName
	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).

	.PARAMETER DomainName
		The name of the domain. The default is the caller domain name ($env:USERDOMAIN).

	.EXAMPLE
		Get-TSDomainServers

		Description
		-----------
		Get a list of all terminal servers of the caller default domain.

	.OUTPUTS

	.COMPONENT
		TerminalServer

	.NOTES
		Author: Shay Levy
		Blog  : http://blogs.microsoft.co.il/blogs/ScriptFanatic/

	.LINK
		http://code.msdn.microsoft.com/PSTerminalServices

	.LINK
		http://code.google.com/p/cassia/

	.LINK
		Get-TSSession
	#>
	
	
	[OutputType('System.Management.Automation.PSCustomObject')]
	[CmdletBinding()]
	Param (
		[Parameter(
				   Position = 0,
				   ParameterSetName = 'Name'
		)]
		[System.String]$DomainName = $env:USERDOMAIN
	)
	
	
	try
	{
		$FuncName = $MyInvocation.MyCommand
		if (!$ComputerName)
		{
			Write-Verbose "[$funcName] ComputerName is not defined, loading global value '$script:Server'."
			$ComputerName = Get-TSGlobalServerName
		}
		else
		{
			$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
		}
		
		Write-Verbose "[$funcName] Enumerating terminal servers for '$DomainName' domain."
		Write-Warning 'Depending on your environment the command may take a while to complete.'
		$TSManager = New-Object Cassia.TerminalServicesManager
		$TSManager.GetServers($DomainName)
	}
	catch
	{
		Throw
	}
	
}