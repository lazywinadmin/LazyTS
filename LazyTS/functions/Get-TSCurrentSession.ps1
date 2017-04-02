function Get-TSCurrentSession
{
	
	<#
	.SYNOPSIS
		Provides information about the session in which the current process is running.

	.DESCRIPTION
		Provides information about the session in which the current process is running.

	.EXAMPLE
		Get-TSCurrentSession

		Description
		-----------
		Displays the session in which the current process is running on the local computer.

	.OUTPUTS
		Cassia.Impl.TerminalServicesSession

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
	
	
	[OutputType('Cassia.Impl.TerminalServicesSession')]
	[CmdletBinding()]
	param (
		[Parameter()]
		[Alias('CN', 'IPAddress')]
		[System.String]$ComputerName = $script:server
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
		
		Write-Verbose "[$funcName] Attempting remote connection to '$ComputerName'"
		$TSManager = New-Object Cassia.TerminalServicesManager
		$TSRemoteServer = $TSManager.GetRemoteServer($ComputerName)
		$TSRemoteServer.Open()
		
		if (!$TSRemoteServer.IsOpen)
		{
			Throw 'Connection to remote server is not open. Use Connect-TSServer to connect first.'
		}
		
		Write-Verbose "[$funcName] Connection is open '$ComputerName'"
		Write-Verbose "[$funcName] Updating global Server name '$ComputerName'"
		$null = Set-TSGlobalServerName -ComputerName $ComputerName
		
		Write-Verbose "[$funcName] Get CurrentSession from '$ComputerName'"
		$TSManager.CurrentSession
		
		Write-Verbose "[$funcName] Disconnecting from remote server '$($TSRemoteServer.ServerName)'"
		$TSRemoteServer.Close()
		$TSRemoteServer.Dispose()
	}
	catch
	{
		Throw
	}
}