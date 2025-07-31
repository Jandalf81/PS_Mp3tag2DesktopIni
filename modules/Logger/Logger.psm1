Enum LogLevel {
    NONE = 0
    ERROR = 1
    WARN = 2
    INFO = 3
    DEBUG = 4
}

Class Logger {
    #region Members
    [System.Collections.Generic.List[Target]]$targets
    #endregion Members

    #region Static Members
    static [Logger]$Instance
    #endregion Static Members

    #region Constructors
    Logger() {
        $this.targets = [System.Collections.Generic.List[Target]]::new()
    }
    #endregion Constructors

    #region Methods
    [void] error([string]$message){
        $this.log([LogLevel]::ERROR, "", "", "", $message)
    }

    [void] error([string]$module, [string]$class, [string]$method, [string]$message){
        $this.log([LogLevel]::ERROR, $module, $class, $method, $message)
    }

    [void] warn([string]$message){
        $this.log([LogLevel]::WARN, "", "", "", $message)
    }

    [void] warn([string]$module, [string]$class, [string]$method, [string]$message){
        $this.log([LogLevel]::WARN, $module, $class, $method, $message)
    }

    [void] info([string]$message){
        $this.log([LogLevel]::INFO, "", "", "", $message)
    }

    [void] info([string]$module, [string]$class, [string]$method, [string]$message){
        $this.log([LogLevel]::INFO, $module, $class, $method, $message)
    }

    [void] debug([string]$message){
        $this.log([LogLevel]::DEBUG, "", "", "", $message)
    }

    [void] debug([string]$module, [string]$class, [string]$method, [string]$message){
        $this.log([LogLevel]::DEBUG, $module, $class, $method, $message)
    }

    [void] log([string]$message) {
        $this.log([LogLevel]::INFO, "", "", "", $message)
    }

    [void] log([LogLevel]$logLevel, [string]$message) {
        $this.log($logLevel, "", "", "", $message)
    }

    [void] log([LogLevel]$logLevel, [string]$module, [string]$class, [string]$method, [string]$message) {
        # generate timestamp for log message
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"

        foreach ($target in $this.targets) {
            if ($logLevel -le $target.MaxLogLevel) {
                $target.log($timestamp, $logLevel, $module, $class, $method, $message)
            }
        }
    }

    [void] destroy() {
        [Logger]::Instance = $null
    }
    #endregion Methods

    #region Static Methods
    static [Logger] GetInstance() {
        if ($null -eq [Logger]::Instance) {
            [Logger]::Instance = [Logger]::new()
        }

        return [Logger]::Instance
    }
    #endregion Static Methods
}

Class Target {
    #region Members
    [LogLevel]$MaxLogLevel
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    Target() {}
    #endregion Constructors

    #region Methods
    [void] log([string]$timestamp, [LogLevel]$logLevel, [string]$module, [string]$class, [string]$method, [string]$message) {}
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}

Class StdoutTarget : Target {
    #region Members
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    StdoutTarget() {
        $this.MaxLogLevel = [LogLevel]::NONE
    }
    #endregion Constructors

    #region Methods
    [void] log([string]$timestamp, [LogLevel]$logLevel, [string]$module, [string]$class, [string]$method, [string]$message) {
        [string]$sep = "`t"
        [string]$fgcolor = "WHITE"

        switch ($logLevel) {
            "ERROR" {
                $fgcolor = "RED"
            }
            "WARN" {
                $fgcolor = "YELLOW"
            }
            "INFO" {
                $fgcolor = "WHITE"
            }
            "DEBUG" {
                $fgcolor = "GRAY"
            }
        }

        [string]$logItem = "$($timestamp)$($sep)$($logLevel)$($sep)$($module)$($sep)$($class)$($sep)$($method)$($sep)$($message)"

        Write-Host "$($logItem)" -ForegroundColor $fgcolor
    }
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}

Class TextfileTarget : Target {
    #region Members
    [string]$Filepath
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    TextfileTarget() {
        $this.MaxLogLevel = [LogLevel]::NONE
    }
    #endregion Constructors

    #region Methods
    [void] log([string]$timestamp, [LogLevel]$logLevel, [string]$module, [string]$class, [string]$method, [string]$message) {
        [string]$sep = "`t"
        [string]$logItem = "$($timestamp)$($sep)$($logLevel)$($sep)$($module)$($sep)$($class)$($sep)$($method)$($sep)$($message)"

        Add-Content -Path $this.Filepath -Value "$($logItem)"
    }
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}

Class EventlogTarget : Target {
    #region Members
    [string]$Source
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    EventlogTarget() {
        $this.MaxLogLevel = [LogLevel]::NONE
    }
    #endregion Constructors

    #region Methods
    [void] log([string]$timestamp, [LogLevel]$logLevel, [string]$module, [string]$class, [string]$method, [string]$message) {
        [string]$sep = "`n`r"
        $entryType = "Information"

        switch ($logLevel) {
            "ERROR" {
                $entryType = "Error"
            }
            "WARN" {
                $entryType = "Warning"
            }
            "INFO" {
                $entryType = "Information"
            }
            "DEBUG" {
                $entryType = "Information"
            }
            default {
                
            }
        }

        [string]$logItem = "Module: $($module)$($sep)Class: $($class)$($sep)Method: $($method)$($sep)Message: $($message)"

        Write-EventLog -LogName "Application" -Source "$($this.source)" -EventId 3001 -EntryType $entryType -Message "$($logItem)" -Category 1
    }
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}