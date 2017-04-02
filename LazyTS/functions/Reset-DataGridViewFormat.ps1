function Reset-DataGridViewFormat
{
<#
	.SYNOPSIS
		The Reset-DataGridViewFormat function will reset the format of a datagridview control
	
	.DESCRIPTION
		The Reset-DataGridViewFormat function will reset the format of a datagridview control
	
	.PARAMETER DataGridView
		Specifies the DataGridView Control.
	
	.EXAMPLE
		PS C:\> Reset-DataGridViewFormat -DataGridView $DataGridViewObj
	
	.NOTES
		Author: Francois-Xavier Cat
		Twitter:@LazyWinAdm
		WWW: 	lazywinadmin.com
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.DataGridView]$DataGridView)
	PROCESS
	{
		$DataSource = $DataGridView.DataSource
		$DataGridView.DataSource = $null
		$DataGridView.DataSource = $DataSource
		
		#$DataGridView.RowsDefaultCellStyle.BackColor = 'White'
		#$DataGridView.RowsDefaultCellStyle.ForeColor = 'Black'
		$DataGridView.RowsDefaultCellStyle = $null
		$DataGridView.AlternatingRowsDefaultCellStyle = $null
	}
} #Reset-DataGridViewFormat