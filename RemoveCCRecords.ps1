############################################################
# AUTHOR  : Filip Vagner
# EMAIL   : filip.vagner@hotmail.com
# DATE    : 01-08-2019
# COMMENT : Script loads all folders in folder E:\Records created older than months specified in variable $FoledrsOlderThan
#           List of folders and files is logged into folder E:\RemovedRecordsLog in file with name as current date (MM-DD-YYYY) and name suffix RemovedItems.txt
#           Detailed content of each folder is logged into folder E:\RemovedRecordsLog\RemovedRecordsContent into file as current date (MM-DD-YYYY) and name suffix folder name and RemovedItems.txt
#           Once content is logged into file, folder is deleted
#           If folder in E:\Records could not be deleted, it is logged into folder E:\RemovedRecordsLog in file with name as current date (MM-DD-YYYY) and name suffix RemovedItemsError.txt
#
###########################################################

$FoledrsOlderThan = -3
$CurrentDate = Get-Date -Format MM-dd-yyyy
$FoldersToDelete = Get-ChildItem -Path E:\Records\ -Directory | Where-Object {$_.CreationTime -lt (Get-Date).AddMonths($FoledrsOlderThan)} | Select-Object -ExpandProperty Name
Write-Output "Folders removed in E:\Records on $CurrentDate" | Out-File E:\RemovedRecordsLog\$CurrentDate-RemovedItems.txt -Append

foreach ($FolderToDelete in $FoldersToDelete) {
    Write-Output $FolderToDelete | Out-File E:\RemovedRecordsLog\$CurrentDate-RemovedItems.txt -Append
    Write-Output "Content of folder $FolderToDelete" | Out-File E:\RemovedRecordsLog\RemovedRecordsContent\$CurrentDate-$FolderToDelete-RemovedItems.txt -Append
    Get-ChildItem -Path E:\Records\$FolderToDelete -Depth 1 | Select-Object Name, CreationTime, Parent | Out-File E:\RemovedRecordsLog\RemovedRecordsContent\$CurrentDate-$FolderToDelete-RemovedItems.txt -Append
    Get-Item -Path E:\Records\$FolderToDelete | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "List of folders that could not be removed from E:\Records on $CurrentDate" | Out-File E:\RemovedRecordsLog\$CurrentDate-RemovedItemsError.txt -Append
foreach ($FolderToDelete in $FoldersToDelete) {
    if (Test-Path -Path E:\Records\$FolderToDelete) {
        Write-Output "Folder $FolderToDelete could not be removed" | Out-File E:\RemovedRecordsLog\$CurrentDate-RemovedItemsError.txt -Append
    }
}
