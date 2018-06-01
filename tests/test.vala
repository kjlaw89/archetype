
/*
* Copyright (c) 2018 KJ Lawrence <kjtehprogrammer@gmail.com>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/


namespace App.Tests {

    /**
     * The {@code Application} class is a foundation for all granite-based applications.
     *
     * @see Granite.Application
     * @since 1.0.0
     */
    public class Testing {
        public Testing (string[] args) {
            Test.init (ref args);

            Test.add_data_func ("/asserts", () => {
                Assert.string_compare ("Test", "Test");
                Assert.bool_compare (true, true);
                Assert.true (true);
                Assert.false (false);

                Assert.int_compare (5, 5);
                Assert.int_compare (5, 6, "!=");
                Assert.int_compare (7, 5, ">");
                Assert.int_compare (7, 7, ">=");
                Assert.int_compare (5, 7, "<");
                Assert.int_compare (7, 7, "<=");

                Assert.float_compare (5.5f, 5.5f);
                Assert.float_compare (5.2f, 6.4f, "!=");
                Assert.float_compare (7.1f, 7.05f, ">");
                Assert.float_compare (7f, 7f, ">=");
                Assert.float_compare (7f, 7.1f, "<");
                Assert.float_compare (8.8f, 8.8f, "<=");

                Assert.double_compare (5.5, 5.5);
                Assert.double_compare (5.2, 6.4, "!=");
                Assert.double_compare (7.1, 7.05, ">");
                Assert.double_compare (7, 7, ">=");
                Assert.double_compare (7, 7.1, "<");
                Assert.double_compare (8.8, 8.8, "<=");
            });

            Test.add_data_func ("/app/colorwidget", () => {
                var widget = new App.Widgets.ColorWidget ("TButton", "Test Button", "#FFFFFF");

                Assert.string_compare ("TButton", widget.label.label);
                Assert.string_compare ("Test Button", widget.label.tooltip_text);
                Assert.string_compare ("Test Button", widget.button.title);
                Assert.string_compare ("rgb(255,255,255)", widget.color.to_string ());
            });

            Test.add_data_func ("/app/form/project/validate", () => {
                var view = new App.Views.AppView ();
                Assert.false (view.next_button.sensitive);

                view.template_combo.active_id = "blank";
                view.license_combo.active_id = "mit";
                view.validate_next ();
                Assert.false (view.next_button.sensitive);

                view.title_entry.text = "Test";
                view.exec_entry.text = "test";
                view.validate_next ();
                Assert.false (view.next_button.sensitive);

                view.domain_entry.text = "com.github+";          // Bad RDNN
                view.domain_entry.changed ();
                view.validate_next ();
                Assert.false (view.next_button.sensitive);

                view.domain_entry.text = "com.github.test";     // Good RDNN
                view.domain_entry.changed ();
                view.validate_next ();
                Assert.true (view.next_button.sensitive);

                view.domain_entry.text = "m.github.test";       // Bad RDNN
                view.domain_entry.changed ();
                view.validate_next ();
                Assert.false (view.next_button.sensitive);

                view.exec_entry.text = "test=";                 // Bad executable name
                view.domain_entry.changed ();
                view.validate_next ();
                Assert.false (view.next_button.sensitive);
            });

            Test.add_data_func ("/app/form/author/validate", () => {
                var view = new App.Views.AppView ();
                view.next ();

                Assert.false (view.next_button.sensitive);

                view.author_entry.text = "Test";
                view.author_email_entry.text = "test@test.com";
                view.validate_next ();
                Assert.true (view.next_button.sensitive);
            });

            Test.add_data_func ("/app/form/rdnn_executable", () => {
                var view = new App.Views.AppView ();
                
                view.exec_entry.text = "test";
                view.domain_entry.text = "com.github.person";
                view.domain_entry.changed ();

                Assert.string_compare ("com.github.person.test", view.executable_label.label);
            });

            Test.add_data_func ("/app/form/dir_path", () => {
                var view = new App.Views.AppView ();
                
                view.exec_entry.text = "test";
                view.directory_button.set_current_folder ("/unit-test");
                view.directory_button.file_set ();

                var directory = "/unit-test/test";
                Assert.string_compare (directory, view.directory_executable_label.label);
            });

            Test.add_data_func ("/app/form/libraries_list", () => {
                var view = new App.Views.AppView ();
                Assert.string_compare ("libgranite-dev, libgtk-3-dev", view.libraries_list ());

                view.toggle_library ("libunity-dev", true);
                Assert.string_compare ("libgranite-dev, libgtk-3-dev, libunity-dev", view.libraries_list ());

                view.toggle_library ("libgranite-dev", false);
                Assert.string_compare ("libgtk-3-dev, libunity-dev", view.libraries_list ());
            });

            Test.add_data_func ("/template/setup", () => {
                var view = new App.Views.AppView ();

                view.template_combo.active_id = "blank";
                view.license_combo.active_id = "mit";
                view.title_entry.text = "Test";
                view.exec_entry.text = "test";
                view.domain_entry.text = "com.github";
                view.domain_entry.changed ();
                view.author_entry.text = "Test Person";
                view.author_email_entry.text = "test@test.com";
                view.punchline_entry.text = "Punch!";
                view.dark_mode_switch.active = true;
                view.directory_button.set_uri ("file:///tmp/");

                var template = new App.Models.Template (view);
                Assert.string_compare ("blank", template.template);
                Assert.string_compare ("mit", template.license);
                Assert.string_compare ("Test", template.title);
                Assert.string_compare ("test", template.executable);
                Assert.string_compare ("com.github.test", template.rdnn);
                Assert.string_compare ("/com/github/test/", template.rdnn_path);
                Assert.string_compare ("Test Person", template.author);
                Assert.string_compare ("test@test.com", template.author_email);
                Assert.string_compare ("Punch!", template.punchline);
                Assert.true (template.dark_mode);
                Assert.string_compare ("file:///tmp", template.directory);
            });

            Test.add_data_func ("/template/create_and_clean", () => {
                var view = new App.Views.AppView ();
                var template = new App.Models.Template (view);
                var name = "com.test.app";

                // Reset to a good state by deleting any existing files
                template.clean (name);

                Assert.true (template.generate_folder (name));

                // Test that our file was extract (see if README.md exists)
                var readme_file = File.new_for_path ("/tmp/"+ name +"/README.md");
                Assert.true (readme_file.query_exists ());
                Assert.true (template.clean (name));
            });            
        }

        public void run () {
            Test.run ();
        }
    }
}
