' ============================================
' https://rosettacode.org/wiki/Random_number_generator_(included)
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' BazzBasic uses .NET's Random class.
' 
' RND(n) with a positive argument calls Random.Next(n), returning an integer between 0 and n-1.
' RND(0) calls Random.NextDouble(), returning a float between 0.0 and 1.0.
' No manual seeding is needed — .NET seeds the generator automatically.
' See: https://learn.microsoft.com/en-us/dotnet/api/system.random

PRINT RND(100)  ' Integer: 0 to 99  (uses Random.Next)
PRINT RND(0)    ' Float:   0.0 to 1.0 (uses Random.NextDouble)
