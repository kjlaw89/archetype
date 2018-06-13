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
using App.Widgets;

namespace App.Views {

    /**
     * The {@code AppView} class.
     *
     * @since 1.0.0
     */
    public class AppView : Gtk.Box {

        // Labels
        private Gtk.Label           author_label;
        private Gtk.Label           author_email_label;
        private Gtk.Label           branding_label;
        private Gtk.Label           dark_mode_label;
        private Gtk.Label           description_label;
        private Gtk.Label           directory_label;
        private Gtk.Label           domain_label;
        private Gtk.Label           exec_label;
        private Gtk.Label           git_label;
        private Gtk.Label           license_label;
        private Gtk.Label           libraries_label;
        private Gtk.Label           punchline_label;
        private Gtk.Label           repo_label;
        private Gtk.Label           store_label;
        private Gtk.Label           template_label;
        private Gtk.Label           title_label;
        private Gtk.Label           website_label;
        
        // Widgets
        public Gtk.Entry           author_entry                 { get; private set; }
        public Gtk.Entry           author_email_entry           { get; private set; }
        public Gtk.Button          back_button                  { get; private set; }
        public Gtk.Grid            branding_box                 { get; private set; }
        public Gtk.Switch          dark_mode_switch             { get; private set; }
        public Gtk.TextView        description_textview         { get; private set; }
        public Gtk.FileChooserButton directory_button           { get; private set; }
        public Gtk.Label           directory_executable_label   { get; private set; }
        public Gtk.Entry           domain_entry                 { get; private set; }
        public Gtk.Label           error_label                  { get; private set; }
        public Gtk.Entry           exec_entry                   { get; private set; }
        public Gtk.Label           executable_label             { get; private set; }
        public Gtk.Button          generate_button              { get; private set; }
        public Gtk.Switch          git_switch                   { get; private set; }
        public Gtk.Button          next_button                  { get; private set; }
        public Gtk.ComboBoxText    license_combo                { get; private set; }
        public Gtk.Button          license_lookup_button        { get; private set; }
        public Gtk.ListBox         libraries_listbox            { get; private set; }
        public Gtk.Popover         libraries_popover            { get; private set; }
        public Gtk.Entry           libraries_values_entry       { get; private set; }
        public Gtk.Entry           punchline_entry              { get; private set; }
        public Gtk.Entry           repo_entry                   { get; private set; }
        public Gtk.Stack           stack_view                   { get; private set; }
        public Gtk.Grid            store_box                    { get; private set; }
        public Gtk.ComboBoxText    template_combo               { get; private set; }
        public Gtk.Entry           title_entry                  { get; private set; }
        public Gtk.Entry           website_entry                { get; private set; }

        // Colors
        public ColorWidget         headerbar_color              { get; private set; }
        public ColorWidget         headerbar_text_color         { get; private set; }
        public ColorWidget         headerbar_shadow_color       { get; private set; }
        public ColorWidget         accent_color                 { get; private set; }
        public ColorWidget         store_color                  { get; private set; }
        public ColorWidget         store_text_color             { get; private set; }

        private string _stage;     // Track stage through variable for testing
        public string stage { 
            get { return _stage; } 
            private set {
                stack_view.visible_child_name = value;
                _stage = value;
            }
        }

        public signal void generate ();

        /**
         * Constructs a new {@code AppView} object.
         */
        public AppView () {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 12;
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            stack_view = new Gtk.Stack ();
            stack_view.vhomogeneous = true;
            stack_view.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

            build_project_form ();
            build_author_form ();
            build_branding_form ();
            build_development_form ();
            build_libraries_list ();

            // Buttons row
            generate_button = new Gtk.Button.with_mnemonic (_("_Generate Project"));
            generate_button.get_style_context ().add_class ("suggested-action");
            generate_button.hexpand = true;
            generate_button.halign = Gtk.Align.END;
            generate_button.clicked.connect (() => {
                next ();
            });

            next_button = new Gtk.Button.with_mnemonic (_("_Next"));
            next_button.get_style_context ().add_class ("suggested-action");
            next_button.hexpand = true;
            next_button.halign = Gtk.Align.END;
            next_button.clicked.connect (() => {
                next ();
            });

            back_button = new Gtk.Button.with_mnemonic (_("_Back"));
            back_button.get_style_context ();
            back_button.halign = Gtk.Align.END;
            back_button.clicked.connect (() => {
                back ();
            });

            error_label = new Gtk.Label (null);
            error_label.get_style_context ().add_class ("error");

            var action_buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            action_buttons_box.halign = Gtk.Align.END;
            action_buttons_box.add (back_button);
            action_buttons_box.add (next_button);
            action_buttons_box.add (generate_button);

            var buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            buttons_box.hexpand = true;
            buttons_box.margin_top = 24;
            buttons_box.add (error_label);
            buttons_box.add (action_buttons_box);

            this.add (stack_view);
            this.add (buttons_box);
            
            stage = "project";
            toggle_buttons ();
            validate_next ();
        }

