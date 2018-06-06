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
        public bool   git { get; set; default = false;}
        public string libraries { get; set; }
        public string license { get; set; }
        public string packages { get; set; }
        public string punchline { get; set; }
        public string template { get; set; }
        public string title { get; set; }
        public string repo_url { get; set; }
        public string rdnn { get; set; }
        public string rdnn_path { get; set; }
        public string website { get; set; }

        public string? headerbar_color { get; set; }
        public string? headerbar_text_color { get; set; }
        public string? headerbar_shadow_color { get; set; }
        public string? accent_color { get; set; }
        public string? store_color { get; set; }
        public string? store_text_color { get; set; }

        /**
         * Constructs a new {@code Template} object.
         */
        public Template (App.Views.AppView view) {
            this.view = view;

            this.author = view.author_entry.text;
            this.author_email = view.author_email_entry.text;
            this.dark_mode = view.dark_mode_switch.active;
            this.description = view.description_textview.get_buffer ().text;
            this.directory = view.dir_path ();
            this.domain = view.domain_entry.text;
            this.executable = view.exec_entry.text;
            this.git = view.git_switch.active;
            this.libraries = view.libraries_list ();
            this.license = view.license_combo.active_id;
            this.packages = view.packages_list ();
            this.punchline = view.punchline_entry.text;
            this.template = view.template_combo.active_id;
            this.title = view.title_entry.text;
            this.repo_url = view.repo_entry.text;
            this.rdnn = view.executable_label.label;
            this.rdnn_path = "/" + rdnn.replace (".", "/") +"/";
            this.website = view.website_entry.text;

            // Add defaults to libraries (used in meson dependencies) and packages (use for apt dev packages)
            this.libraries = "gobject-2.0, glib-2.0, " + this.libraries;
            this.packages = "meson, valac, debhelper, " + this.packages;

            // Get colors
            headerbar_color = view.headerbar_color.hex ();
            headerbar_text_color = view.headerbar_text_color.hex ();
            headerbar_shadow_color = view.headerbar_shadow_color.hex ();
            accent_color = view.accent_color.hex ();
            store_color = view.store_color.hex ();
            store_text_color = view.store_text_color.hex ();
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

        public bool generate_folder (string rdnn, string template) {
            if (rdnn == "" || template == "") {
                return false;
            }

            var export_path = "/tmp/"+ rdnn;
            var tar_path = "/tmp/"+ rdnn +".tar.gz";
            var template_file = File.new_for_uri ("resource:///com/github/kjlaw89/archetype/templates/" + template);
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
            var export_path = "/tmp/"+ rdnn;

            // Do an initial clean to clean up any previous attempts to generate this rdnn
            clean (rdnn);

            // Attempt to create our folder first
            if (!generate_folder (rdnn, template)) {
                return false;
            }

            /* Replaceable variables (in order of importance)
             * \/\* {{ preamble }} \*\/ - replace with preamble associated with selected license (replace first)
             * {{ license }} - replace with selected license content
             * {{ year }} - replace with current year (should be run after preamble)
             * {{ month }} - replace with current month
             * {{ day }} - replace with current day
             * {{ app-name }} - replace with title
             * {{ punchline }} - replace with punchline
             * {{ description }} - replace with description
             * {{ author }} - replace with author
             * {{ author-email }} - replace with author_email
             * {{ rdnn-path }} - replace with rdnn_path
             * {{ repo-url }} - still need to get
             * {{ website-url }} - still need to get 
             * {{ exe-name }} - replace with executable
             * {{ path }} - replace with path application will be stored in
             * {{ libraries-control }} - replace with packages (formatted for debian control file)
             * {{ libraries-readme }} - replace with packages formatted for README.md
             * {{ libraries-meson }} - replace with libraries formatted for meson
             * {{ screenshot-url }} - replace with nothing for now (no good way to get this)
             * {{ app-center-bg }} - need to get
             * {{ app-center-text }} - need to get
             * {{ app-center-price }} - need to get (default to 0)
             * {{ categories }} - need to get (replace with nothing)
             * {{ keywords }} - need to get (replace with nothing)
             * {{ terminal-mode }} - replace with true if terminal app, false otherwise
             * {{ license-code }} - replace with Gtk.LICENSE constant for selected license (https://valadoc.org/gtk+-3.0/Gtk.License.html)
             * {{ license-type }} - replace with README license for badge
             * \/\* {{ styles }} \*\/ - replace with all of the colors provided for branding
             * \/\* {{ dark-mode }} \*\/ - replace with code to enable dark mode
             * \/\* {{ headerbar-style-code }} \*\/ - replace with style code for the headerbar
             * com.generic.rdnn - replace with rdnn (filenames and content)
             * move directory
             */

            var license_file = File.new_for_uri ("resource:///com/github/kjlaw89/archetype/licenses/" + this.license);
            uint8[] license_data;

            try {
                if (!license_file.load_contents (null, out license_data, null)) {
                    warning ("Unable to load license resource");
                    return false;
                }
            }
            catch (Error e) {
                warning ("Unable to get license " + e.message);
                return false;
            }

            var license_preamble_file = File.new_for_uri ("resource:///com/github/kjlaw89/archetype/licenses/"+ this.license +"-preamble");
            uint8[] license_preamble_data;

            try {
                if (!license_preamble_file.load_contents (null, out license_preamble_data, null)) {
                    warning ("Unable to load license preamble resource");
                    return false;
                }
            }
            catch (Error e) {
                warning ("Unable to get license preamble " + e.message);
                return false;
            }

            var dt = new DateTime.now_local ();

            replace_in_files (export_path, "/* {{ preamble }} */", format_preamble ((string)license_preamble_data));
            replace_in_files (export_path, "{{ license }}", (string)license_data);
            replace_in_files (export_path, "{{ year }}", dt.get_year ().to_string ());
            replace_in_files (export_path, "{{ month }}", dt.get_month ().to_string ());
            replace_in_files (export_path, "{{ day }}", dt.get_day_of_month ().to_string ());
            replace_in_files (export_path, "{{ title }}", title);
            replace_in_files (export_path, "{{ headerbar-title }}", (template != "widget") ? title : "");
            replace_in_files (export_path, "{{ punchline }}", punchline);
            replace_in_files (export_path, "{{ description }}", description);
            replace_in_files (export_path, "{{ path }}", "file://" + directory);
            replace_in_files (export_path, "{{ author }}", author);
            replace_in_files (export_path, "{{ author-email }}", author_email);
            replace_in_files (export_path, "{{ rdnn-path }}", rdnn_path);
            replace_in_files (export_path, "{{ libraries-control }}", format_libraries_control (packages));
            replace_in_files (export_path, "{{ libraries-readme }}", format_libraries_readme (packages));
            replace_in_files (export_path, "{{ libraries-meson }}", format_libraries_meson (libraries));
            replace_in_files (export_path, "{{ categories }}", "");
            replace_in_files (export_path, "{{ keywords }}", "");
            replace_in_files (export_path, "{{ terminal-mode }}", (template == "terminal" ? "true" : "false"));
            replace_in_files (export_path, "{{ license-code }}", format_license_type (license));
            replace_in_files (export_path, "{{ license-type }}", license.up ());
            replace_in_files (export_path, "{{ repo-url }}", (repo_url == "") ? null : repo_url);
            replace_in_files (export_path, "{{ website-url }}", (website == "") ? null : website);
            replace_in_files (export_path, "{{ store-color }}", (store_color == null) ? "#FFFFFF" : store_color);
            replace_in_files (export_path, "{{ store-color-text }}", (store_text_color == null) ? "#000000" : store_text_color);
            replace_in_files (export_path, "{{ store-price }}", "0");
            replace_in_files (export_path, "{{ resizable }}", (template == "utility" || template =="widget") ? "false" : "true");
            replace_in_files (export_path, "/* {{ styles }} */", generate_styles ());
            replace_in_files (export_path, "/* {{ dark-mode }} */", dark_mode ? "Gtk.Settings.get_default ().set (\"gtk-application-prefer-dark-theme\", true);" : "");
            replace_in_files (export_path, "/* {{ headerbar-style-code }} */", (template == "utility") ? "get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);" : "");
            replace_in_files (export_path, "/* {{ window-style-code }} */", generate_window_styles ());
            replace_in_files (export_path, "com.generic.rdnn", rdnn);
            replace_in_filenames (export_path, "com.generic.rdnn", rdnn);

            if (git) {
                initialize_git (export_path);
            }

            // Move directory
            var source_dir = File.new_for_path (export_path);
            var dest_dir = File.new_for_path (directory);

            try {
                if (!source_dir.move (dest_dir, FileCopyFlags.NONE)) {
                    warning ("Unable to move temp directory to " + directory);
                    clean (rdnn);
                    return false;
                }
            }
            catch (Error e) {
                warning ("Unable to move temp directory to "+ directory +" - "+ e.message);
                clean (rdnn);
                return false;
            }
            

            // Clean up after the build process (only the .tar.gz should be left)
            clean (rdnn);
            return true;
        }

        public bool validate_rdnn (string rdnn) {
            var rdnn_regex = new Regex ("^[a-z]{2,6}\\.[a-zA-Z0-9\\-_]{1,30}\\.([a-zA-Z0-9\\-_]{1,30}\\.?)+$");
            return rdnn_regex.match (rdnn);
        }

        public int replace_in_files (string path, string? search, string? replace) {
            if (path == null || path == "" || search == null || search == "" || replace == null) {
                return 0;
            }

            string output;
            Process.spawn_command_line_sync ("grep -r \""+ escape_regex (search) +"\" "+ path, out output);

            var modified = 0;
            var files = output.split ("\n");
            foreach (var f in files) {
                if (f == "") {
                    continue;
                }

                var file_split = f.split (":");
                var file = File.new_for_path (file_split[0]);
                uint8[] data;

                try {
                    if (!file.load_contents (null, out data, null)) {
                        warning ("Unable to load contents of " + file_split[0]);
                        continue;
                    }
                }
                catch (Error e) {
                    warning ("Unable to get contents of "+ file_split[0] +" - "+ e.message);
                }

                var content = (string)data;
                content = content.replace (search, replace);
                file.replace_contents (content.data, null, false, FileCreateFlags.NONE, null);
                
                modified++;
            }

            return modified;
        }

        public int replace_in_filenames (string path, string? search, string? replace) {
            if (path == null || path == "" || search == null || search == "" || replace == null) {
                return 0;
            }

            string output;
            Process.spawn_command_line_sync ("find "+ path +" -name \"*"+ search +"*\" -print", out output);

            var modified = 0;
            var files = output.split ("\n");
            foreach (var f in files) {
                if (f == "") {
                    continue;
                }

                var file_split = f.split (":");
                var file = File.new_for_path (file_split[0]);
                var new_name = file.get_basename ().replace (search, replace);

                try {
                    file.set_display_name (new_name);
                    modified++;
                }
                catch (Error e) {
                    warning ("Unable to rename file "+ file_split[0] +" - "+ e.message);
                }
            }

            return modified;
        }

        public string escape_regex (string search) {
            return search
                .replace ("/", "\\/")
                .replace ("*", "\\*")
                .replace ("(", "\\(")
                .replace (")", "\\)");
        }

        private string format_preamble (string preamble) {
            var output = "/*\n";

            foreach (var line in preamble.split ("\n")) {
                output += "* " + line + "\n";
            }

            output += "*/";
            return output;
        }

        private void initialize_git (string path) {
            try {
                string[] init_args = { "git", "init" };
                Process.spawn_sync (path, init_args, Environ.get (), SpawnFlags.SEARCH_PATH, null);

                string[] add_args = { "git", "add", "." };
                Process.spawn_sync (path, add_args, Environ.get (), SpawnFlags.SEARCH_PATH, null);

                string[] commit_args = { "git", "commit", "-m", "Initial commit for " + title };
                Process.spawn_sync (path, commit_args, Environ.get (), SpawnFlags.SEARCH_PATH, null);
            }
            catch (Error e) {
                warning ("Unable to initialize GIT " + e.message);
            }
        }

        private string format_libraries_control (string libraries) {
            var output = "";

            var i = 0;
            var libs = libraries.split (",");
            foreach (var l in libs) {
                var library = l.strip ();

                if (i == 0) {
                    output = library +",\n";
                }
                else if (i == libs.length - 1) {
                    output += "               "+ library;
                }
                else {
                    output += "               "+ library +",\n";
                }
                
                i++;
            }

            return output;
        }

        private string format_libraries_readme (string libraries) {
            var output = "";

            foreach (var library in libraries.split (",")) {
                if (library == "") {
                    continue;
                }

                output += " - `" + library.strip () +"`\n";
            }

            return output;
        }

        private string format_libraries_meson (string libraries) {
            var output = "";

            var i = 0;
            var libs = libraries.split (",");
            foreach (var l in libs) {
                var library = l.strip ();

                if (i == 0) {
                    output = "dependency('"+ library +"'),\n";
                }
                else if (i == libs.length - 1) {
                    output += "    dependency('"+ library +"')";
                }
                else {
                    output += "    dependency('"+ library +"'),\n";
                }
                
                i++;
            }

            return output;
        }

        private string format_license_type (string license) {
            switch (license) {
                case "agpl-3.0":
                    return "Gtk.License.CUSTOM";  // AGPL_3_0 is only available in Gtk 3.22+
                case "gpl-3.0":
                    return "Gtk.License.GPL_3_0";
                case "lgpl-3.0":
                    return "Gtk.License.LGPL_3_0";
                case "mit":
                    return "Gtk.License.MIT_X11";
                case "unlicense":
                    return "Gtk.License.UNKNOWN";
                case "apache-2.0":
                case "mpl-2.0":
                default:
                    return "Gtk.License.CUSTOM";
            }
        }

        private string generate_styles () {
            var output = "";

            if (headerbar_color != null) {
                output += "@define-color colorPrimary %s;\n".printf (headerbar_color);
            }
            else {
                output += "/* @define-color colorPrimary {{ headerbar-color }}; */\n";
            }

            if (headerbar_text_color != null) {
                output += "@define-color textColorPrimary %s;\n".printf (headerbar_text_color);
            }
            else {
                output += "/* @define-color textColorPrimary {{ headerbar-text-color }}; */\n";
            }

            if (headerbar_shadow_color != null) {
                output += "@define-color textColorPrimaryShadow %s;\n".printf (headerbar_shadow_color);
            }
            else {
                output += "/* @define-color textColorPrimaryShadow {{ headerbar-text-shadow-color }}; */\n";
            }

            if (accent_color != null) {
                output += "@define-color colorAccent %s;\n".printf (accent_color);
            }
            else {
                output += "/* @define-color colorAccent {{ accent-color }}; */\n";
            }

            // A widget should have the headerbar and body be the same color
            // Use the font color specified for the headerbar for the primary font color
            if (template == "widget") {
                output += "@define-color bg_highlight_color shade (@colorPrimary, 1.4);\n\n";
                output += ".titlebar, .background {\n";
                output += "    background-color: @colorPrimary; color: @textColorPrimary;\n";
                output += "    icon-shadow: 0 1px 1px shade (@textColorPrimaryShadow, 0.82)\n";
                output += "    text-shadow: 0 1px 1px shade (@textColorPrimaryShadow, 0.82);\n";
                output += "}\n";
            }

            return output;
        }

        private string generate_window_styles () {
            var output = "";

            switch (template) {
                case "widget":
                    output += "get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);\n";
                    output += "            set_keep_below (true);\n";
                    output += "            stick ();";
                    break;
                case "utility":
                    output += "get_style_context ().add_class (\"rounded\");";
                    break;
            }
            
            return output;
        }
    }
}
