$port1 = New-Object System.IO.Ports.SerialPort('COM14',115200 )
$port2 = New-Object System.IO.Ports.SerialPort('COM10',115200 )
$port1.Open()
$port2.Open()
$data1
$data2

#$filepath = "test.txt"
#$content = Get-Content -Path $filepath -Raw
#$port2.write($content)
while($true) 
{
    if ($port2.BytesToRead -gt 0) 
	{
        $data2 = $port2.ReadExisting()
		$port1.write($data2)
		Write-Host "rec: $data2"
        #Add-Content -Path "output.txt" -Value $data -NoNewline
		
    }
	    if ($port1.BytesToRead -gt 0) 
	{   sleep(0.1)
        $data1 = $port1.ReadExisting()
		$port2.write($data1)
		Write-Host "Send: $data1"
        #Add-Content -Path "output.txt" -Value $data -NoNewline
		
    }
}
