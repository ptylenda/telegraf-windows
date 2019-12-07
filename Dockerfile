FROM mcr.microsoft.com/windows/servercore:ltsc2019 

WORKDIR /LogMonitor
RUN powershell -Command \
    Invoke-WebRequest https://github.com/microsoft/windows-container-tools/releases/download/v1.0/LogMonitor.exe -OutFile LogMonitor.exe
COPY LogMonitorConfig.json .

WORKDIR /temp
RUN powershell -Command \
    Invoke-WebRequest https://dl.influxdata.com/telegraf/releases/telegraf-1.12.6_windows_amd64.zip -OutFile telegraf.zip \
  ; powershell -Command  Expand-Archive -Path telegraf.zip -DestinationPath C:\temp \
  ; Remove-Item -Path telegraf.zip \
  ; mkdir c:\telegraf \
  ; Move-Item -Path c:\temp\telegraf\telegraf.exe -Destination c:\telegraf

WORKDIR /telegraf
RUN powershell -Command \
    mkdir telegraf.d \
  ; .\telegraf.exe --service install --config C:\telegraf\telegraf.conf --config-directory C:\telegraf\telegraf.d
COPY telegraf.conf .

SHELL ["C:\\LogMonitor\\LogMonitor.exe", "powershell.exe"]
EXPOSE 9273

ENTRYPOINT "powershell.exe -Command 'Start-Service telegraf; while ($true) { Start-Sleep -Seconds 10 }'"