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

public class Services.Database : GLib.Object {
    private Sqlite.Database db;
    private string db_path;

    public signal void game_added (Objects.Game game);

    public Database () {
        int rc = 0;
        db_path = Environment.get_user_data_dir () + "/com.github.alainm23.retro-byte/database.db";

        if (create_tables () != Sqlite.OK) {
            stderr.printf ("Error creating db table: %d, %s\n", rc, db.errmsg ());
            Gtk.main_quit ();
        }

        rc = Sqlite.Database.open (db_path, out db);
        rc = db.exec ("PRAGMA foreign_keys = ON;");

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            Gtk.main_quit ();
        }
    }

    private int create_tables () {
        int rc;
        string sql;

        rc = Sqlite.Database.open (db_path, out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            Gtk.main_quit ();
        }

        sql = """
            CREATE TABLE IF NOT EXISTS Games (
                id              INTEGER PRIMARY KEY AUTOINCREMENT,
                name            TEXT,
                uri             TEXT,
                platform          TEXT,
                date_added      TEXT,
                last_played     TEXT,
                is_favorite     INTEGER,
                CONSTRAINT unique_game UNIQUE (uri)
            );
        """;

        rc = db.exec (sql, null, null);
        debug ("Table Games created");

        return rc;
    }

    public void insert_game (Objects.Game game) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            INSERT OR IGNORE INTO Games (name, uri, platform, date_added, last_played, is_favorite)
            VALUES (?, ?, ?, ?, ?, ?);
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, game.name);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (2, game.uri);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (3, game.platform);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (4, game.date_added);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (5, game.last_played);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (6, game.is_favorite);
        assert (res == Sqlite.OK);

        if (stmt.step () != Sqlite.DONE) {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }

        stmt.reset ();

        sql = """
            SELECT id FROM Games WHERE uri = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, game.uri);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            game.id = stmt.column_int (0);
            game_added (game);
        } else {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }
    }

    public Gee.ArrayList<Objects.Game?> get_games_by_platform (string platform) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT * FROM Games WHERE platform = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, platform);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Game?> ();

        while ((res = stmt.step ()) == Sqlite.ROW) {
            var g = new Objects.Game ();

            g.id = stmt.column_int (0);
            g.name = stmt.column_text (1);
            g.uri = stmt.column_text (2);
            g.platform = stmt.column_text (3);
            g.date_added = stmt.column_text (4);
            g.last_played = stmt.column_text (5);
            g.is_favorite = stmt.column_int (6);

            all.add (g);
        }

        return all;
    }
}