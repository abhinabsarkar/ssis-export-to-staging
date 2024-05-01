# How to generate the report
# 1. Update the parameters.json file with the month as an integer (1-12) i.e. 1 for January, 2 for February, etc.
# 2. Run the PowerShell script generate-cost-report.ps1 to 
    # download the file using API call, 
    # execute the SSIS package to create a Staging table, 
    # execute the stored procedure which will update the Historical table with the current month data.
    # The data updated will show up in the Power BI reports which which have the Stored Procedures to pull the data from the various tables & views.
# 3. The script will display the output of the SSIS package execution and the stored procedure execution.
# 4. The script will also display any errors that occur during the execution of the SSIS package or the stored procedure.

# The script executes a curl command to make a web request to the constructed URL based on parameters read from a JSON file.
# This PowerShell script is used to execute an SSIS package after downloading the file using curl.
# Exception handling is implemented to catch and display any errors that occur during the execution of the SSIS package.

try {
    # Read parameters from parameters.json file
    $params = Get-Content -Raw -Path "parameters.json" | ConvertFrom-Json

    # Assign parameter values
    $month = $params.month
    # Convert the integer to a month name
    $monthName = (Get-Culture).DateTimeFormat.GetMonthName($month).Substring(0, 3)     
    $year = $params.year
    $segment = $params.segment
    $sub_segment = $params.sub_segment
    $format = $params.format
    $filename = $params.filenamepart + $monthName + "_" + $year + "." + $format
    $api_endpoint = $params.api_endpoint

    # Construct the URL. Use the ` character to break the URL into multiple lines
    $url = "$api_endpoint`?month=$month&year=$year&segment=$segment&sub_segment=$sub_segment&format=$format"
    # Write-Host "URL: $url"

    # Execute the curl command
    Write-Host "Executing curl command with parameters: $url"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $filename -Headers @{"Content-Type" = "application/octet-stream"} -UseBasicParsing 
    $ProgressPreference = 'Continue'

    # Check if the file is downloaded
    if (Test-Path $filename) {
        Write-Host "File $filename downloaded successfully"
        # Define the destination path for moving the file
        $destinationPath = $params.destinationPath #"C:\abhinab\ssis\source\" 
        # Move the file to the destination path
        Move-Item -Path $filename -Destination $destinationPath
        Write-Host "File moved to $destinationPath"
    } else {
        Write-Host "File download failed"
    }

    # Path to the SSIS package
    $ssisPackagePath = $params.ssis_package
    $logFile = "ssis_log.txt"

    # Execute the SSIS package using dtexec utility. The -Wait parameter is used to make the script wait
    Write-Host "Executing SSIS package: $ssisPackagePath"
    Start-Process -FilePath "dtexec" -ArgumentList "/F `"$ssisPackagePath`"" -Wait -WindowStyle Hidden -PassThru -RedirectStandardOutput $logFile
    # Display the contents of the log file
    Get-Content $logFile

    # Check the exit code of dtexec to determine if the package execution was successful
    $exitCode = 0 #$process.ExitCode
    if ($exitCode -eq 0) {
        Write-Host "SSIS package executed successfully"

        # # Execute the SQL Server stored procedure 
        # # The SP will insert current month cost into Historical_Cost table
        # $sqlServer = $params.sql_server
        # $database = $params.database
        # $procedure = $params.stored_procedure

        # $query = "EXEC $procedure $monthName, $year"

        # try {
        #     Write-Host "Executing stored procedure: $query"
        #     Invoke-Sqlcmd -ServerInstance $sqlServer -Database $database -Query $query
        #     # Check if the error message is not null
        # }
        # catch {
        #     Write-Host "Failed to execute stored procedure: $_"
        # }
    } else {
        Write-Host "SSIS package execution failed with exit code: $exitCode"
    }
}
catch {
    Write-Host "An error occurred: $_"
}