        public new void activate () {
            stage = "project";
            toggle_buttons ();
            validate_next ();
        }

        public void toggle_buttons () {
            generate_button.hide ();
            back_button.hide ();
            next_button.hide ();

            switch (stage) {
                case "project":
                    next_button.show ();
                    break;
                case "author":
                    back_button.show ();
                    next_button.show ();
                    break;
                case "branding":
                    back_button.show ();
                    next_button.show ();
                    break;
                case "development":
                    back_button.show ();
                    generate_button.show ();
                    break;
            }

            validate_next ();
        }

        public void back () {
            switch (stage) {
                case "project":
                    stage = "project";
                    break;
                case "author":
                    stage = "project";
                    template_combo.has_focus = true;
                    break;
                case "branding":
                    stage = "author";
                    author_entry.has_focus = true;
                    break;
                case "development":
                    stage = "branding";
                    dark_mode_switch.has_focus = true;
                    break;
            }

            toggle_buttons ();
        }
        
        public void next () {
            switch (stage) {
                case "project":
                    stage = "author";
                    author_entry.has_focus = true;
                    break;
                case "author":
                    stage = "branding";
                    dark_mode_switch.has_focus = true;
                    break;
                case "branding":
                    stage = "development";
                    directory_button.has_focus = true;
                    libraries_list ();
                    break;
                case "development":
                    this.generate ();
                    break;
            }

            toggle_buttons ();
        }

        public void validate_next () {
            var valid = true;
            
            switch (stage) {
                case "project":
                    if (template_combo.active_id == null || license_combo.active_id == null || title_entry.text == "") {
                        valid = false;
                    }

                    var exec_regex = new Regex ("^[a-zA-Z0-9\\-_]{1,40}$");
                    if (exec_entry.text == "" || !exec_regex.match (exec_entry.text)) {
                        valid = false;
                    }

                    var rdnn_regex = new Regex ("^[a-z]{2,6}\\.[a-zA-Z0-9\\-_]{1,30}\\.([a-zA-Z0-9\\-_]{1,30}\\.?)+$");
                    if (domain_entry.text == "" || !rdnn_regex.match (executable_label.label)) {
                        valid = false;
                    }


                    break;
                case "author":
                    if (author_entry.text == "" || author_email_entry.text == "") {
                        valid = false;
                    }

                    break;
                case "branding":
                    valid = true;
                    break;
                case "development":
                    if (directory_button.get_uri () == null) {
                        valid = false;
                        generate_button.sensitive = false;
                    }
                    else {
                        generate_button.sensitive = true;
                    }
                    break;
                default:
                    valid = false;
                    break;
            }

            next_button.sensitive = valid;
        }

        public string rdnn_executable () {
            var valid = true;

            var exec_regex = new Regex ("^[a-zA-Z0-9\\-_]{1,40}$");
            if (exec_entry.text == "" || !exec_regex.match (exec_entry.text)) {
                valid = false;
            }

            var rdnn_regex = new Regex ("^[a-z]{2,6}\\.([a-zA-Z0-9\\-_]{1,30}\\.?)+$");
            if (domain_entry.text == "" || !rdnn_regex.match (domain_entry.text)) {
                valid = false;
            }

            executable_label.label = valid ? domain_entry.text +"."+ exec_entry.text : "";
            return executable_label.label;
        }

        public string dir_path () {
            var full_path = directory_button.get_uri ();
            var directory = full_path;
            if (directory == null) {
                return "";
            }

            directory = directory.replace ("file:///", "/");
            if (directory.length > 35) {
                directory = "..." + directory.substring (directory.length - 35);
            }

            directory_executable_label.label = directory + "/" + rdnn_executable ();
            return directory_executable_label.label;
        }

        public string libraries_list () {
            var list = new Array<string?> ();
            foreach (var widget in libraries_listbox.get_children ()) {
                LibraryRow row = (LibraryRow)widget;
                if (row.active) {
                    list.append_val (row.library.library);
                }
            }

            var output = string.joinv (", ", list.data);
            libraries_values_entry.text = output;
            return output;
        }

