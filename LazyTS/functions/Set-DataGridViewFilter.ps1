function Set-DataGridViewFilter
{
<#
	.SYNOPSIS
		The function Set-DataGridViewFilter helps to only show specific entries with a specific value
	
	.DESCRIPTION
		The function Set-DataGridViewFilter helps to only show specific entries with a specific value.
		The data needs to be in a DataTable Object. You can use ConvertTo-DataTable to convert your
		PowerShell object into a DataTable object.
	
	.PARAMETER AllColumns
		Specifies to search all the column
	
	.PARAMETER ColumnName
		Specifies to search in a specific column name
	
	.PARAMETER DataGridView
		Specifies the DataGridView control where the data will be filtered
	
	.PARAMETER DataTable
		Specifies the DataTable object that is most likely the original source of the DataGridView
	
	.PARAMETER Filter
		Specifies the string to search
	
	.EXAMPLE
		PS C:\> Set-DataGridViewFilter -DataGridView $datagridview1 -DataTable $ProcessesDT -AllColumns -Filter $textbox1.Text
	
	.EXAMPLE
		PS C:\> Set-DataGridViewFilter -DataGridView $datagridview1 -DataTable $ProcessesDT -ColumnName "Name" -Filter $textbox1.Text

	.NOTES
		Author: Francois-Xavier Cat
		Twitter:@LazyWinAdm
		WWW: 	lazywinadmin.com
#>
	PARAM (
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.DataGridView]$DataGridView,
		[Parameter(Mandatory = $true)]
		[System.Data.DataTable]$DataTable,
		[Parameter(Mandatory = $true)]
		[String]$Filter,
		[Parameter(Mandatory = $true, ParameterSetName = "OneColumn")]
		[String]$ColumnName,
		[Parameter(Mandatory = $true, ParameterSetName = "AllColumns")]
		[Switch]$AllColumns
	)
	PROCESS
	{
		$Filter = $Filter.ToString()
		
		IF ($PSBoundParameters['AllColumns'])
		{
			FOREACH ($Column in $DataTable.Columns)
			{
				#$RowFilter += "Convert("+$($Column.ColumnName)+",'system.string') Like '%"{1}%' OR " -f $Column.ColumnName, $Filter
				$RowFilter += "Convert($($Column.ColumnName),'system.string') Like '%$Filter%' OR "
			}
			
			# Remove the last 'OR'
			$RowFilter = $RowFilter -replace " OR $", ''
			
			#Append-RichtextboxStatus -Message $RowFilter
		}
		IF ($PSBoundParameters['ColumnName'])
		{
			$RowFilter = "$ColumnName LIKE '%$Filter%'"
		}
		
		$DataTable.defaultview.rowfilter = $RowFilter
		Load-DataGridView -DataGridView $DataGridView -Item $DataTable
	}
	END { Remove-Variable -Name $RowFilter -ErrorAction 'SilentlyContinue' | Out-Null }
} #Set-DataGridViewFilter