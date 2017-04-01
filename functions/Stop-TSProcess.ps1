function Stop-TSProcess
{
	
	<#
	.SYNOPSIS
		Terminates the process running in a specific session or in all sessions.

	.DESCRIPTION
		Use Stop-TSProcess to terminate one or more processes from a local or remote computers.

	.PARAMETER ComputerName
	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).

	.PARAMETER Id
		Specifies the process Id number.

	.PARAMETER InputObject
		Specifies a process object. Enter a variable that contains the object, or type a command or expression that gets the sessions.

	.PARAMETER Name
		Specifies the process name.

	.PARAMETER Session
		Specifies the session Id number.

	.PARAMETER Force
	       Overrides any confirmations made by the command.

	.EXAMPLE
		 Get-TSProcess -Id 6552 | Stop-TSProcess

		Description
		-----------
		Gets process Id 6552 from the local computer and stop it. Confirmations needed.

	.EXAMPLE
		Get-TSSession -Id 3 -ComputerName comp1 | Stop-TSProcess -Force

		Description
		-----------
		Terminats all processes connected to session id 3 from remote computer 'comp1', suppress confirmations.

	.OUTPUTS
		Cassia.Impl.TerminalServicesProcess

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
		Get-TSProcess
		Get-TSSession
	#>
	
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Name')]
	Param (
		[Parameter()]
		[Alias('CN', 'IPAddress')]
		[System.String]$ComputerName = $script:server,
		[Parameter(
				   Position = 0,
				   ValueFromPipelineByPropertyName = $true,
				   ParameterSetName = 'Name'
		)]
		[Alias("ProcessName")]
		[System.String]$Name = '*',
		[Parameter(
				   Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ParameterSetName = 'Id'
		)]
		[Alias('ProcessID')]
		[ValidateRange(0, 65536)]
		[System.Int32]$Id = -1,
		[Parameter(
				   Position = 0,
				   Mandatory = $true,
				   ValueFromPipeline = $true,
				   ParameterSetName = 'InputObject'
		)]
		[Cassia.Impl.TerminalServicesProcess]$InputObject,
		[Parameter(
				   Position = 0,
				   Mandatory = $true,
				   ValueFromPipeline = $true,
				   ParameterSetName = 'Session'
		)]
		[Alias('SessionId')]
		[Cassia.Impl.TerminalServicesSession]$Session,
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
			
			if ($PSCmdlet.ParameterSetName -eq 'Name')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				if ($Name -eq '*')
				{
					$proc = $TSRemoteServer.GetProcesses()
				}
				else
				{
					$proc = $TSRemoteServer.GetProcesses() | Where-Object { $_.ProcessName -like $Name }
				}
			}
			
			if ($PSCmdlet.ParameterSetName -eq 'Id')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				if ($Id -lt 0)
				{
					$proc = $TSRemoteServer.GetProcesses()
				}
				else
				{
					$proc = $TSRemoteServer.GetProcess($Id)
				}
			}
			
			
			if ($PSCmdlet.ParameterSetName -eq 'Session')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				if ($Session)
				{
					$proc = $Session.GetProcesses()
				}
			}
			
			
			if ($PSCmdlet.ParameterSetName -eq 'InputObject')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				$proc = $InputObject
			}
			
			
			if ($proc)
			{
				foreach ($p in $proc)
				{
					if ($Force -or $PSCmdlet.ShouldProcess($TSRemoteServer.ServerName, "Stop Process '$($p.ProcessName) ($($p.ProcessID))"))
					{
						Write-Verbose "[$FuncName] Killing process '$($p.ProcessName)' ($($p.ProcessId))"
						$p.Kill()
					}
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