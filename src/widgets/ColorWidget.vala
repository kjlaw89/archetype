/* Copyright 2018 KJ Lawrence <kjtehprogrammer@gmail.com>
*
* This program is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see http://www.gnu.org/licenses/.
*/

using App.Configs;

namespace App.Widgets {

    /**
     * The {@code ColorWidget} class.
     *
     * @since 1.0.0
     */
    public class ColorWidget : Gtk.Box {

        public Gtk.ColorButton button { get; private set; }
        public Gtk.Label label { get; private set; }
        public Gdk.RGBA color { get { return button.rgba; } }
        public bool is_set { get; private set; }

        /**
         * Constructs a new {@code ColorWidget} object.
         */
        public ColorWidget (string title, string? desc = null, string? color = null) {
            orientation = Gtk.Orientation.VERTICAL;

            button = new Gtk.ColorButton ();
            button.title = desc ?? title;
            button.add_palette (Gtk.Orientation.HORIZONTAL, 9, this.colorPalette ());
            button.add_palette (Gtk.Orientation.HORIZONTAL, 9, this.grayPalette ());

            button.button_release_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_SECONDARY) {
                    button.rgba = Gdk.RGBA ();
                    is_set = false;
                }

                return false;
            });

            button.color_set.connect (() => {
                is_set = true;
            });

            if (color != null) {
                var rgba = Gdk.RGBA ();
                if (rgba.parse (color)) {
                    button.rgba = rgba;
                    is_set = true;
                }
            }

            label = new Gtk.Label (title);
            label.tooltip_text = desc ?? title;

            this.add (button);
            this.add (label);
        }

        private Gdk.RGBA makeColor (string color) {
            var c = Gdk.RGBA ();
            c.parse (color);

            return c;
        }

        private Gdk.RGBA[] colorPalette () {
            var colors = new Gdk.RGBA[27];

            // Row 1
            colors[0] = makeColor ("#ed5353");
            colors[1] = makeColor ("#ffa154");
            colors[2] = makeColor ("#ffe16b");
            colors[3] = makeColor ("#9bdb4d");
            colors[4] = makeColor ("#64baff");
            colors[5] = makeColor ("#ad65d6");
            colors[6] = makeColor ("#8a715e");
            colors[7] = makeColor ("#667885");
            colors[8] = makeColor ("#d4d4d4");

            // Row 2
            colors[9] = makeColor ("#c6262e");
            colors[10] = makeColor ("#f37329");
            colors[11] = makeColor ("#f9c440");
            colors[12] = makeColor ("#68b723");
            colors[13] = makeColor ("#3689e6");
            colors[14] = makeColor ("#7a36b1");
            colors[15] = makeColor ("#715344");
            colors[16] = makeColor ("#485a6c");
            colors[17] = makeColor ("#abacae");

            // Row 3
            colors[18] = makeColor ("#a10705");
            colors[19] = makeColor ("#cc3b02");
            colors[20] = makeColor ("#d48e15");
            colors[21] = makeColor ("#3a9104");
            colors[22] = makeColor ("#0d52bf");
            colors[23] = makeColor ("#4c158a");
            colors[24] = makeColor ("#57392d");
            colors[25] = makeColor ("#273445");
            colors[26] = makeColor ("#7e8087");

            return colors;
        }

        private Gdk.RGBA[] grayPalette () {
            var colors = new Gdk.RGBA[9];

            // Row 1
            colors[0] = makeColor ("#000000");
            colors[1] = makeColor ("#1a1a1a");
            colors[2] = makeColor ("#333333");
            colors[3] = makeColor ("#4d4d4d");
            colors[4] = makeColor ("#666666");
            colors[5] = makeColor ("#7e8087");
            colors[6] = makeColor ("#abacae");
            colors[7] = makeColor ("#d4d4d4");
            colors[8] = makeColor ("#ffffff");

            return colors;
        }

        public string? hex () {
            if (!is_set) {
                return null;
            }

            var red = (int)(color.red * 255);
            var green = (int)(color.green * 255);
            var blue = (int)(color.blue * 255);

            var output = "#%02X%02X%02X".printf (red, green, blue);
            return output;
        }
    }
}
