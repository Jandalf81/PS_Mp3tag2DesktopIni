Using Module ".\modules\Logger\Logger.psm1"
Using Module ".\modules\Music\0.1.0\Music.psd1"


function writeDesktopIni([string]$rootDirectory) {
    # get direct child directories
    $directories = Get-ChildItem -Path $rootDirectory -Directory

    # recurse down into each directory, call this function recursively
    foreach ($directory in $directories) {
        $myLogger.info("Current directory: ""$($directory.FullName)""")

        writeDesktopIni($directory.FullName)
    }

    # get mp3 files in the current directory
    $mp3Files = Get-ChildItem -Path $rootDirectory -File -Filter "*.mp3"

    # if there is at least one mp3 file
    if ($mp3Files.Count -gt 0) {
        [string]$nl = "`r`n"
        [string]$dirIni = $null

        # get the Id3Tag of the first file
        [Music.File]$myFile = [Music.File]::new("$($mp3Files[0].FullName)")
        $myFile.readId3Tag()

        # write desktop.ini
        $dirIni += "[.ShellClassInfo]$nl"
        $dirIni += "[{56A3372E-CE9C-11D2-9F0E-006097C686F6}]$nl"
        $dirIni += "Prop2 = 31,$($myFile.Id3Tag.Artist.Trim() -Join ";")$nl" # there can be more than one artist per file!
        $dirIni += "Prop4 = 31,$($myFile.Id3Tag.Album)$nl"
        $dirIni += "Prop5 = 31,$($myFile.Id3Tag.Year)"
        Out-File -InputObject $dirIni -FilePath "$($mp3Files[0].DirectoryName)\desktop.ini" -Encoding ansi

        $myLogger.info("Successfully wrote ""$($mp3Files[0].DirectoryName)\desktop.ini""")
    }
}


function main() {
    #region define Logger
    [Logger.Logger]$myLogger = [Logger.Logger]::GetInstance()

    [Logger.Target]$fileTarget = [Logger.TextfileTarget]::new()
    $fileTarget.MaxLogLevel = [Logger.LogLevel]::DEBUG
    $fileTarget.Filepath = "$($PSScriptRoot)\Mp3tag2DirectoryIni.log"
    $myLogger.targets.Add($fileTarget)

    [Logger.Target]$stdOutTarget = [Logger.StdoutTarget]::new()
    $stdOutTarget.MaxLogLevel = [Logger.LogLevel]::DEBUG
    $myLogger.targets.Add($stdOutTarget)
    #endregion define Logger


    $myLogger.info("---------- START")
    $myLogger.info("User: $(whoami) @ $(hostname)")

    
    #region actual code logic
    Add-Type -AssemblyName System.Windows.Forms

    $myLogger.info("Asking user for root directory...")
    $fbd = [System.Windows.Forms.FolderBrowserDialog]::new()
    $fbd.RootFolder = "MyComputer"

    if ($fbd.ShowDialog() -eq "OK") {
        $myLogger.info("Got root directory: ""$($fbd.SelectedPath)""")

        $myLogger.info("Begin recurse writing of desktop.ini files...")
        writeDesktopIni($fbd.SelectedPath)
    } else {
        $myLogger.warn("Selection canceled by user")
    }
    #endregion actual code logic


    $myLogger.info("---------- END")
    $myLogger.destroy()
    Remove-Variable myLogger
}


main