        public string packages_list () {
            var list = new Array<string?> ();
            foreach (var widget in libraries_listbox.get_children ()) {
                LibraryRow row = (LibraryRow)widget;
                if (row.active) {
                    list.append_val (row.library.package);
                }
            }

            var output = string.joinv (", ", list.data);
            return output;
        }

        public void toggle_library (string? library, bool active, bool all = false) {
            foreach (var widget in libraries_listbox.get_children ()) {
                LibraryRow row = (LibraryRow)widget;
                if (row.library.library == library || all) {
                    row.active = active;
                }
            }

            libraries_list ();
        }

        public void disable_git () {
            git_label.hide ();
            git_switch.hide ();
            git_switch.active = false;
        }

        private void build_project_form () {
            var grid = new Gtk.Grid ();
            grid.expand = true;
            grid.column_spacing = 12;
            grid.row_spacing = 12;

            grid.attach (new Granite.HeaderLabel (_("Project Details")), 0, 0, 4, 1);
            
            // Template list
            template_combo = new Gtk.ComboBoxText ();
            template_combo.hexpand = true;
            template_combo.append ("granite", "Granite App (Headerbar + Welcome screen)");
            template_combo.append ("utility", "Utility (Flat headerbar, no maximize)");
            template_combo.append ("widget", "Widget (No headerbar, sticky to desktop)");
            template_combo.append ("blank", "Blank GTK Window");
            template_combo.append ("terminal", "Terminal App (No GUI)");
            template_combo.changed.connect (() => {
                validate_next ();

                switch (template_combo.active_id) {
                    case "granite":
                    case "utility":
                    case "widget":
                        toggle_library ("granite", true);
                        toggle_library ("gtk+-3.0", true);
                        break;
                    case "blank":
                        toggle_library ("granite", false);
                        toggle_library ("gtk+-3.0", true);
                        break;
                    case "terminal":
                        toggle_library ("granite", false);
                        toggle_library ("gtk+-3.0", false);
                        break;
                }
            });

            template_label = new Gtk.Label.with_mnemonic (_("Tem_plate") + ":");
            template_label.halign = Gtk.Align.END;
            template_label.mnemonic_widget = template_combo;

            grid.attach (template_label, 0, 1, 1, 1);
            grid.attach (template_combo, 1, 1, 3, 1);

            // License list
            license_combo = new Gtk.ComboBoxText ();
            license_combo.hexpand = true;
            license_combo.append ("agpl-3.0", "GNU AGPLv3");
            license_combo.append ("apache-2.0", "Apache 2.0");
            license_combo.append ("gpl-3.0", "GNU GPLv3");
            license_combo.append ("lgpl-3.0", "GNU LGPLv3");
            license_combo.append ("mit", "MIT");
            license_combo.append ("mpl-2.0", "Mozilla Public");
            license_combo.append ("unlicense", "Unlicense");
            license_combo.append ("custom", "Custom or Proprietary");
            license_combo.changed.connect (() => {
                validate_next ();
            });

            license_lookup_button = new Gtk.Button.from_icon_name ("dialog-question", Gtk.IconSize.MENU);
            license_lookup_button.tooltip_text = _("See license");
            license_lookup_button.clicked.connect (() => { this.show_license (); });

            license_label = new Gtk.Label.with_mnemonic (_("_License") + ":");
            license_label.halign = Gtk.Align.END;
            license_label.mnemonic_widget = license_combo;

            var license_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            license_box.add (license_combo);
            license_box.add (license_lookup_button);

            grid.attach (license_label, 0, 2, 1, 1);
            grid.attach (license_box, 1, 2, 3, 1);

            // Title entry
            title_entry = new Gtk.Entry ();
            title_entry.hexpand = true;
            title_entry.placeholder_text = "My app";
            title_entry.key_release_event.connect ((key) => {
                validate_next ();
                return false;
            });

            title_label = new Gtk.Label.with_mnemonic (_("_Title") + ":");
            title_label.halign = Gtk.Align.END;
            title_label.mnemonic_widget = title_entry;

            grid.attach (title_label, 0, 3, 1, 1);
            grid.attach (title_entry, 1, 3, 1, 1);

            // Executable Name Entry
            exec_entry = new Gtk.Entry ();
            exec_entry.hexpand = true;
            exec_entry.placeholder_text = "myapp";
            exec_entry.secondary_icon_name = "dialog-information-symbolic";
            exec_entry.secondary_icon_tooltip_text = _("Executable names should be lowercase alphanumeric [a-z0-9]");
            exec_entry.key_release_event.connect ((key) => {
                validate_next ();
                rdnn_executable ();
                return false;
            });
            exec_entry.changed.connect (() => {
                validate_next ();
                rdnn_executable ();
            });

            exec_label = new Gtk.Label.with_mnemonic (_("E_xecutable") + ":");
            exec_label.halign = Gtk.Align.END;
            exec_label.mnemonic_widget = exec_entry;

            grid.attach (exec_label, 2, 3, 1, 1);
            grid.attach (exec_entry, 3, 3, 1, 1);

            // Domain Entry
            domain_entry = new Gtk.Entry ();
            domain_entry.hexpand = true;
            domain_entry.placeholder_text = "com.github.you";
            domain_entry.secondary_icon_name = "dialog-information-symbolic";
            domain_entry.secondary_icon_tooltip_text = _("Should be a valid RDNN");
            domain_entry.key_release_event.connect ((key) => {
                validate_next ();
                rdnn_executable ();
                return false;
            });
            domain_entry.changed.connect (() => {
                validate_next ();
                rdnn_executable ();
            });

            executable_label = new Gtk.Label (null);
            executable_label.get_style_context ().add_class ("small_label");
            executable_label.halign = Gtk.Align.START;

            domain_label = new Gtk.Label.with_mnemonic (_("D_omain") + ":");
            domain_label.halign = Gtk.Align.END;
            domain_label.valign = Gtk.Align.START;
            domain_label.margin_top = 4;
            domain_label.mnemonic_widget = domain_entry;

            grid.attach (domain_label, 0, 4, 1, 1);
            grid.attach (domain_entry, 1, 4, 1, 1);
            grid.attach (executable_label, 2, 4, 2, 1);

            this.stack_view.add_named (grid, "project");
        }

