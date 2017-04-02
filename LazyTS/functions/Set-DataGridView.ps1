function Set-DataGridView
{
	<#
		.SYNOPSIS
			This function helps you edit the datagridview control
	
		.DESCRIPTION
			This function helps you edit the datagridview control
	
		.EXAMPLE
			Set-DataGridView -DataGridView $datagridview1 -ProperFormat -FontFamily $listboxFontFamily.Text -FontSize $listboxFontSize.Text
	
		.EXAMPLE
			Set-DataGridView -DataGridView $datagridview1 -AlternativeRowColor -BackColor 'AliceBlue' -ForeColor 'Black'
	
		.EXAMPLE
			Set-DataGridViewRowHeader -DataGridView $datagridview1 -HideRowHeader
	
		.EXAMPLE
			Set-DataGridViewRowHeader -DataGridView $datagridview1 -ShowRowHeader
	
		.NOTES
			Author: Francois-Xavier Cat
			Twitter:@LazyWinAdm
			WWW: 	lazywinadmin.com
	#>
	
	[CmdletBinding()]
	PARAM (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.DataGridView]$DataGridView,
		[Parameter(Mandatory = $true, ParameterSetName = "AlternativeRowColor")]
		[Switch]$AlternativeRowColor,
		[Parameter(ParameterSetName = "DefaultRowColor")]
		[Switch]$DefaultRowColor,
		[Parameter(Mandatory = $true, ParameterSetName = "AlternativeRowColor")]
		[Parameter(ParameterSetName = "DefaultRowColor")]
		[System.Drawing.Color]$ForeColor,
		[Parameter(Mandatory = $true, ParameterSetName = "AlternativeRowColor")]
		[Parameter(ParameterSetName = "DefaultRowColor")]
		[System.Drawing.Color]$BackColor,
		[Parameter(Mandatory = $true, ParameterSetName = "Proper")]
		[Switch]$ProperFormat,
		[Parameter(ParameterSetName = "Proper")]
		[String]$FontFamily = "Consolas",
		[Parameter(ParameterSetName = "Proper")]
		[Int]$FontSize = 10,
		[Parameter(ParameterSetName = "HideRowHeader")]
		[Switch]$HideRowHeader,
		[Parameter(ParameterSetName = "ShowRowHeader")]
		[Switch]$ShowRowHeader
	)
	PROCESS
	{
		if ($psboundparameters['AlternativeRowColor'])
		{
			$DataGridView.AlternatingRowsDefaultCellStyle.ForeColor = $ForeColor
			$DataGridView.AlternatingRowsDefaultCellStyle.BackColor = $BackColor
		}
		
		if ($psboundparameters['DefaultRowColor'])
		{
			$DataGridView.RowsDefaultCellStyle.ForeColor = $ForeColor
			$DataGridView.RowsDefaultCellStyle.BackColor = $BackColor
		}
		
		
		if ($psboundparameters['ProperFormat'])
		{
			#$Font = New-Object -TypeName System.Drawing.Font -ArgumentList "Segoi UI", 10
			$Font = New-Object -TypeName System.Drawing.Font -ArgumentList $FontFamily, $FontSize
			
			#[System.Drawing.FontStyle]::Bold
			
			$DataGridView.ColumnHeadersBorderStyle = 'Raised'
			$DataGridView.BorderStyle = 'Fixed3D'
			$DataGridView.SelectionMode = 'FullRowSelect'
			$DataGridView.AllowUserToResizeRows = $false
			$datagridview.DefaultCellStyle.font = $Font
		}
		
		if ($psboundparameters['HideRowHeader'])
		{
			$DataGridView.RowHeadersVisible = $false
		}
		if ($psboundparameters['ShowRowHeader'])
		{
			$DataGridView.RowHeadersVisible = $true
		}
	}
	
} #Set-DataGridView