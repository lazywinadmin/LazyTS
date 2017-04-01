function Enable-Button
{
<#
.SYNOPSIS
	This function will enable a button control
.EXAMPLE
	Enable-Button -Button $Button
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
			$ButtonObject.Enabled = $true
		}
	}
} #Enable-Button