        private void build_author_form () {
            var grid = new Gtk.Grid ();
            grid.expand = true;
            grid.column_spacing = 12;
            grid.row_spacing = 12;

            grid.attach (new Granite.HeaderLabel (_("Author & Description")), 0, 0, 4, 1);

            // Author entry
            author_entry = new Gtk.Entry ();
            author_entry.hexpand = true;
            author_entry.placeholder_text = _("Your name");
            author_entry.key_release_event.connect ((key) => {
                validate_next ();
                return false;
            });

            author_label = new Gtk.Label.with_mnemonic (_("_Author") + ":");
            author_label.halign = Gtk.Align.END;
            author_label.mnemonic_widget = author_entry;

            grid.attach (author_label, 0, 1, 1, 1);
            grid.attach (author_entry, 1, 1, 1, 1);

            // Author email Entry
            author_email_entry = new Gtk.Entry ();
            author_email_entry.hexpand = true;
            author_email_entry.placeholder_text = "youremail@domain.com";
            author_email_entry.key_release_event.connect ((key) => {
                validate_next ();
                return false;
            });

            author_email_label = new Gtk.Label.with_mnemonic (_("_Email") + ":");
            author_email_label.halign = Gtk.Align.END;
            author_email_label.mnemonic_widget = author_email_entry;

            grid.attach (author_email_label, 2, 1, 1, 1);
            grid.attach (author_email_entry, 3, 1, 1, 1);


            // Website entry
            website_entry = new Gtk.Entry ();
            website_entry.hexpand = true;
            website_entry.placeholder_text = _("https://www.yourwebsite.com/");
            website_entry.key_release_event.connect ((key) => {
                validate_next ();
                return false;
            });

            website_label = new Gtk.Label.with_mnemonic (_("_Website") + ":");
            website_label.halign = Gtk.Align.END;
            website_label.mnemonic_widget = website_entry;

            grid.attach (website_label, 0, 2, 1, 1);
            grid.attach (website_entry, 1, 2, 3, 1);

            // Punchline entry
            punchline_entry = new Gtk.Entry ();
            punchline_entry.hexpand = true;
            punchline_entry.placeholder_text = _("A short punchline");
            punchline_entry.key_release_event.connect ((key) => {
                validate_next ();
                return false;
            });

            punchline_label = new Gtk.Label.with_mnemonic (_("_Punchline") + ":");
            punchline_label.halign = Gtk.Align.END;
            punchline_label.mnemonic_widget = punchline_entry;

            grid.attach (punchline_label, 0, 3, 1, 1);
            grid.attach (punchline_entry, 1, 3, 3, 1);

            // Long description entry
            description_textview = new Gtk.TextView ();
            description_textview.hexpand = true;
            description_textview.margin = 4;
            description_textview.key_release_event.connect ((key) => {
                validate_next ();
                return false;
            });

            description_label = new Gtk.Label.with_mnemonic (_("De_scription") + ":");
            description_label.valign = Gtk.Align.START;
            description_label.halign = Gtk.Align.END;
            description_label.mnemonic_widget = description_textview;

            var desc_frame = new Gtk.Frame (null);
            desc_frame.height_request = 60;

            var desc_scroll = new Gtk.ScrolledWindow (null, null);

            desc_frame.add (desc_scroll);
            desc_scroll.add (description_textview);

            grid.attach (description_label, 0, 4, 1, 1);
            grid.attach (desc_frame, 1, 4, 3, 1);

            this.stack_view.add_named (grid, "author");
        }

