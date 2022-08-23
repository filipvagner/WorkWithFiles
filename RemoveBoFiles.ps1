###########################################################
# COMMENT : Folder for logs must exist in variable $LogsFolder
#           In variables for folders must be always slash '\' at the end
#
###########################################################

# Variables
$FilesOlderThan = 30
$CurrentDate = Get-Date -Format yyyy-MM-dd
$SourceFolder = "D:\Tmp\RecoStar\"
$FilesFilter = "*.bo"
$LogsFolder = "D:\RemovedFilesLog\"

$FilesToDelete = Get-ChildItem -Path $SourceFolder -File -Filter $FilesFilter -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddDays($FilesOlderThan)}
Write-Output "Files removed in $SourceFolder on $CurrentDate" | Out-File "$LogsFolder$CurrentDate-RemovedItems.txt" -Append

foreach ($FileToDelete in $FilesToDelete) {
    Get-Item -Path $FileToDelete | Select-Object -ExpandProperty Name | Out-File "$LogsFolder$CurrentDate-RemovedItems.txt" -Append
    Get-Item -Path $FileToDelete | Remove-Item -Force -Confirm:$false -ErrorAction SilentlyContinue
}

Write-Output "List of files that could not be removed from $SourceFolder on $CurrentDate" | Out-File "$LogsFolder$CurrentDate-RemovedItemsError.txt" -Append
foreach ($FileToDelete in $FilesToDelete) {
    if (Get-Item -Path $FileToDelete -ErrorAction SilentlyContinue) {
        Write-Output "File $FileToDelete could not be removed" | Out-File "$LogsFolder$CurrentDate-RemovedItemsError.txt" -Append
    }
}