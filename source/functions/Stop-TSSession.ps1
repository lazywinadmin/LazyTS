function Stop-TSSession
{
	
	<#
	.SYNOPSIS
		Logs the session off, disconnecting any user that might be connected.

	.DESCRIPTION
		Use Stop-TSSession to logoff the session and disconnect any user that might be connected.

	.PARAMETER ComputerName
	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).

	.PARAMETER Id
		Specifies the session Id number.

	.PARAMETER InputObject
		   Specifies a session object. Enter a variable that contains the object, or type a command or expression that gets the sessions.

	.PARAMETER Synchronous
	       When the Synchronous parameter is present the command waits until the session is fully disconnected otherwise it returns
	       immediately, even though the session may not be completely disconnected yet.

	.PARAMETER Force
	       Overrides any confirmations made by the command.

	.EXAMPLE
		Get-TSSession -ComputerName comp1 | Stop-TSSession

		Description
		-----------
		logs off all connected users from Active sessions on remote computer 'comp1'. The caller is prompted to
		By default, the caller is prompted to confirm each action.

	.EXAMPLE
		Get-TSSession -ComputerName comp1 -State Active | Stop-TSSession -Force

		Description
		-----------
		logs off any connected user from Active sessions on remote computer 'comp1'.
		By default, the caller is prompted to confirm each action. To override confirmations, the Force Switch parameter is specified.

	.EXAMPLE
		Get-TSSession -ComputerName comp1 -State Active -Synchronous | Stop-TSSession -Force

		Description
		-----------
		logs off any connected user from Active sessions on remote computer 'comp1'. The Synchronous parameter tells the command to
		wait until the session is fully disconnected and only tghen it proceeds to the next session object.
		By default, the caller is prompted to confirm each action. To override confirmations, the Force Switch parameter is specified.

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
		Disconnect-TSSession
		Send-TSMessage
	#>
	
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Id')]
	Param (
		
		[Parameter()]
		[Alias('CN', 'IPAddress')]
		[System.String]$ComputerName = $script:server,
		[Parameter(
				   Position = 0,
				   Mandatory = $true,
				   ParameterSetName = 'Id',
				   ValueFromPipelineByPropertyName = $true
		)]
		[Alias('SessionId')]
		[System.Int32]$Id,
		[Parameter(
				   Mandatory = $true,
				   ValueFromPipeline = $true,
				   ParameterSetName = 'InputObject'
		)]
		[Cassia.Impl.TerminalServicesSession]$InputObject,
		[switch]$Synchronous,
		[switch]$Force
	)
	
	begin
	{
		try
		{
			$FuncName = $MyInvocation.MyCommand
			Write-Verbose "[$funcName] Entering Begin block."
			
			if (!$ComputerName)
			{
				Write-Verbose "[$funcName] $ComputerName is not defined, loading global value '$script:Server'."
				$ComputerName = Get-TSGlobalServerName
			}
			else
			{
				$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
			}
			
			Write-Verbose "[$FuncName] Attempting remote connection to '$ComputerName'"
			$TSManager = New-Object Cassia.TerminalServicesManager
			$TSRemoteServer = $TSManager.GetRemoteServer($ComputerName)
			$TSRemoteServer.Open()
			
			if (!$TSRemoteServer.IsOpen)
			{
				Throw 'Connection to remote server is not open. Use Connect-TSServer to connect first.'
			}
			
			Write-Verbose "[$FuncName] Connection is open '$ComputerName'"
			Write-Verbose "[$FuncName] Updating global Server name '$ComputerName'"
			$null = Set-TSGlobalServerName -ComputerName $ComputerName
		}
		catch
		{
			Throw
		}
	}
	
	
	
	Process
	{
		
		Write-Verbose "[$funcName] Entering Process block."
		
		try
		{
			
			if ($PSCmdlet.ParameterSetName -eq 'Id')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				$session = $TSRemoteServer.GetSession($Id)
			}
			
			if ($PSCmdlet.ParameterSetName -eq 'InputObject')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				$session = $InputObject
			}
			
			if ($session -ne $null)
			{
				if ($Force -or $PSCmdlet.ShouldProcess($TSRemoteServer.ServerName, "Logging off session id '$($session.sessionId)'"))
				{
					Write-Verbose "[$FuncName] Logging off session '$($session.SessionId)'"
					$session.Logoff($Synchronous)
				}
			}
		}
		catch
		{
			Throw
		}
	}
	
	
	end
	{
		try
		{
			Write-Verbose "[$funcName] Entering End block."
			Write-Verbose "[$funcName] Disconnecting from remote server '$($TSRemoteServer.ServerName)'"
			$TSRemoteServer.Close()
			$TSRemoteServer.Dispose()
		}
		catch
		{
			Throw
		}
	}
}