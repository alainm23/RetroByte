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

public class MainWindow : Hdy.ApplicationWindow {
    private Views.CoreView? core_view = null;
    private Gtk.Stack main_stack;
    private Views.Platform platform_view;
    private uint configure_id = 0;

    const Gtk.TargetEntry[] targets = {
        {"text/uri-list", 0, 0}
    };

    public MainWindow (RetroByte application) {
        Object (
            application: application,
            icon_name: "com.github.alainm23.retro-byte",
            title: _("RetroByte")
        );
    }

    static construct {
        Hdy.init ();
    }

    construct {
        var sidebar_header = new Hdy.HeaderBar ();
        sidebar_header.decoration_layout = "close:";
        sidebar_header.has_subtitle = false;
        sidebar_header.show_close_button = true;
        sidebar_header.get_style_context ().add_class ("sidebar-header");
        sidebar_header.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var pane = new Widgets.Pane ();

        var sidebar = new Gtk.Grid ();
        sidebar.attach (sidebar_header, 0, 0);
        sidebar.attach (pane, 0, 1);

        var view_header = new Hdy.HeaderBar ();
        view_header.has_subtitle = false;
        view_header.decoration_layout = ":maximize";
        view_header.show_close_button = true;

        var modeview_button = new Granite.Widgets.ModeButton ();
        modeview_button.valign = Gtk.Align.CENTER;
        modeview_button.append_icon ("view-grid-symbolic", Gtk.IconSize.MENU);
        modeview_button.append_icon ("view-list-symbolic", Gtk.IconSize.MENU);

        var search_entry = new Gtk.SearchEntry ();
        search_entry.valign = Gtk.Align.CENTER;

        view_header.pack_start (modeview_button);
        view_header.pack_end (search_entry);

        var library_stack = new Gtk.Stack ();
        library_stack.transition_type = Gtk.StackTransitionType.NONE;
        library_stack.expand = true;

        var view_grid = new Gtk.Grid ();
        view_grid.attach (view_header, 0, 0);
        view_grid.attach (library_stack, 0, 1);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (sidebar, false, false);
        paned.pack2 (view_grid, true, false);

        main_stack = new Gtk.Stack ();
        main_stack.expand = true;
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        main_stack.add_named (paned, "library");

        add (main_stack);

        RetroByte.settings.bind ("pane-position", paned, "position", GLib.SettingsBindFlags.DEFAULT);

        Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.LINK);
        drag_data_received.connect (on_drag_data_received);
        drag_motion.connect (on_drag_motion);
        drag_leave.connect (on_drag_leave);

        pane.row_selected.connect ((platform) => {
            if (platform_view == null) {
                platform_view = new Views.Platform ();
                platform_view.platform = platform;

                platform_view.game_selected.connect ((game) => {
                    if (core_view == null) {
                        core_view = new Views.CoreView (game);
                        main_stack.add_named (core_view, "core_view");
                        main_stack.visible_child_name = "core_view";

                        core_view.back.connect (() => {
                            if (core_view != null) {
                                main_stack.visible_child_name = "library";
                                GLib.Timeout.add (main_stack.transition_duration, () => {
                                    core_view.stop ();
                                    core_view.destroy ();
                                    core_view = null;
                                    return GLib.Source.REMOVE;
                                });
                            }
                        });
                    }
                });

                library_stack.add_named (platform_view, "platform_view");
            } else {
                platform_view.platform = platform;
            }

            library_stack.visible_child_name = "platform_view";
        });
    }

    private void on_drag_data_received (Gdk.DragContext context, int x, int y,
        Gtk.SelectionData data, uint target_type) {
        foreach (var uri in data.get_uris ()) {
            var file = File.new_for_uri (uri);
            try {
                var file_info = file.query_info ("standard::*", GLib.FileQueryInfoFlags.NONE);
                var system_type = RetroByte.utils.get_system_type (file_info.get_content_type ());
                
                if (system_type != null) {
                    var game = new Objects.Game ();
                    game.name = file_info.get_name ();
                    game.uri = uri;
                    game.platform = system_type;

                    RetroByte.database.insert_game (game);
                }
            } catch (Error err) {
                warning (err.message);
            }

            file.dispose ();
        }
    }

    public void on_drag_leave (Gdk.DragContext context, uint time) {
        get_style_context ().remove_class ("highlight");
    }

    public bool on_drag_motion (Gdk.DragContext context, int x, int y, uint time) {
        get_style_context ().add_class ("highlight");
        return true;
    }
    
    public override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;

            if (is_maximized) {
                RetroByte.settings.set_boolean ("window-maximized", true);
            } else {
                RetroByte.settings.set_boolean ("window-maximized", false);

                Gdk.Rectangle rect;
                get_allocation (out rect);
                RetroByte.settings.set ("window-size", "(ii)", rect.width, rect.height);

                int root_x, root_y;
                get_position (out root_x, out root_y);
                RetroByte.settings.set ("window-position", "(ii)", root_x, root_y);
            }

            return false;
        });

        return base.configure_event (event);
    }
}
