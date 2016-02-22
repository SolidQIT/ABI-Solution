$files = Get-ChildItem "./extract" -Filter *.sql -Recurse

foreach($file in $files)
{
    Write-Output $File.FullName
    SQLCMD.EXE -S localhost -i $files.FullName -E
}