        private void build_branding_form () {
            var grid = new Gtk.Grid ();
            grid.expand = true;
            grid.column_spacing = 12;
            grid.row_spacing = 12;

            grid.attach (new Granite.HeaderLabel (_("Branding & Design")), 0, 0, 4, 1);

            // Dark mode switch
            dark_mode_label = new Gtk.Label.with_mnemonic (_("Dark _Mode") + ":");
            dark_mode_label.halign = Gtk.Align.END;

            dark_mode_switch = new Gtk.Switch ();
            dark_mode_switch.hexpand = false;
            dark_mode_switch.halign = Gtk.Align.START;
            dark_mode_switch.state_set.connect ((state) => {
                Gtk.Settings.get_default ().set ("gtk-application-prefer-dark-theme", state);
                return false;
            });

            grid.attach (dark_mode_label, 0, 1, 1, 1);
            grid.attach (dark_mode_switch, 1, 1, 1, 1);

            // Branding colors box
            branding_label = new Gtk.Label.with_mnemonic (_("App. Colors") + ":");
            branding_label.valign = Gtk.Align.START;
            branding_label.halign = Gtk.Align.END;

            branding_box = new Gtk.Grid ();
            branding_box.hexpand = true;
            branding_box.column_homogeneous = true;
            branding_box.column_spacing = 12;
            branding_box.row_spacing = 12;

            headerbar_color = new ColorWidget ("Headerbar", "Headerbar");
            headerbar_text_color = new ColorWidget ("H. Text", "Headerbar Text");
            headerbar_shadow_color = new ColorWidget ("H. Text Shadow", "Headerbar Text Shadow");
            accent_color = new ColorWidget ("Accent Color", "Accent Color");

            branding_box.attach (headerbar_color, 0, 0);
            branding_box.attach (headerbar_text_color, 1, 0);
            branding_box.attach (headerbar_shadow_color, 2, 0);
            branding_box.attach (accent_color, 3, 0);

            grid.attach (branding_label, 0, 2, 1, 1);
            grid.attach (branding_box, 1, 2, 3, 1);

            // Store colors box
            store_label = new Gtk.Label.with_mnemonic (_("Store Colors") + ":");
            store_label.valign = Gtk.Align.START;
            store_label.halign = Gtk.Align.END;

            store_box = new Gtk.Grid ();
            store_box.hexpand = true;
            store_box.column_homogeneous = true;
            store_box.column_spacing = 12;
            store_box.row_spacing = 12;

            store_color = new ColorWidget ("Background", "Store background color");
            store_text_color = new ColorWidget ("Text", "Store text color");

            store_box.attach (store_color, 0, 0);
            store_box.attach (store_text_color, 1, 0);

            grid.attach (store_label, 0, 3, 1, 1);
            grid.attach (store_box, 1, 3, 3, 1);

            this.stack_view.add_named (grid, "branding");
        }

