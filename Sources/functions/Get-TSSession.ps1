function Get-TSSession
{
	<#
	.SYNOPSIS
		Lists the sessions on a given terminal server.

	.DESCRIPTION
		Use Get-TSSession to get a list of sessions from a local or remote computers.
		Note that Get-TSSession is using Aliased properties to display the output on the console (IPAddress and State), these attributes
		are not the same as the original attributes (ClientIPAddress and ConnectionState).
		This is important when you want to use the -Filter parameter which requires the latter.
		To see all aliassed properties and their corresponding properties (Definition column), pipe the result to Get-Member:

		PS > Get-TSSession | Get-Member -MemberType AliasProperty

		   TypeName: Cassia.Impl.TerminalServicesSession

		Name      MemberType    Definition
		----      ----------    ----------
		(...)
		IPAddress AliasProperty IPAddress = ClientIPAddress
		State     AliasProperty State = ConnectionState


	.PARAMETER ComputerName
	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).

	.PARAMETER Id
		Specifies the session Id number.

	.PARAMETER InputObject
		   Specifies a session object. Enter a variable that contains the object, or type a command or expression that gets the sessions.

	.PARAMETER Filter
		   Specifies a filter based on the session properties. The syntax of the filter, including the use of
		   wildcards and depends on the properties of the session. Internally, The Filter parameter uses client side
		   filtering using the Where-Object cmdlet, objects are filtered after they are retrieved.

	.PARAMETER State
		The connection state of the session. Use this parameter to get sessions of a specific state. Valid values are:

		Value		 Description
		-----		 -----------
		Active		 A user is logged on to the session.
		ConnectQuery The session is in the process of connecting to a client.
		Connected	 A client is connected to the session).
		Disconnected The session is active, but the client has disconnected from it.
		Down		 The session is down due to an error.
		Idle		 The session is waiting for a client to connect.
		Initializing The session is initializing.
		Listening 	 The session is listening for connections.
		Reset		 The session is being reset.
		Shadowing	 This session is shadowing another session.

	.PARAMETER ClientName
		The name of the machine last connected to a session.
		Use this parameter to get sessions made from a specific computer name. Wildcrads are permitted.

	.PARAMETER UserName
		Use this parameter to get sessions made by a specific user name. Wildcrads are permitted.

	.EXAMPLE
		Get-TSSession

		Description
		-----------
		Gets all the sessions from the local computer.

	.EXAMPLE
		Get-TSSession -ComputerName comp1 -State Disconnected

		Description
		-----------
		Gets all the disconnected sessions from the remote computer 'comp1'.

	.EXAMPLE
		Get-TSSession -ComputerName comp1 -Filter {$_.ClientIPAddress -like '10*' -AND $_.ConnectionState -eq 'Active'}

		Description
		-----------
		Gets all Active sessions from remote computer 'comp1', made from ip addresses that starts with '10'.

	.EXAMPLE
		Get-TSSession -ComputerName comp1 -UserName a*

		Description
		-----------
		Gets all sessions from remote computer 'comp1' made by users with name starts with the letter 'a'.

	.EXAMPLE
		Get-TSSession -ComputerName comp1 -ClientName s*

		Description
		-----------
		Gets all sessions from remote computer 'comp1' made from a computers names that starts with the letter 's'.

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
		Stop-TSSession
		Disconnect-TSSession
		Send-TSMessage
	#>
	
	
	[OutputType('Cassia.Impl.TerminalServicesSession')]
	[CmdletBinding(DefaultParameterSetName = 'Session')]
	Param (
		
		[Parameter()]
		[Alias('CN', 'IPAddress')]
		[System.String]$ComputerName,
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
		[Cassia.Impl.TerminalServicesSession]$InputObject,
		[Parameter(
				   Mandatory = $true,
				   ParameterSetName = 'Filter'
		)]
		[ScriptBlock]$Filter,
		[Parameter()]
		[ValidateSet('Active', 'Connected', 'ConnectQuery', 'Shadowing', 'Disconnected', 'Idle', 'Listening', 'Reset', 'Down', 'Initializing')]
		[Alias('ConnectionState')]
		[System.String]$State = '*',
		[Parameter()]
		[System.String]$ClientName = '*',
		[Parameter()]
		[System.String]$UserName = '*'
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
			if ($PSCmdlet.ParameterSetName -eq 'Session')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				if ($Id -lt 0)
				{
					$session = $TSRemoteServer.GetSessions()
				}
				else
				{
					$session = $TSRemoteServer.GetSession($Id)
				}
			}
			
			if ($PSCmdlet.ParameterSetName -eq 'InputObject')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				$session = $InputObject
			}
			
			if ($PSCmdlet.ParameterSetName -eq 'Filter')
			{
				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
				
				$TSRemoteServer.GetSessions() | Where-Object $Filter
			}
			
			if ($session)
			{
				$session | Where-Object { $_.ConnectionState -like $State -AND $_.UserName -like $UserName -AND $_.ClientName -like $ClientName } | `
				Add-Member -MemberType AliasProperty -Name IPAddress -Value ClientIPAddress -PassThru | `
				Add-Member -MemberType AliasProperty -Name State -Value ConnectionState -PassThru
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