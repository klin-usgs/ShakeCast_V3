rem mklink /J "C:/Perl" "C:/Perl64/"
mklink /J "C:\Strawberry" "C:\Shakecast\Strawberry"
mklink /J "C:\Perl" "C:\Shakecast\Strawberry\perl"
mklink /J "C:\Perl64" "C:\Shakecast\Strawberry\perl"

assoc .pl=PerlScript
assoc .cgi=PerlScript

ftype PerlScript=C:\ShakeCast\Strawberry\perl\bin\perl.exe "%%1" %%*

setx Path "%Path%;C:\Shakecast\Strawberry\perl\bin;C:\Shakecast\Strawberry\perl\site\bin;C:\Shakecast\Strawberry\c\bin" -m
setx PATHEXT "%PATHEXT%;.PL" -m

pause