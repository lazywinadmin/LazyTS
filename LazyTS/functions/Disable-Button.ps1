function Disable-Button
{
<#
.SYNOPSIS
	This function will disable a button control
.EXAMPLE
	Disable-Button -Button $Button
.NOTES
	Francois-Xavier Cat
	@lazywinadm
	www.lazywinadmin.com
#>
	[CmdletBinding()]
	PARAM (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.Button[]]$Button
	)
	BEGIN
	{
		Add-Type -AssemblyName System.Windows.Forms
	}
	PROCESS
	{
		foreach ($ButtonObject in $Button)
		{
			$ButtonObject.Enabled = $false
		}
		
	}
} #Disable-Button