function Send-TSMessage
{
	
	<#
	.SYNOPSIS
		Displays a message box in the specified session Id.

	.DESCRIPTION
		Use Send-TSMessage display a message box in the specified session Id.

	.PARAMETER ComputerName
	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).

	.PARAMETER Text
		The text to display in the message box.

	.PARAMETER SessionID
		The number of the session Id.

	.PARAMETER Caption
		   The caption of the message box. The default caption is 'Alert'.

	.EXAMPLE
		$Message = "Importnat message`n, the server is going down for maintanace in 10 minutes. Please save your work and logoff."
		Get-TSSession -State Active -ComputerName comp1 | Send-TSMessage -Message $Message

		Description
		-----------
		Displays a message box inside all active sessions of computer name 'comp1'.

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
	
	
	[CmdletBinding(DefaultParameterSetName = 'Session')]
	Param (
		[Parameter()]
		[Alias('CN', 'IPAddress')]
		[System.String]$ComputerName = $script:server,
		[Parameter(
				   Position = 0,
				   Mandatory = $true,
				   HelpMessage = 'The text to display in the message box.'
		)]
		[System.String]$Text,
		[Parameter(
				   HelpMessage = 'The caption of the message box.'
		)]
		[ValidateNotNullOrEmpty()]
		[System.String]$Caption = 'Alert',
		[Parameter(
				   Position = 0,
				   ValueFromPipelineByPropertyName = $true,
				   ParameterSetName = 'Session'
		)]
		[Alias('SessionID')]
		[ValidateRange(0, 65536)]
		[System.Int32]$Id = -1,
		[Parameter(
				   Position = 0,
				   Mandatory = $true,
				   ValueFromPipeline = $true,
				   ParameterSetName = 'InputObject'
		)]
		[Cassia.Impl.TerminalServicesSession]$InputObject
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
	
	
	process
	{
		
		Write-Verbose "[$funcName] Entering Process block."
		
		try
		{
			
			if ($PSCmdlet.ParameterSetName -eq 'Session')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				if ($Id -ge 0)
				{
					$session = $TSRemoteServer.GetSession($Id)
				}
			}
			
			if ($PSCmdlet.ParameterSetName -eq 'InputObject')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				$session = $InputObject
			}
			
			if ($session)
			{
				Write-Verbose "[$FuncName] Sending alert message to session id: '$($session.SessionId)' on '$ComputerName'"
				$session.MessageBox($Text, $Caption)
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