/*
 * Support for the Radeon R9 295X2 on an X99 DELUXE motherboard.
 * This device implements 2 PCI bridges for the two cards which
 * we have to define:
 *
 * - The first bridge contains a GPU and the HDMI audio device.
 * - The second bridge contains only a GPU.
 *
 * For macOS we patch the device-id to load the driver supporting
 * 290X/390X cards.
 */

DefinitionBlock ("", "SSDT", 2, "ACDT", "BRG0", 0x00000000)
{
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.BR3A.H000, DeviceObj)

    Scope (\_SB.PCI0.BR3A.H000)
    {
        // First PCI Bridge
        Device (BRG0)
        {
            Name (_ADR, 0x00080000) // Pci(0x0,0x0)/Pci(0x8,0x0)

            // R9 295X2 Primary GPU
            Device (GFX0)
            {
                Name (_ADR, Zero) // Pci(0x0,0x0)
                Method (_STA, 0, NotSerialized)
                {
                    If (_OSI ("Darwin"))
                    {
                        Return (0x0F)
                    }
                    Else
                    {
                        Return (Zero)
                    }
                }

                // Patch to 290X/390X if macOS
                if (_OSI ("Darwin"))
                {
                    Method (_DSM, 4, NotSerialized)
                    {
                        Local0 = Package (0x04)
                        {
                            "device-id",
                            Buffer (0x04)
                            {
                                0xB0, 0x67, 0x00, 0x00
                            },

                            "model",
                            Buffer ()
                            {
                                "AMD Radeon R9 295X2"
                            }
                        }
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }
            }

            // HDMI Audio Device
            Device (HDAU)
            {
                Name (_ADR, One) // Pci(0x0,0x1)
                Method (_STA, 0, NotSerialized)
                {
                    If (_OSI ("Darwin"))
                    {
                        Return (0x0F)
                    }
                    Else
                    {
                        Return (Zero)
                    }
                }
            }

            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        // Second PCI Bridge
        Device (BRG1)
        {
            Name (_ADR, 0x00100000) // Pci(0x0,0x0)/Pci(0x10,0x0)

            // R9 295X2 Secondary GPU
            Device (GFX0)
            {
                Name (_ADR, Zero) // Pci(0x0,0x0)
                Method (_STA, 0, NotSerialized)
                {
                    If (_OSI ("Darwin"))
                    {
                        Return (0x0F)
                    }
                    Else
                    {
                        Return (Zero)
                    }
                }

                // Patch to 290X/390X if macOS
                if (_OSI ("Darwin"))
                {
                    Method (_DSM, 4, NotSerialized)
                    {
                        Local0 = Package (0x04)
                        {
                            "device-id",
                            Buffer (0x04)
                            {
                                0xB0, 0x67, 0x00, 0x00
                            },

                            "model",
                            Buffer ()
                            {
                                "AMD Radeon R9 295X2 (Slave)"
                            }
                        }
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }
            }

            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }
    Scope (\_SB.PCI0)
    {
        Method (DTGP, 5, NotSerialized)
        {
            If (LEqual (Arg0, ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
            {
                If (LEqual (Arg1, One))
                {
                    If (LEqual (Arg2, Zero))
                    {
                        Store (Buffer (One)
                            {
                                0x03
                            }, Arg4)
                        Return (One)
                    }

                    If (LEqual (Arg2, One))
                    {
                        Return (One)
                    }
                }
            }

            Store (Buffer (One)
                {
                    0x00
                }, Arg4)
            Return (Zero)
        }
    }
}
