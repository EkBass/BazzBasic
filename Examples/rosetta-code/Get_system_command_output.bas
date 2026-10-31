' ============================================
' ROSETTA: https://rosettacode.org/wiki/Get_system_command_output
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Runs ping google.com through SHELL, captures the command's output and writes it to temp.txt.
' CATEGORY: api
' TAGS: shell, system command output, ping, filewrite
' MINVERSION: 1.5
' ============================================

[inits]
    LET exec$

[main]
    exec$ = SHELL("ping google.com")

    FILEWRITE("temp.txt", exec$)
END

' file: temp.txt
' Pinging google.com [142.251.38.78] with 32 bytes of data:
' Reply from 142.251.38.78: bytes=32 time=31ms TTL=118
' Reply from 142.251.38.78: bytes=32 time=48ms TTL=118
' Reply from 142.251.38.78: bytes=32 time=58ms TTL=118
' Reply from 142.251.38.78: bytes=32 time=62ms TTL=118
' 
' Ping statistics for 142.251.38.78:
'     Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
' Approximate round trip times in milli-seconds:
'     Minimum = 31ms, Maximum = 62ms, Average = 49ms