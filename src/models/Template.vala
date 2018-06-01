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


namespace App.Models {

    /**
     * The {@code Template} class.
     *
     * @since 1.0.0
     */
    public class Template {

        private App.Views.AppView view;

        public string author { get; set; }
        public string author_email { get; set; }
        public bool   dark_mode { get; set; default = false; }
        public string description { get; set; }
        public string directory { get; set; }
        public string domain { get; set; }
        public string executable { get; set; }
        public string libraries { get; set; }
        public string license { get; set; }
        public string punchline { get; set; }
        public string template { get; set; }
        public string title { get; set; }
        public string rdnn { get; set; }
        public string rdnn_path { get; set; }

        /**
         * Constructs a new {@code Template} object.
         */
        public Template (App.Views.AppView view) {
            this.view = view;

            this.author = view.author_entry.text;
            this.author_email = view.author_email_entry.text;
            this.dark_mode = view.dark_mode_switch.active;
            this.description = view.description_textview.get_buffer ().text;
            this.directory = view.directory_button.get_uri ();
            this.domain = view.domain_entry.text;
            this.executable = view.exec_entry.text;
            this.libraries = view.libraries_list ();
            this.license = view.license_combo.active_id;
            this.punchline = view.punchline_entry.text;
            this.template = view.template_combo.active_id;
            this.title = view.title_entry.text;
            this.rdnn = view.executable_label.label;
            this.rdnn_path = "/" + rdnn.replace (".", "/") +"/";
        }

        public bool clean (string rdnn) {
            if (!validate_rdnn (rdnn)) {
                return false;
            }

            var export_path = "/tmp/"+ rdnn;
            var tar_path = "/tmp/"+ rdnn +".tar.gz";

            try {
                Process.spawn_command_line_sync ("rm -rf " + export_path);
                Process.spawn_command_line_sync ("rm -rf " + tar_path);
                return true;
            }
            catch (Error e) {
                warning ("Unable to delete temporary files " + export_path +", "+ tar_path);
            }

            return false;
        }

        public bool generate_folder (string rdnn) {
            var export_path = "/tmp/"+ rdnn;
            var tar_path = "/tmp/"+ rdnn +".tar.gz";
            var template_file = File.new_for_uri ("resource:///com/github/kjlaw89/archetype/templates/windowed");
            uint8[] data;

            // Attempt to load the template resource
            try {
                if (!template_file.load_contents (null, out data, null)) {
                    warning ("Unable to load template resource");
                    return false;
                }
            }
            catch (Error e) {
                warning ("Unable to load resource " + e.message);
                return false;
            }

            // Attempt to save the resource into the /tmp directory to perform replacements
            try {
                var temp_file = File.new_for_path (tar_path);
                var stream = temp_file.create (FileCreateFlags.NONE);
                var output = new DataOutputStream (stream);
                output.write_all (data, null);
            }
            catch (Error e) {
                warning ("Unable to create archive in /tmp " + e.message);
                return false;
            }

            // Create export directory and unzip our tar to it
            try {
                Process.spawn_command_line_sync ("mkdir -p "+ export_path);
                Process.spawn_command_line_sync ("tar -xzf "+ tar_path +" -C "+ export_path);
            }
            catch (Error e) {
                warning ("Unable to unzip archive in /tmp " + e.message);
                return false;
            }

            return true;
        }

        public bool generate (string? rdnn = null) {
            rdnn = rdnn ?? this.rdnn;

            // Do an initial clean to clean up any previous attempts to generate this rdnn
            clean (rdnn);

            // Attempt to create our folder first
            if (!generate_folder (rdnn)) {
                return false;
            }

            /* Replaceable variables
             * com.generic.rdnn - replace with rdnn (filenames and content)
             * {{ app-name }} - replace with title
             * {{ punchline }} - replace with punchline
             * {{ author }} - replace with author
             * {{ author-email }} - replace with author_email
             * {{ rdnn-path }} - replace with rdnn_path
             * {{ repo-url }} - still need to get
             * {{ website-url }} - still need to get 
             * {{ exe-name }} - replace with executable
             * {{ license }} - replace with selected license content
             * {{ preamble }} - replace with preamble associated with selected license (replace first)
             * {{ libraries-control }} - replace with libraries (formatted for debian control file)
             * {{ libraries-readme }} - replace with libraries formatted for README.md
             * {{ year }} - replace with current year (should be run after preamble)
             * {{ screenshot-url }} - replace with nothing for now (no good way to get this)
             * {{ app-center-bg }} - need to get
             * {{ app-center-text }} - need to get
             * {{ app-center-price }} - need to get (default to 0)
             * {{ categories }} - need to get (replace with nothing)
             * {{ keywords }} - need to get (replace with nothing)
             * {{ terminal-mode }} - replace with true if terminal app, false otherwise
             * {{ code-license }} - replace with Gtk.LICENSE constant for selected license (https://valadoc.org/gtk+-3.0/Gtk.License.html)
             */

            // Clean up after the build process (only the .tar.gz should be left)
            clean (rdnn);
            return true;
        }

        public bool validate_rdnn (string rdnn) {
            var rdnn_regex = new Regex ("^[a-z]{2,6}\\.[a-zA-Z0-9\\-_]{1,30}\\.([a-zA-Z0-9\\-_]{1,30}\\.?)+$");
            return rdnn_regex.match (rdnn);
        }
    }
}
