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

public class Widgets.HeaderBar : Hdy.HeaderBar {
    private Gtk.Stack first_stack;
    public Gtk.SearchEntry search_entry;

    public signal void back ();
    public signal void toggle_playing (string icon_name);
    public signal void search_changed (string text);
    public signal void save_button_clicked ();

    public string visible_child_name {
        set {
            first_stack.visible_child_name = value;
        }
    }

    construct {
        show_close_button = true;

        var back_icon = new Gtk.Image ();
        back_icon.gicon = new ThemedIcon ("go-previous-symbolic");
        back_icon.pixel_size = 14;

        var back_button = new Gtk.Button ();
        back_button.can_focus = false;
        back_button.valign = Gtk.Align.CENTER;
        back_button.tooltip_text = _ ("Library");
        back_button.get_style_context ().add_class ("headerbar-button");
        back_button.add (back_icon);

        var icon_play_puse = new Gtk.Image ();
        icon_play_puse.gicon = new ThemedIcon ("media-playback-pause-symbolic");
        icon_play_puse.pixel_size = 14;

        var play_button = new Gtk.Button ();
        play_button.margin_start = 12;
        play_button.can_focus = false;
        play_button.valign = Gtk.Align.CENTER;
        play_button.tooltip_text = _ ("Pause");
        play_button.get_style_context ().add_class ("headerbar-button");
        play_button.add (icon_play_puse);

        play_button.clicked.connect (() => {
            if (icon_play_puse.icon_name == "media-playback-start-symbolic") {
                icon_play_puse.icon_name = "media-playback-pause-symbolic";
                play_button.tooltip_text = _ ("Pause");
            } else {
                icon_play_puse.icon_name = "media-playback-start-symbolic";
                play_button.tooltip_text = _ ("Play");
            }

            toggle_playing (icon_play_puse.icon_name);
        });

        var save_icon = new Gtk.Image ();
        save_icon.gicon = new ThemedIcon ("document-save-symbolic");
        save_icon.pixel_size = 14;

        var save_button = new Gtk.Button ();
        save_button.margin_start = 12;
        save_button.can_focus = false;
        save_button.valign = Gtk.Align.CENTER;
        save_button.tooltip_text = _ ("Play");
        save_button.get_style_context ().add_class ("headerbar-button");
        save_button.add (save_icon);

        var open_last_scene_icon = new Gtk.Image ();
        open_last_scene_icon.gicon = new ThemedIcon ("document-open-recent-symbolic");
        open_last_scene_icon.pixel_size = 14;

        var open_last_scene_button = new Gtk.Button ();
        open_last_scene_button.can_focus = false;
        open_last_scene_button.valign = Gtk.Align.CENTER;
        open_last_scene_button.tooltip_text = _ ("Play");
        open_last_scene_button.get_style_context ().add_class ("headerbar-button");
        open_last_scene_button.add (open_last_scene_icon);

        var open_scenes_icon = new Gtk.Image ();
        open_scenes_icon.gicon = new ThemedIcon ("pan-down-symbolic");
        open_scenes_icon.pixel_size = 14;

        var open_scenes_button = new Gtk.Button ();
        open_scenes_button.can_focus = false;
        open_scenes_button.valign = Gtk.Align.CENTER;
        open_scenes_button.tooltip_text = _ ("Play");
        open_scenes_button.get_style_context ().add_class ("headerbar-button");
        open_scenes_button.get_style_context ().add_class ("no-padding-left-right");
        open_scenes_button.add (open_scenes_icon);

        var open_box = new Gtk.Grid ();
        open_box.margin_start = 12;
        open_box.valign = Gtk.Align.CENTER;
        open_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        open_box.add (open_last_scene_button);
        open_box.add (open_scenes_button);

        var fullscreen_button = new Gtk.Button ();
        fullscreen_button.can_focus = false;
        fullscreen_button.valign = Gtk.Align.CENTER;
        fullscreen_button.tooltip_text = _ ("Play");
        fullscreen_button.get_style_context ().add_class ("headerbar-button");
        fullscreen_button.add (new Gtk.Image.from_icon_name ("view-fullscreen-symbolic", Gtk.IconSize.MENU));

        var extern_button = new Gtk.Button ();
        extern_button.can_focus = false;
        extern_button.valign = Gtk.Align.CENTER;
        extern_button.tooltip_text = _ ("Play");
        extern_button.get_style_context ().add_class ("headerbar-button");
        extern_button.add (new Gtk.Image.from_icon_name ("window-new-symbolic", Gtk.IconSize.MENU));

        var extern_box = new Gtk.Grid ();
        extern_box.margin_start = 12;
        extern_box.valign = Gtk.Align.CENTER;
        extern_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        extern_box.add (fullscreen_button);
        extern_box.add (extern_button);

        var controller_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        controller_box.hexpand = true;
        controller_box.pack_start (back_button, false, false, 0);
        controller_box.pack_start (play_button, false, false, 0);
        controller_box.pack_start (save_button, false, false, 0);
        controller_box.pack_start (open_box, false, false, 0);

        search_entry = new Gtk.SearchEntry ();
        search_entry.valign = Gtk.Align.CENTER;
        
        pack_start (controller_box);

        back_button.clicked.connect (() => {
            back ();
        });

        search_entry.search_changed.connect (() => {
            search_changed (search_entry.text);
        });

        save_button.clicked.connect (() => {

        });
    }

    //  private Gtk.Widget get_home_header () {
    //      var app_menu = new Gtk.MenuButton ();
    //      app_menu.valign = Gtk.Align.CENTER;
    //      app_menu.valign = Gtk.Align.CENTER;
    //      app_menu.tooltip_text = _("Menu");

    //      var menu_icon = new Gtk.Image ();
    //      menu_icon.gicon = new ThemedIcon ("open-menu-symbolic");
    //      menu_icon.pixel_size = 16;

    //      app_menu.image = menu_icon;

    //      var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    //      box.hexpand = true;
    //      box.pack_start (view_mode, false, false, 0);
    //      box.pack_end (search_entry, false, false, 0);

    //      return box;
    //  }

    //  public void visible_child_name (string child_name) {
    //      main_stack.visible_child_name = child_name;
    //  }
}
