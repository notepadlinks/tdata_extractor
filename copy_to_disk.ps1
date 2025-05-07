# Параметры
$tdataFolder = "C:\Users\Noname\AppData\Roaming\Telegram Desktop\tdata"
$archivePath = "C:\Users\Noname\AppData\Local\Temp\tdata.zip"

# Закрытие Telegram (если он открыт)
Get-Process -Name "Telegram" -ErrorAction SilentlyContinue | Stop-Process

# Удаление существующего архива (если он есть)
if (Test-Path -Path $archivePath) {
    Remove-Item -Path $archivePath
}

# Создание архива из папки tdata
Compress-Archive -Path $tdataFolder -DestinationPath $archivePath

# Проверка, что архив был успешно создан
if (Test-Path -Path $archivePath) {
    Write-Host "Архив успешно создан и сохранен в Temp.`n"

    # Получение списка доступных физических дисков
    $drives = Get-Volume | Where-Object { $_.DriveLetter } | Select-Object DriveLetter, FileSystemLabel

    if (-not $drives) {
        Write-Host "❌ Не найдено ни одного доступного диска для копирования."
        exit
    }

    # Вывод доступных дисков
    Write-Host "Доступные диски:"
    foreach ($drive in $drives) {
        $label = if ($drive.FileSystemLabel) { $drive.FileSystemLabel } else { "Нет метки" }
        Write-Host "$($drive.DriveLetter):\ — $label"
    }

    # Цикл выбора
    while ($true) {
        $input = Read-Host "`nВведите букву диска для копирования архива (например, D), или 'Q' для выхода"

        if ($input.ToUpper() -eq 'Q') {
            Write-Host "Выход..."
            break
        }

        $letter = $input.Trim().TrimEnd(':').ToUpper()

        if ($drives.DriveLetter -contains $letter) {
            $destinationPath = "${letter}:\tdata.zip"
            Copy-Item -Path $archivePath -Destination $destinationPath -Force

            if (Test-Path -Path $destinationPath) {
                Write-Host "`n✅ Архив успешно скопирован на диск ${letter}:"
            } else {
                Write-Host "`n⚠️ Не удалось скопировать архив на диск ${letter}:"
            }
            break
        } else {
            Write-Host "❌ Неверный диск. Пожалуйста, выберите один из доступных."
        }
    }
} else {
    Write-Host "❌ Не удалось создать архив!"
}
