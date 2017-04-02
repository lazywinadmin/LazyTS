function ConvertTo-DataTable
{
	<#
		.SYNOPSIS
			Converts objects into a DataTable.
	
		.DESCRIPTION
			Converts objects into a DataTable, which are used for DataBinding.
	
		.PARAMETER  InputObject
			The input to convert into a DataTable.
	
		.PARAMETER  Table
			The DataTable you wish to load the input into.
	
		.PARAMETER RetainColumns
			This switch tells the function to keep the DataTable's existing columns.
		
		.PARAMETER FilterWMIProperties
			This switch removes WMI properties that start with an underline.
	
		.EXAMPLE
			$DataTable = ConvertTo-DataTable -InputObject (Get-Process)
	
		.NOTES
			SAPIEN Technologies, Inc.
			http://www.sapien.com/
	
			VERSION HISTORY
			1.0 ????/??/?? From Sapien.com Version
			2.0 2014/12/03 Francois-Xavier Cat - In the rows workk, I added a 
				small piece of code to handle the $null value with [DBNull]::Value
				
	#>
	[CmdletBinding()]
	[OutputType([System.Data.DataTable])]
	param (
		[ValidateNotNull()]
		$InputObject,
		[ValidateNotNull()]
		[System.Data.DataTable]$Table,
		[switch]$RetainColumns,
		[switch]$FilterWMIProperties
	)
	
	if ($Table -eq $null)
	{
		$Table = New-Object System.Data.DataTable
	}
	
	if ($InputObject -is [System.Data.DataTable])
	{
		$Table = $InputObject
	}
	else
	{
		if (-not $RetainColumns -or $Table.Columns.Count -eq 0)
		{
			#Clear out the Table Contents
			$Table.Clear()
			
			if ($InputObject -eq $null) { return } #Empty Data
			
			$object = $null
			
			#find the first non null value
			foreach ($item in $InputObject)
			{
				if ($item -ne $null)
				{
					$object = $item
					break
				}
			}
			
			if ($object -eq $null) { return } #All null then empty
			
			#COLUMN
			#Get all the properties in order to create the columns
			foreach ($prop in $object.PSObject.Get_Properties())
			{
				if (-not $FilterWMIProperties -or -not $prop.Name.StartsWith('__')) #filter out WMI properties
				{
					#Get the type from the Definition string
					$type = $null
					
					if ($prop.Value -ne $null)
					{
						try { $type = $prop.Value.GetType() }
						catch { Write-Verbose -Message "Can't find type of $prop" }
					}
					
					if ($type -ne $null) # -and [System.Type]::GetTypeCode($type) -ne 'Object')
					{
						Write-Verbose -Message "Creating Column: $($Prop.name) (Type: $type)"
						[void]$table.Columns.Add($prop.Name, $type)
					}
					else #Type info not found
					{
						#if ($prop.name -eq "" -or $prop.name -eq $null) { [void]$table.Columns.Add([DBNull]::Value) }
						[void]$table.Columns.Add($prop.Name)
					}
				}
			}
			
			if ($object -is [System.Data.DataRow])
			{
				foreach ($item in $InputObject)
				{
					$Table.Rows.Add($item)
				}
				return @( , $Table)
			}
		}
		else
		{
			$Table.Rows.Clear()
		}
		
		#Rows Work
		foreach ($item in $InputObject)
		{
			# Create a new row object
			$row = $table.NewRow()
			
			if ($item)
			{
				foreach ($prop in $item.PSObject.Get_Properties())
				{
					#Find the appropriate column to put the value
					if ($table.Columns.Contains($prop.Name))
					{
						if ($prop.value -eq $null) { $prop.value = [DBNull]::Value }
						$row.Item($prop.Name) = $prop.Value
					}
				}
			}
			[void]$table.Rows.Add($row)
		}
	}
	
	return @( , $Table)
}