        private void build_development_form () {
            var grid = new Gtk.Grid ();
            grid.expand = true;
            grid.column_spacing = 12;
            grid.row_spacing = 12;

            grid.attach (new Granite.HeaderLabel (_("Development")), 0, 0, 4, 1);

            // Directory Entry
            directory_label = new Gtk.Label.with_mnemonic (_("_Directory") + ":");
            directory_label.halign = Gtk.Align.END;
            directory_label.valign = Gtk.Align.START;
            directory_label.margin_top = 4;

            directory_button = new Gtk.FileChooserButton ("Project Directory", Gtk.FileChooserAction.SELECT_FOLDER);
            directory_button.hexpand = true;
            directory_button.file_set.connect (() => {
                validate_next ();
                dir_path ();
            });

            directory_executable_label = new Gtk.Label (null);
            directory_executable_label.halign = Gtk.Align.START;
            directory_executable_label.get_style_context ().add_class ("small_label");

            var directory_executable_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            directory_executable_box.width_request = 175;
            directory_executable_box.add (directory_executable_label);

            grid.attach (directory_label, 0, 1, 1, 1);
            grid.attach (directory_button, 1, 1, 1, 1);
            grid.attach (directory_executable_box, 2, 1, 1, 1);

            // Libraries label
            libraries_label = new Gtk.Label.with_mnemonic (_("_Libraries") + ":");
            libraries_label.halign = Gtk.Align.END;
            libraries_label.valign = Gtk.Align.START;
            libraries_label.margin_top = 4;            

            libraries_values_entry = new Gtk.Entry ();
            libraries_values_entry.sensitive = true;
            libraries_values_entry.secondary_icon_name = "tag-new";
            libraries_values_entry.secondary_icon_tooltip_text = _("Modify selected libraries");

            libraries_values_entry.key_press_event.connect ((event) => {
                return true;
            });

            libraries_values_entry.icon_release.connect ((pos, event) => {
                show_libraries_list ();
            });

            grid.attach (libraries_label, 0, 2, 1, 1);
            grid.attach (libraries_values_entry, 1, 2, 3, 1);

            // Repo entry
            repo_entry = new Gtk.Entry ();
            repo_entry.hexpand = true;
            repo_entry.placeholder_text = _("https://github.com/.../...");
            repo_entry.key_release_event.connect ((key) => {
                validate_next ();
                return false;
            });

            repo_label = new Gtk.Label.with_mnemonic (_("_Repository URL") + ":");
            repo_label.halign = Gtk.Align.END;
            repo_label.mnemonic_widget = repo_entry;

            grid.attach (repo_label, 0, 3, 1, 1);
            grid.attach (repo_entry, 1, 3, 3, 1);

            // GIT initialize switch
            git_label = new Gtk.Label.with_mnemonic (_("_Initialize GIT") + ":");
            git_label.halign = Gtk.Align.END;

            git_switch = new Gtk.Switch ();
            git_switch.hexpand = false;
            git_switch.halign = Gtk.Align.START;
            git_switch.active = true;

            grid.attach (git_label, 0, 4, 1, 1);
            grid.attach (git_switch, 1, 4, 1, 1);

            this.stack_view.add_named (grid, "development");
        }

        private void build_libraries_list () {
            libraries_listbox = new Gtk.ListBox ();
            libraries_listbox.selection_mode = Gtk.SelectionMode.NONE;
            libraries_listbox.get_style_context ().add_class ("libraries_list");

            foreach (var l in Constants.LIBRARIES) {
                var row = new LibraryRow (l);
                row.selected_changed.connect ((selected) => {
                    if (selected) {
                        libraries_listbox.select_row (row);
                    }
                    else {
                        libraries_listbox.unselect_row (row);
                    }
                });

                libraries_listbox.insert (row, -1);
            }

            var libraries_viewport = new Gtk.Viewport (null, null);
            libraries_viewport.add (libraries_listbox);

            var libraries_scrolled = new Gtk.ScrolledWindow (null, null);
            libraries_scrolled.width_request = 500;
            libraries_scrolled.height_request = 300;
            libraries_scrolled.add (libraries_viewport);

            libraries_popover = new Gtk.Popover (libraries_label);
            libraries_popover.position = Gtk.PositionType.RIGHT;
            libraries_popover.add (libraries_scrolled);
            libraries_popover.closed.connect (() => {
                this.libraries_list ();
            });
        }

        private void show_libraries_list () {
            libraries_popover.show_all ();
        }

        private bool show_license () {
            var license = license_combo.active_id;

            if (license != "custom") {
                Granite.Services.System.open_uri ("https://choosealicense.com/" + ((license == null) ? "" : "licenses/" + license));
            }
            else {
                var info_label = new Gtk.Label (_("LICENSE file is pre-created but empty. Terms will need to be put in it."));
                info_label.margin = 12;

                var popover = new Gtk.Popover (license_lookup_button);
                popover.position = Gtk.PositionType.BOTTOM;
                popover.add (info_label);
                popover.show_all ();
            }

            return false;
        }
    }
}
