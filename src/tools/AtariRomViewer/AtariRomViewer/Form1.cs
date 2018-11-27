using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace AtariRomViewer
{
    public partial class Form1 : Form
    {
        private const string RomFileName = "dragonfire.rom";
        private int _address;
        private byte[] _romBytes;
        private Panel[] _leds;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            Text = RomFileName;
            _romBytes = File.ReadAllBytes(RomFileName);
            _leds = new[] { pnlLed0, pnlLed1, pnlLed2, pnlLed3, pnlLed4, pnlLed5, pnlLed6, pnlLed7 };

            UpdateDisplay();
        }

        private void btnRight_Click(object sender, EventArgs e)
        {
            _address = (_address == 0xFFF) ? 0 : _address + 1;
            UpdateDisplay();
        }

        private void btnLeft_Click(object sender, EventArgs e)
        {
            _address = (_address == 0) ? 0xFFF : _address - 1;
            UpdateDisplay();
        }

        private void UpdateDisplay()
        {
            lblAddress.Text = $@"0xF{_address:X3}";
            var data = _romBytes[_address];

            for (var i = 0; i < 8; i++)
            {
                _leds[i].BackColor = (data & (1 << i)) != 0 ? Color.Lime : Color.Gray;
            }
        }
    }
}
