# Demander le type d'affichage
$displayType = Read-Host "Choisissez le type d'affichage (standard/web)"



$diskInfo = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } | 
            Select-Object Name, @{Name='Disk';Expression={$_.Name}}, 
                            @{Name='UsedSpace';Expression={[math]::Round($_.Used / 1GB, 2)}}, 
                            @{Name='FreeSpace';Expression={[math]::Round($_.Free / 1GB, 2)}}, 
                            @{Name='TotalSpace';Expression={[math]::Round(($_.Used + $_.Free) / 1GB, 2)}}

if ($displayType -eq "s") {
    
    $barChar = '#'
    $emptyChar = '-'

    # Affichage standard
    foreach ($info in $diskInfo) {
        $usedPercentage = 0
        if ($info.TotalSpace -ne 0) {
            $usedPercentage = $info.UsedSpace / $info.TotalSpace
        }

        $usedBarLength = [Math]::Floor($usedPercentage * 10)
        $freeBarLength = 10 - $usedBarLength

        $usedBar = $barChar * $usedBarLength
        $freeBar = $emptyChar * $freeBarLength

        $progressBar = $info.Disk + ": [" + $usedBar + $freeBar + "] " + $info.UsedSpace + "Go / " + $info.TotalSpace + "Go   -->   " + $info.FreeSpace + "Go de disponible"
        Write-Output $progressBar
    }

} elseif ($displayType -eq "web") {
    # Générer un schéma en HTML
    $htmlContent = @"
    <html>
    <head>
        <title>Informations sur l'espace disque</title>
        <script src='https://cdn.jsdelivr.net/npm/chart.js'></script>
        <link href='https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap' rel='stylesheet'>
        <style>
            body {
                font-family: 'Roboto', sans-serif;
                margin: 0;
                padding: 20px;
                background-color: #f4f4f4;
            }
            h1, h2 {
                color: #333;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            table, th, td {
                border: 1px solid #ddd;
            }
            th, td {
                padding: 8px;
                text-align: left;
            }
            th {
                background-color: #007bff;
                color: white;
            }
            tr:nth-child(even) {
                background-color: #f2f2f2;
            }
            canvas {
                display: block;
                margin: 20px auto;
            }
        </style>
    </head>
    <body>
        <h1>Informations sur l'espace disque</h1>
        <table>
            <tr>
                <th>Disque</th>
                <th>Espace utilisé</th>
                <th>Espace libre</th>
                <th>Espace total</th>
            </tr>
"@
    foreach ($info in $diskInfo) {
    $htmlContent += @"
        <tr>
            <td>$($info.Disk)</td>
            <td>$($info.UsedSpace) GB</td>
            <td>$($info.FreeSpace) GB</td>
            <td>$($info.TotalSpace) GB</td>
        </tr>
"@
    }
}

    $htmlContent += @"
    </table>
"@

    foreach ($info in $diskInfo) {
        $canvasId = $info.Disk -replace '\\', ''
        $htmlContent += @"
        <div>
            <h2>Disque $($info.Disk)</h2>
            <canvas id='$canvasId' width='400' height='400'></canvas>
        </div>
        <script>
        var ctx = document.getElementById('$canvasId').getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: ['Espace utilisé', 'Espace libre'],
                datasets: [{
                    label: 'Usage du disque',
                    data: [$($info.UsedSpace), $($info.TotalSpace - $info.UsedSpace)],
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.2)',
                        'rgba(54, 162, 235, 0.2)'
                    ],
                    borderColor: [
                        'rgba(255, 99, 132, 1)',
                        'rgba(54, 162, 235, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: false,
            }
        });
        </script>
        $htmlContent += @"
        </body>
        </html>
"@   
    
    # N'oubliez pas de sauvegarder le contenu HTML dans un fichier avec encodage UTF-8
    $htmlContent | Out-File "disque_info.html" -Encoding UTF8
    Write-Output "Le fichier HTML a été créé à l'emplacement suivant : $(Get-Location)\disque_info.html"
} 