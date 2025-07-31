Using Module "..\..\Logger\Logger.psm1"

[string]$module = "Music"

Class File {
     #region Members
    [string]$FilePath
    [Id3Tag]$Id3Tag

    hidden [Logger.Logger]$myLogger   
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    File() {
        $this.myLogger = [Logger.Logger]::GetInstance()
        
        $this.Id3Tag = [Id3Tag]::new()
    }

    File([string]$FilePath) {
        $this.myLogger = [Logger.Logger]::GetInstance()
        
        $this.Id3Tag = [Id3Tag]::new()
        $this.FilePath = $FilePath
    }
    #endregion Constructors

    #region Methods
    [void] readId3Tag() {
        $this.Id3Tag.read($($this.FilePath))
    }
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}

Class Id3Tag {
    # https://www.toddklindt.com/blog/Lists/Posts/Post.aspx?ID=468
    # https://www.rickgouin.com/use-powershell-to-edit-mp3-tags/


    #region Members
    [string[]]$Artist
    [string]$Album
    [string]$Title
    [int]$Year
    [int]$Rating
    
    hidden [Logger.Logger]$myLogger
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    Id3Tag() {
        $this.myLogger = [Logger.Logger]::GetInstance()
    }
    #endregion Constructors

    #region Methods
    [void] read([string]$FilePath) {
        $module = $script:module
        $class = $this.GetType().Name
        $method = (Get-PSCallStack)[0].FunctionName

        $this.myLogger.debug($module, $class, $method, "Reading Id3Tags of $($FilePath)...")

        $myPath = Get-Item -LiteralPath "$($FilePath)"

        $media = [TagLib.File]::Create($myPath)
        $tag = $media.GetTag([TagLib.TagTypes]::Id3v2)
        $popm = [TagLib.Id3v2.PopularimeterFrame]::Get($tag, "Windows Media Player 9 Series", $true)

        $this.Artist = $media.Tag.Artists
        $this.Album = $media.Tag.Album
        $this.Title = $media.Tag.Title
        $this.Year = $media.Tag.Year

        switch ($popm.Rating) {
            255 {
                $this.Rating = 5
            }
            196 {
                $this.Rating = 4
            }
            128 {
                $this.Rating = 3
            }
            64 {
                $this.Rating = 2
            }
            1 {
                $this.Rating = 1
            }
            0 {
                $this.Rating = 0
            }
        }

        $this.myLogger.debug($module, $class, $method, "OK")
    }
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}