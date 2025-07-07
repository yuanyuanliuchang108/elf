$port1 = New-Object System.IO.Ports.SerialPort('COM14',115200 )#zynq
$port2 = New-Object System.IO.Ports.SerialPort('COM10',115200 )#elf
$port1.Open()
$port2.Open()
$data1
$data2

while($true) 
{
    if ($port2.BytesToRead -gt 0) 
	{sleep(0.01)
        $data2 = $port2.ReadExisting()
          if($data2.Length-1)
	    {Write-Host $data2 -NoNewLine
		Write-Host "Receive successfuly"
		#Write-Host "rec: $data2"
	    }
     $port1.write($data2)
    }
	    if ($port1.BytesToRead -gt 0) 
	{   sleep(0.1)
        $data1 = $port1.ReadExisting()
		$port2.write($data1)
		Write-Host "IP:" -NoNewLine
		Write-Host "$data1"-NoNewLine
		
    }
}