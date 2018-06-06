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
     * The {@code LibraryRow} class.
     *
     * @since 1.0.0
     */
    public class LibraryRow : Gtk.ListBoxRow {

        private Gtk.CheckButton selected_check;

        public Library library { get; private set; }
        public bool active { 
            get { return selected_check.active; }
            set {
                selected_check.sensitive = (value == false && library.is_default);
                selected_check.active = value;
            }
        }

        public signal void selected_changed (bool selected);

        /**
         * Constructs a new {@code LibraryRow} object.
         */
        public LibraryRow (Library library) {
            this.library = library;

            var grid = new Gtk.Grid ();
            grid.margin_top = 6;
            grid.margin_bottom = 6;
            grid.margin_left = 12;
            grid.margin_right = 12;
            grid.column_spacing = 12;
            grid.row_spacing = 6;

            var name_label = new Gtk.Label (library.name);
            name_label.halign = Gtk.Align.START;

            var library_label = new Gtk.Label (library.library);
            library_label.get_style_context ().add_class ("small_label");
            library_label.halign = Gtk.Align.END;

            var description_label = new Gtk.Label (library.description);
            description_label.halign = Gtk.Align.START;
            description_label.hexpand = true;

            selected_check = new Gtk.CheckButton ();
            selected_check.active = library.is_default;
            selected_check.sensitive = !library.is_default;
            selected_check.toggled.connect (() => {
                var active = selected_check.active;
                if (active) {
                    this.activate ();
                }

                this.selected_changed (active);
            });

            grid.attach (selected_check, 0, 0, 1, 2);
            grid.attach (name_label, 1, 0);
            grid.attach (library_label, 2, 0);
            grid.attach (description_label, 1, 1, 2, 1);

            this.add (grid);
        }
    }

    public struct Library {
        public string library;
        public string package;
        public string name;
        public string description;
        public bool is_default;
    }
}
