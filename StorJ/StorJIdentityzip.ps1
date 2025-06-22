[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; curl https://github.com/storj/storj/releases/latest/download/identity_windows_amd64.exe.zip -o identity_windows_amd64.exe.zip; Expand-Archive ./identity_windows_amd64.exe.zip . -Force

./identity.exe create storagenode3

(sls BEGIN $env:AppData\Storj\Identity\storagenode\ca.cert).count
(sls BEGIN $env:AppData\Storj\Identity\storagenode\identity.cert).count
