function Find-DataGridViewValue
{
<#
	.SYNOPSIS
		The Find-DataGridViewValue function helps you to find a specific value and select the cell, row or to set a fore and back color.
	
	.DESCRIPTION
		The Find-DataGridViewValue function helps you to find a specific value and select the cell, row or to set a fore and back color.
	
	.PARAMETER DataGridView
		Specifies the DataGridView Control to use
	
	.PARAMETER RowBackColor
		Specifies the back color of the row to use
	
	.PARAMETER RowForeColor
		Specifies the fore color of the row to use
	
	.PARAMETER SelectCell
		Specifies to select only the cell when the value is found
	
	.PARAMETER SelectRow
		Specifies to select the entire row when the value is found
	
	.PARAMETER Value
		Specifies the value to search
	
	.EXAMPLE
		PS C:\> Find-DataGridViewValue -DataGridView $datagridview1 -Value $textbox1.Text
	
		This will find the value and select the cell(s)
	
	.EXAMPLE
		PS C:\> Find-DataGridViewValue -DataGridView $datagridview1 -Value $textbox1.Text -RowForeColor 'Red' -RowBackColor 'Black'
	
		This will find the value and color the fore and back of the row
	.EXAMPLE
		PS C:\> Find-DataGridViewValue -DataGridView $datagridview1 -Value $textbox1.Text -SelectRow
	
		This will find the value and select the entire row
	
	.NOTES
		Francois-Xavier Cat
		@lazywinadm
		www.lazywinadmin.com
#>
	[CmdletBinding(DefaultParameterSetName = "Cell")]
	PARAM (
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.DataGridView]$DataGridView,
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[String]$Value,
		[Parameter(ParameterSetName = "Cell")]
		[Switch]$SelectCell,
		[Parameter(ParameterSetName = "Row")]
		[Switch]$SelectRow,
		#[Parameter(ParameterSetName = "Column")]

		#[Switch]$SelectColumn,

		[Parameter(ParameterSetName = "RowColor")]
		[system.Drawing.Color]$RowForeColor,
		[Parameter(ParameterSetName = "RowColor")]
		[system.Drawing.Color]$RowBackColor
	)
	
	PROCESS
	{
		$DataGridView.ClearSelection()
		
		FOR ([int]$i = 0; $i -lt $DataGridView.RowCount; $i++)
		{
			FOR ([int]$j = 0; $j -lt $DataGridView.ColumnCount; $j++)
			{
				$CurrentCell = $dataGridView.Rows[$i].Cells[$j]
				
				#if ((-not $CurrentCell.Value.Equals([DBNull]::Value)) -and ($CurrentCell.Value.ToString() -like "*$Value*"))
				if ($CurrentCell.Value.ToString() -match $Value)
				{
					
					# Row Selection
					IF ($PSBoundParameters['SelectRow'])
					{
						$dataGridView.Rows[$i].Selected = $true
					}
					
					<#
					# Column Selection
					IF ($PSBoundParameters['SelectColumn'])
					{
						#$DataGridView.Columns[$($CurrentCell.ColumnIndex)].Selected = $true
						#$DataGridView.Columns[$j].Selected = $true
						#$CurrentCell.DataGridView.Columns[$j].Selected = $true
					}
					#>
					
					# Row Fore Color
					IF ($PSBoundParameters['RowForeColor'])
					{
						$dataGridView.Rows[$i].DefaultCellStyle.ForeColor = $RowForeColor
					}
					# Row Back Color
					IF ($PSBoundParameters['RowBackColor'])
					{
						$dataGridView.Rows[$i].DefaultCellStyle.BackColor = $RowBackColor
					}
					
					# Cell Selection
					ELSEIF (-not ($PSBoundParameters['SelectRow']) -and -not ($PSBoundParameters['SelectColumn']))
					{
						$CurrentCell.Selected = $true
					}
				} #IF not empty and contains value
			} #For Each column
		} #For Each Row
	} #PROCESS
} #Find-DataGridViewValue