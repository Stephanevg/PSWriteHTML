Function Get-HTMLPieChart {
    <#
	.SYNOPSIS

#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $ChartObject,
        [Parameter(Mandatory = $true)]
        [Array]
        $DataSet,
        [Parameter(Mandatory = $false)]
        $Options
    )

    $DataCount = $DataSet.Count
    Write-Verbose "Data Set counnt is $DataCount"

    if ($ChartObject.ChartStyle.ColorSchemeName -ne 'Random') {
        if ($Options -eq $null) {
            #Write-Verbose "Default Colour Schemes selected, selecting $($ChartObject.ChartStyle.ColorSchemeName)"
            #$ColorSchemes =	Get-HTMLColorSchemes
            $ChartColorScheme = $GlobalColorSchemes.($ChartObject.ChartStyle.ColorSchemeName) | select -First $DataCount
        } else {
            Write-Verbose "Options Colour Schemes selected, selecting $($ChartObject.ChartStyle.ColorSchemeName)"
            $ChartColorScheme = $Options.ColorSchemes.($ChartObject.ChartStyle.ColorSchemeName) | select -First $DataCount
        }
        if ($ChartColorScheme.Count -lt $DataCount) {
            Write-Warning ("Colorscheme " + $ChartObject.ChartStyle.ColorSchemeName + " only has " + $ChartColorScheme.Count + " schemes, you have $DataCount Records. Generating one for you" )
            $ChartColorScheme = Get-RandomColorScheme -numberofschemes $DataCount
        }
    } else {
        $ChartColorScheme = Get-RandomColorScheme -numberofschemes $DataCount
    }

    $ofs = ','
    $CJSHeader = @()
    $CJSHeader += '<canvas id="' + $ChartObject.ObjectName + '" width="' + $ChartObject.Size.Width + '" height="' + $ChartObject.Size.Height + '"></canvas>'
    $CJSHeader += '<script>'
    $CJSHeader += 'var ctx = document.getElementById("' + $ChartObject.ObjectName + '");'
    $CJSHeader += 'var ' + $ChartObject.ObjectName + ' = new Chart(ctx, {'
    $CJSHeader += "	type: '$($ChartObject.ChartStyle.ChartType)',"


    $CJSData = @()
    $CJSData = "	data:	{" + "`n"
    if ($ChartObject.ChartStyle.Showlabels) {
        $ofs = '","'
        $CJSData += '		labels: ["' + "$($DataSet.($ChartObject.DataDefinition.DataNameColumnName))" + '"],' + "`n"
    }

    $CJSData += "		datasets: [{" + "`n"
    $CJSData += "			label: '$($chartobject.DataDefinition.datasetname)'," + "`n"
    $ofs = ","
    $CJSData += "			data: [" + "$($DataSet | % {$_.($ChartObject.DataDefinition.DataValueColumnName)})" + "]," + "`n"
    $ofs = "','"
    $CJSData += "			backgroundColor: ['" + "$($ChartColorScheme.Background)" + "']," + "`n"
    $CJSData += "			hoverBackgroundColor:  ['" + "$($ChartColorScheme.border)" + "']," + "`n"
    $CJSData += "			borderWidth: $($ChartObject.ChartStyle.borderWidth)" + "`n"
    $CJSData += "		}]" + "`n"
    $CJSData += "	},"
    $ofs = ""


    $CJSOptions = @()
    $cjsOptions += '	options: {'
    #responsive
    $cjsOptions += "		responsive: $($ChartObject.ChartStyle.responsive),"
    #legend
    $cjsOptions += "		legend: {
                position: '$($ChartObject.ChartStyle.legendposition)',
            },"
    #Title
    if ($ChartObject.Title -ne '') {
        $cjsOptions += "		title: {
				display: true,
				text: '$($ChartObject.Title)'
			},"
    }
    $cjsOptions += "	},"
    #animation
    $cjsOptions += "	animation: {
                animateScale: $($ChartObject.ChartStyle.animateScale),
                animateRotate: $($ChartObject.ChartStyle.animateRotate)
            }"
    $CJSOptions += "});	"



    $CJSFooter = " </script>"



    $CJS = @()
    $CJS += $CJSHeader
    $CJS += $CJSData
    $CJS += $CJSOptions
    $CJS += $CJSFooter

    write-output $CJS
}