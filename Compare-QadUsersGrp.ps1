<#
    .SYNOPSIS
        Compare les groupe entre 2 users
    .DESCRIPTION
        Affiche sur 2 collones les les groupes AD des 2 users a comparer et met en evidance les goupes mamquants de chaque user
    .PARAMETER user1
        Nom complet de l'utilisateur 1 a comparer
        ex : domain.adds\UserName
    .PARAMETER user2
        Nom complet de l'utilisateur 2 a comparer
    .EXAMPLE
        .\Compare-QadUsersGrp.ps1 $(whoami) $($UserNames)
    .EXAMPLE
        Start-Process -WindowStyle hidden powershell -ArgumentList "-WindowStyle Normal .\Compare-QadUsersGrp.ps1 $(whoami) $($UserNames[1])"
#>
    param( $User1, $User2 )
    Add-PSSnapin 'Quest.ActiveRoles.ADManagement'
    $User1 = Get-QADUser -identity $User1
    $User2 = Get-QADUser -identity $User2
    $ListCompared = Compare-Object $User1.memberof $User2.memberof -IncludeEqual | %{
        #$_.InputObject=(Get-QADGroup $_.InputObject).Name
        $_.InputObject=($_.InputObject -split(','))[0] -replace('CN=','')
        $_
    } | Sort-Object InputObject
    $ListCompared2 = $ListCompared | select *

    $top=20

    Add-Type -AssemblyName 'System.Drawing'
    Add-Type -AssemblyName 'System.Windows.Forms'
    $Form = New-Object 'system.Windows.Forms.Form'
    $Form.SuspendLayout()
    $tooltip1 = New-Object 'System.Windows.Forms.ToolTip'
    $Form.Text = "Compare Groupe list"
    $Form.StartPosition = "CenterScreen"
    $Form.Width = 2*$middle+35
    $Form.Height = 400
    $Form.MinimumSize = "830, 400"
    $Form.AutoScroll = $True
    $Form.KeyPreview = $True
    $icon1 = & {
        $iconString = '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'
        $iconStream = New-Object -TypeName 'System.IO.MemoryStream' -ArgumentList @(,([System.Convert]::FromBase64String($iconString)))
        $icon = New-Object -TypeName 'System.Drawing.Icon' -ArgumentList $iconStream
        $iconStream.Dispose()
        return $icon
    }
    $Form.Icon = $icon1
    $Form.Add_KeyDown({ if ($_.KeyCode -eq 'Escape') {$Form.Close()} })

    #$Font = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Regular)
        # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $Font = New-Object System.Drawing.Font("Lucida Console",9,[System.Drawing.FontStyle]::Regular)

        # Boutton de gauche [=>]
            $CopyGrpToUser2 = New-Object 'System.Windows.Forms.Button'
            #$CopyGrpToUser2.ContextMenuStrip = $MyContextMenu
            $CopyGrpToUser2.enabled = $false
            $CopyGrpToUser2.Font = "Microsoft Sans Serif, 10pt"
            $CopyGrpToUser2.Location = "$(($Form.Width-24)/2-40), $($top-7)"
            $CopyGrpToUser2.Name = "A_To_B"
            $CopyGrpToUser2.Size = '40, 25'
            $CopyGrpToUser2.Text = "=>"
            $CopyGrpToUser2.tabindex = 2
            $CopyGrpToUser2.TextAlign = 'BottomCenter'
                $tooltip1.SetToolTip($CopyGrpToUser2, "Ajouter a $($User2.name) les groupes de $($User1.name)`nCopie vers la Droite")
            $CopyGrpToUser2.UseVisualStyleBackColor = $True
            $CopyGrpToUser2.add_Click($CopyGrpToUser2_Click)
            $Form.Controls.Add($CopyGrpToUser2)

        # Boutton de Droite [<=]
            $CopyGrpToUser1 = New-Object 'System.Windows.Forms.Button'
            #$CopyGrpToUser1.ContextMenuStrip = $MyContextMenu
            $CopyGrpToUser1.enabled = $false
            $CopyGrpToUser1.Font = "Microsoft Sans Serif, 10pt"
            $CopyGrpToUser1.Location = "$(($Form.Width-24)/2), $($top-7)"
            $CopyGrpToUser1.Name = "B_To_A"
            $CopyGrpToUser1.Size = '40, 25'
            $CopyGrpToUser1.Text = "<="
            $CopyGrpToUser1.tabindex = 3
            $CopyGrpToUser1.TextAlign = 'BottomCenter'
                $tooltip1.SetToolTip($CopyGrpToUser1, "Ajouter a $($User1.name) les groupes de $($User2.name)`nCopie vers la Gauche")
            $CopyGrpToUser1.UseVisualStyleBackColor = $True
            $CopyGrpToUser1.add_Click($CopyGrpToUser1_Click)
            $Form.Controls.Add($CopyGrpToUser1)

        # colonne de gauche
            $LeftLabel = New-Object 'System.Windows.Forms.Label'
            #$LeftLabel.backcolor = 'Red'
            $LeftLabel.Font = $Font
            $LeftLabel.autoSize = $true
            $LeftLabel.TextAlign = 'TopRight'
            $LeftLabel.Text = "-     $($User1.name)     -`n`n`n"
            $LeftLabel.Text += ($ListCompared | %{if ($_.SideIndicator -eq "=>") {$_.InputObject=""}; $_ }).InputObject -join("`n")
            $LeftLabel.Text += "`n"
            $Form.Controls.Add($LeftLabel)
            $LeftLabel.Location = "$(($Form.Width-24)/2-10-$LeftLabel.Width), $top"

        # colonne du centre
            $CenterLabel = New-Object 'System.Windows.Forms.Label'
            $CenterLabel.Font = $Font
            $CenterLabel.autoSize = $true
            #$CenterLabel.backcolor = 'Yellow'
            $CenterLabel.Text = "`n`n`n"
            $CenterLabel.Text += $ListCompared2.SideIndicator -join("`n") -replace('=>','<-') -replace('<=','->')
            $CenterLabel.Text += "`n"
            $Form.Controls.Add($CenterLabel)
            $CenterLabel.Location = "$(($Form.Width-24)/2-10), $top"

        # colonne de droite
            $RightLabel = New-Object System.Windows.Forms.Label
            $RightLabel.Font = $Font
            $RightLabel.autoSize = $true
            #$RightLabel.backcolor = 'Red'
            $RightLabel.Text = "-     $($User2.name)     -`n`n`n"
            $RightLabel.Text += ($ListCompared2 | %{if ($_.SideIndicator -eq "<=") {$_.InputObject=""}; $_ }).InputObject -join("`n")
            $RightLabel.Text += "`n"
            $Form.Controls.Add($RightLabel)
            $RightLabel.Location = "$(($Form.Width-24)/2+20), $top"

    $form.ResumeLayout($false)
    $form.PerformLayout()
    $Form.ShowDialog() | out-null