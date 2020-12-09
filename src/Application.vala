/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
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
* Authored by: Alain M. <alainmh23@gmail.com>
*/

public class RetroByte : Gtk.Application {
    public MainWindow? main_window = null;

    public static Utils utils;
    public static GLib.Settings settings;
    public static Services.Database database;
    public static Services.RetroCoreManager core_manager;

    public RetroByte () {
        Object (
            application_id: "com.github.alainm23.retro-byte",
            flags: ApplicationFlags.FLAGS_NONE
        );

        // Dir to Database
        utils = new Utils ();
        utils.create_dir_with_parents ("/com.github.alainm23.retro-byte");
        utils.create_dir_with_parents ("/com.github.alainm23.retro-byte/snapshots");
        utils.create_dir_with_parents ("/com.github.alainm23.retro-byte/cores");
        
        // Services
        settings = new Settings ("com.github.alainm23.retro-byte");
        database = new Services.Database ();
        core_manager = new Services.RetroCoreManager ();
    }

    public static RetroByte _instance = null;
    public static RetroByte instance {
        get {
            if (_instance == null) {
                _instance = new RetroByte ();
            }
            return _instance;
        }
    }

    protected override void activate () {
        if (get_windows ().length () > 0) {
            get_windows ().data.present ();
            get_windows ().data.show_all ();

            return;
        }

        main_window = new MainWindow (this);

        int window_x, window_y;
        var rect = Gtk.Allocation ();

        settings.get ("window-position", "(ii)", out window_x, out window_y);
        settings.get ("window-size", "(ii)", out rect.width, out rect.height);

        if (window_x != -1 || window_y != -1) {
            main_window.move (window_x, window_y);
        }

        main_window.set_allocation (rect);

        if (settings.get_boolean ("window-maximized")) {
            main_window.maximize ();
        }

        main_window.show_all ();
        main_window.present ();

        // Set Dark Theme
        Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

        // Stylesheet
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/alainm23/retro-byte/stylesheet.css");
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
        
        // Default Icon Theme
        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
        default_theme.add_resource_path ("/com/github/alainm23/retro-byte");

        // Search Cores
        core_manager.search_modules ();
    }

    public static int main (string[] args) {
        RetroByte app = RetroByte.instance;
        return app.run (args);
    }
}
