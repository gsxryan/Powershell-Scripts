

echo Excluded file types from backup:
echo --
echo The following are the ONLY directories included in backups.  Data listed in this report, or Data in other locations will NOT be backed up.
echo ----------------------------------------
echo C:\Users\*\Documents
echo C:\Users\*\Desktop
echo C:\Users\*\Favorites
echo C:\Users\*\Links
echo C:\Users\*\Pictures
echo C:\Users\*\Searches
echo C:\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles
echo C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Bookmarks
echo ----------------------------------------
 
echo PRESS ENTER to view the files excluded from backup - You should make separate provisions to back these up!

pause

dir /a /b /s "%userprofile%\Documents" | findstr /i /e "\.tmp \.cab \.exe \.msi \.vdi \.vmdk \.vmdx \.fcz \.rdata \.sqd \.clust \.fasta \.qual \.rda \.rdb \.sas7bdat \.mdb \.sff \.mov \.png \.tif \.tiff \.dll \.img \.iso \.bin \.bak \.vmem \.asn \.bam \.fastq \.frame000 \.ibd \.pdata \.xml \.wma" > C:\Temp\FilesNOTbackedup.txt
dir /a /b /s "%userprofile%\Desktop" | findstr /i /e "\.tmp \.cab \.exe \.msi \.vdi \.vmdk \.vmdx \.fcz \.rdata \.sqd \.clust \.fasta \.qual \.rda \.rdb \.sas7bdat \.mdb \.sff \.mov \.png \.tif \.tiff \.dll \.img \.iso \.bin \.bak \.vmem \.asn \.bam \.fastq \.frame000 \.ibd \.pdata \.xml \.wma" >> C:\Temp\FilesNOTbackedup.txt
dir /a /b /s "%userprofile%\Favorites" | findstr /i /e "\.tmp \.cab \.exe \.msi \.vdi \.vmdk \.vmdx \.fcz \.rdata \.sqd \.clust \.fasta \.qual \.rda \.rdb \.sas7bdat \.mdb \.sff \.mov \.png \.tif \.tiff \.dll \.img \.iso \.bin \.bak \.vmem \.asn \.bam \.fastq \.frame000 \.ibd \.pdata \.xml \.wma" >> C:\Temp\FilesNOTbackedup.txt
dir /a /b /s "%userprofile%\Links" | findstr /i /e "\.tmp \.cab \.exe \.msi \.vdi \.vmdk \.vmdx \.fcz \.rdata \.sqd \.clust \.fasta \.qual \.rda \.rdb \.sas7bdat \.mdb \.sff \.mov \.png \.tif \.tiff \.dll \.img \.iso \.bin \.bak \.vmem \.asn \.bam \.fastq \.frame000 \.ibd \.pdata \.xml \.wma" >> C:\Temp\FilesNOTbackedup.txt
dir /a /b /s "%userprofile%\Pictures" | findstr /i /e "\.tmp \.cab \.exe \.msi \.vdi \.vmdk \.vmdx \.fcz \.rdata \.sqd \.clust \.fasta \.qual \.rda \.rdb \.sas7bdat \.mdb \.sff \.mov \.png \.tif \.tiff \.dll \.img \.iso \.bin \.bak \.vmem \.asn \.bam \.fastq \.frame000 \.ibd \.pdata \.xml \.wma" >> C:\Temp\FilesNOTbackedup.txt
dir /a /b /s "%userprofile%\Searches" | findstr /i /e "\.tmp \.cab \.exe \.msi \.vdi \.vmdk \.vmdx \.fcz \.rdata \.sqd \.clust \.fasta \.qual \.rda \.rdb \.sas7bdat \.mdb \.sff \.mov \.png \.tif \.tiff \.dll \.img \.iso \.bin \.bak \.vmem \.asn \.bam \.fastq \.frame000 \.ibd \.pdata \.xml \.wma" >> C:\Temp\FilesNOTbackedup.txt

notepad C:\Temp\FilesNOTbackedup.txt

exit