<#*******************************************************************
    
    CARD SWAPPER V1.0

    Author: squeezoure@gmail.com, 2018
    
    
    Must be run as administrator.
    Provide the name of the problematic device which should be
    enabled/disabled when this script is run.
    The name is the same as displayed in Windows device manager.
    The name will be used as a search pattern.
    Regex is allowed. Case insensitive.

*********************************************************************#>

#SEARCH PATTERN
#$Card_Name = ".*AMD.*Radeon.*";
#$Card_Name = ".*intel.*";
$Card_Name = ".*qualcomm.*bluetooth.*";


Clear-Host;


#Import the official Microsoft module: "deviceManagement.psd1"
try
{
    Import-Module "D:\CARD_SWAPPER\DeviceManagement\DeviceManagement.psd1" -ErrorAction Stop;
}
catch
{
    Write-Host $_.Exception.Message;
}





class GraphicCard{
    [string]$Name = ""
    [string]$SearchPattern = ""
    #for state the correct type is "DeviceManager.Engine.DeviceConfigurationFlags",
    #but the script will fail before running saying unrecognized type.
    #you can import it manually or call the ps1 script with the import module command.
    #"object" works well however.
    [object]$State = 0
    [object]$Device = $null
    GraphicCard([string]$SearchPattern){
        $this.SearchPattern = $SearchPattern;

        $this.Device = Get-Device | ? {$_.name -imatch $SearchPattern};

        

        if ($this.Device -eq $null)
        {
            
            Write-Host "Device not found: "$SearchPattern ;
            Write-Host "Exiting with code 1.";
            pause;
            exit 1;
            
        }
        if (($this.Device | measure).Count -gt 1)
        {
            Write-Host "Too many result for device: "$this.SearchPattern ;
            Write-Host "Use a more specific seach pattern.";
            Write-Host "Exiting with code 1.";
            pause;
            exit 1;
            
        }
        else
        {

                Write-Host "device found: "$SearchPattern;
                $this.Name = $this.Device.Name;
                $this.State = $this.Device.ConfigurationFlags;
                Write-Host "Name: "$this.Name;
                Write-Host "State: "$this.State;
        }
    }
    [void]Enable(){

        $confirm = Read-Host "Do you want to enable device:`n"$this.Name" [y/n]";
        
        if ($confirm -eq 'y')
        {

            try
            {

                Write-Host "Enabling device...";
                $this.Device | Enable-Device -ErrorAction Stop;
                Write-Host "Success!";
            }
            catch
            {
                Write-Host "Failed to enable device: "$this.SearchPattern ;
                Write-Host "Exiting with code 1.";
                pause;
                exit 1;
            }


        }
        else
        {
            write-host "aborting";
            pause;
            exit 1;
        }
        
            

        
          
    }
    [void]Disable(){

        $confirm = Read-Host "Do you want to disable device:`n"$this.Name" [y/n]";
        
        if ($confirm -eq 'y')
        {

            try
            {
                Write-Host "Disabling device...";
                $this.Device | Disable-Device -ErrorAction Stop;
                Write-Host "Success!";
            }
            catch
            {
                Write-Host "Failed to disable device: "$this.SearchPattern ;
                Write-Host $_.Exception.Message;
                Write-Host "Exiting with code 1.";
            
                pause;
                exit 1;
            }


        }
        else
        {
            write-host "aborting";
            pause;
            exit 1;
        }


        
    }
}


$CARD = [GraphicCard]::New($Card_Name);



switch ($CARD.State.ToString())
{
    
    "CONFIGFLAG_DISABLED"
    {
        
        $CARD.Enable();
        break;

    };

    "0"
    {
        $CARD.Disable();
        break;
    };
    default:
    {
        Write-Host "Unrecognized state: "$CARD.State.ToString();
        Write-Host "Exiting with code 1.";
        pause;
        exit 1;
    }

}


Write-Host "Your computer will be restarted";
Pause;

Restart-Computer;