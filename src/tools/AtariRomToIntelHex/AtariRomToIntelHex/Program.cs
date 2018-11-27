using System;
using System.IO;
using System.Linq;
using System.Text;

namespace AtariRomToIntelHex
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var romFileName = args[0];

            Console.Write($"Converting file {romFileName}... ");

            var bytes = File.ReadAllBytes(romFileName);

            if (bytes.Length == 2048)
            {
                // If this is a 2K ROM, then duplicate it to fill 4K.
                bytes = bytes.Concat(bytes).ToArray();
            }

            var sb = new StringBuilder();
            var address = 0;
            const int byteCount = 1;

            for (var i = 0; i < bytes.Length; i += byteCount)
            {
                var checksum = 0;

                sb
                    .Append(":")
                    .Append(byteCount.ToString("X2"))
                    .Append(address.ToString("X4"))
                    .Append("00");  // 00 = Data

                checksum += byteCount;
                checksum += (address & 0xFF00) >> 8;
                checksum += address & 0x0FF;

                for (var j = 0; j < byteCount; j++)
                {
                    var b = bytes[i + j];
                    sb.Append(b.ToString("X2"));
                    checksum += b;
                }

                checksum = (~(checksum & 0xFF) + 1) & 0xFF;  // Two's complement of least significant byte

                sb
                    .Append(checksum.ToString("X2"))
                    .Append('\n');

                address += byteCount;
            }

            sb.Append(":00000001FF");  // End-of-file record

            var hexFileName = Path.ChangeExtension(romFileName, ".hex");
            File.WriteAllText(hexFileName, sb.ToString());

            Console.WriteLine("done.");
            Console.ReadLine();
        }
    }
}
