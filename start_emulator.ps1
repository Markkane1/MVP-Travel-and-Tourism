if (!(Test-Path "jdk-21.0.2")) {
    Invoke-WebRequest -Uri "https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_windows-x64_bin.zip" -OutFile "jdk-21.zip"
    Expand-Archive jdk-21.zip -DestinationPath .
}
$env:JAVA_HOME = "$PWD\jdk-21.0.2"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
firebase emulators:start --project demo-mvptravel
