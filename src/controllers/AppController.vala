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

using App.Models;
using App.Views;
using App.Widgets;

namespace App.Controllers {

    /**
     * The {@code AppController} class.
     *
     * @since 1.0.0
     */
    public class AppController {

        private Gtk.Application            application;
        private AppView                    app_view;
        private Gtk.HeaderBar              headerbar;
        private Gtk.ApplicationWindow      window { get; private set; default = null; }

        /**
         * Constructs a new {@code AppController} object.
         */
        public AppController (Gtk.Application application) {
            this.application = application;
            this.window = new Window (this.application);
            this.headerbar = new HeaderBar ();
            this.app_view = new AppView ();

            this.window.add (this.app_view);
            this.window.set_default_size (800, 350);
            this.window.set_size_request (800, 350);
            this.window.set_titlebar (this.headerbar);
            this.application.add_window (window);

            this.app_view.generate.connect (() => {
                this.generate ();
            });

            // See if GIT is available to initialize
            string output;
            Process.spawn_command_line_sync ("which git", out output);

            if (output.length == 0) {
                this.app_view.disable_git ();
            }
        }

        public void activate () {
            window.show_all ();
            app_view.activate ();
        }

        public void quit () {
            window.destroy ();
        }

        private void generate () {
            var template = new Template (this.app_view);
            if (template.generate ()) {
                var directory = File.new_for_path (template.directory);
                Granite.Services.System.open (directory);
                quit ();
                return;
            }

            this.app_view.error_label.label = "Unable to create project";
            var dialog = new Granite.MessageDialog.with_image_from_icon_name (
                "Unable to create project",
                template.error,
                "dialog-error",
                Gtk.ButtonsType.CLOSE
            );

            dialog.run ();
            dialog.destroy ();
        }
    }
}
