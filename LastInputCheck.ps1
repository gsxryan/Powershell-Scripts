<# RCautomate.com
 Modified to run until exited, 
 from source: 
Andy Arismendi
https://stackoverflow.com/questions/15845508/get-idle-time-of-machine
#>

Add-Type @'
    using System;
    using System.Diagnostics;
    using System.Runtime.InteropServices;
    namespace PInvoke.Win32 {
        public static class UserInput {
            [DllImport("user32.dll", SetLastError=false)]
            private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
            [StructLayout(LayoutKind.Sequential)]
            private struct LASTINPUTINFO {
                public uint cbSize;
                public int dwTime;
            }
            public static DateTime LastInput {
                get {
                    DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                    DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                    return lastInput;
                }
            }
            public static TimeSpan IdleTime {
                get {
                    return DateTime.UtcNow.Subtract(LastInput);
                }
            }
            public static int LastInputTicks {
                get {
                    LASTINPUTINFO lii = new LASTINPUTINFO();
                    lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                    GetLastInputInfo(ref lii);
                    return lii.dwTime;
                }
            }
        }
    }
'@

While ($true) {
    Write-Host ("Last input " + [PInvoke.Win32.UserInput]::LastInput)
    Write-Host ("Idle for " + [PInvoke.Win32.UserInput]::IdleTime)
    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)
}
