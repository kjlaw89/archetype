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

namespace App.Configs {

    /**
     * The {@code Constants} class is responsible for defining all 
     * the constants used in the application.
     *
     * @since 1.0.0
     */
    public class Constants {
    
        public abstract const string ID = "com.github.kjlaw89.archetype";
        public abstract const string VERSION = "1.0.0";
        public abstract const string PROGRAME_NAME = "Archetype";
        public abstract const string APP_YEARS = "2018";
        public abstract const string APP_ICON = "com.github.kjlaw89.archetype";
        public abstract const string ABOUT_COMMENTS = "Create new Vala apps with ease";
        public abstract const string TRANSLATOR_CREDITS = "Github Translators";
        public abstract const string MAIN_URL = "https://kjlaw89.github.io/archetype";
        public abstract const string BUG_URL = "https://github.com/kjlaw89/archetype/issues";
        public abstract const string HELP_URL = "https://github.com/kjlaw89/archetype/wiki";
        public abstract const string TRANSLATE_URL = "https://kjlaw89.github.io/archetype";
        public abstract const string TEXT_FOR_ABOUT_DIALOG_WEBSITE = "Website";
        public abstract const string TEXT_FOR_ABOUT_DIALOG_WEBSITE_URL = "https://kjlaw89.github.io/archetype";
        public abstract const string URL_CSS = "com/github/kjlaw89/archetype/css/style.css";
        public abstract const string [] ABOUT_AUTHORS = { "KJ Lawrence <kjtehprogrammer@gmail.com>" };
        public abstract const Gtk.License ABOUT_LICENSE_TYPE = Gtk.License.GPL_3_0;
        public abstract const App.Widgets.Library [] LIBRARIES = {
            { "appindicator3-0.1",   "libappindicator3-dev",   "App Indictator",   "Desktop indicator icons",              false },
            { "libarchive",          "libarchive-dev",         "Archive",          "Library to create/read archive formats", false },
            { "cairo",               "libcairo2-dev",          "Cairo",            "2D Graphics library",                  false },
            { "libevent",            "libevent-dev",           "Event",            "Asynchronous event notifications library", false },
            { "granite",             "libgranite-dev",         "Granite",          "elementary extended GTK+",             true },
            { "gtk+-3.0",            "libgtk-3-dev",           "GTK+",             "Gnome UI Toolkit",                     true },
            { "javascriptcoregtk-4.0", "libjavascriptcoregtk-4.0-dev", "JS Core",  "JS Introspection data for GTK+",       false },
            { "json-glib-1.0",       "libjson-glib-dev",       "JSON",             "JSON Encoding/Decoding",               false },
            { "libmarkdown",         "libmarkdown2-dev",       "Markdown",         "Markdown to HTML convertor",           false },
            { "mysql",               "libmysqlclient-dev",     "MySQL",            "Client api for communicating with MySQL", false },
            { "libpeas-1.0",         "libpeas-dev",            "Libpeas",          "Plugins engine",                       false },
            { "libpq",               "libpq-dev",              "PostgreSQL",       "Client api for communicating with PostgreSQL", false },
            { "libpulse",            "libpulse-dev",           "Pulse",            "Client library for PulseAudio",        false },
            { "purple",              "libpurple-dev",          "Purple",           "IM library from Pidgin",               false },
            { "librabbitmq",         "librabbitmq-dev",        "RabbitMQ",         "AMQP Client for AMQP Servers",         false },
            { "libserialport",       "libserialport-dev",      "Serial Port",      "Library to interact with serial ports", false },
            { "sdl2",                "libsdl2-dev",            "SDL2",             "Cross-platform media and graphis library", false },
            { "sdl2-gfx",            "libsdl2-dev",            "SDL2 Gfx",         "SDL2 Extension for basic graphic functions", false },
            { "sdl2-image",          "libsdl2-dev",            "SDL2 Image",       "SDL2 Extension for basic image loading", false },
            { "sdl2-net",            "libsdl2-dev",            "SDL2 Net",         "SDL2 Extension for basic networking",  false },
            { "sdl2-ttf",            "libsdl2-dev",            "SDL2 TTF",         "SDL2 Extension for using TrueType fonts", false },
            { "sdl2-mixer",          "libsdl2-dev",            "SDL2 Mixer",       "SDL2 Extension for multi-channel audio", false },
            { "libsoup-2.4",         "libsoup2.4-dev",         "Soup",             "HTTP(s) Requests",                     false },
            { "sqlite3",             "libsqlite-3-dev",        "SQLite",           "Local database storage",               false },
            { "switchboard-2.0",     "libswitchboard-2.0-dev", "Switchboard",      "Write plugins for elementary Switchboard", false },
            { "telepathy-glib",      "libtelepathy-glib-dev",  "Telepathy",        "D-Bus framwork for unifying real time communication", false },
            { "unity",               "libunity-dev",           "Unity",            "Ubuntu Unity integration library",     false },
            { "libusb",              "libusb-dev",             "USB",              "Library to interact with USB ports",   false },
            { "vte-2.91",            "libvte-2.91-dev",        "VTE",              "Terminal emulator widget for GTK",     false },
            { "webkit2gtk-4.0",      "libwebkit2gtk-4.0-dev",  "Webkit",           "Web content rendering with Webkit",    false },
            { "libxml-2.0",          "libxml2-dev",            "XML",              "XML Encoding/Decoding",                false },
            { "zeitgeist-2.0",       "libzeitgeist-2.0-dev",   "Zeitgeist",        "Logging and events service",           false },
            
        };
    }
}
