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
    public signal void snapshot_added (Objects.Snapshot snapshot);

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
                platform        TEXT,
                date_added      TEXT,
                last_played     TEXT,
                is_favorite     INTEGER,
                developer       TEXT,
                genre           TEXT,
                CONSTRAINT unique_game UNIQUE (uri)
            );
        """;

        rc = db.exec (sql, null, null);
        debug ("Table Games created");

        sql = """
            CREATE TABLE IF NOT EXISTS Snapshots (
                id             INTEGER PRIMARY KEY AUTOINCREMENT,
                game_id        INTEGER,
                is_automatic   INTEGER,
                date_added     TEXT,
                FOREIGN KEY (game_id) REFERENCES Games (id) ON DELETE CASCADE
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

    public int insert_snapshot (Objects.Snapshot snapshot) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            INSERT OR IGNORE INTO Snapshots (game_id, date_added, is_automatic)
            VALUES (?, ?, ?);
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (1, snapshot.game_id);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (2, snapshot.date_added);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (3, snapshot.is_automatic);
        assert (res == Sqlite.OK);

        if (stmt.step () != Sqlite.DONE) {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }

        stmt.reset ();

        sql = """
            SELECT id FROM Snapshots WHERE date_added = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, snapshot.date_added);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            snapshot.id = stmt.column_int (0);
            snapshot_added (snapshot);
        } else {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }

        return snapshot.id;
    }

    public Objects.Snapshot? get_last_snapshot (int game_id) {
        Objects.Snapshot? returned = null;
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT * FROM Snapshots WHERE game_id = ? ORDER BY date_added DESC LIMIT 1;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (1, game_id);
        assert (res == Sqlite.OK);

        while (stmt.step () == Sqlite.ROW) {
            returned = new Objects.Snapshot ();
            returned.id = stmt.column_int (0);
            returned.game_id = stmt.column_int (1);
            returned.is_automatic = stmt.column_int (2);
            returned.date_added = stmt.column_text (3);
        }

        stmt.reset ();
        return returned;
    }

    public Gee.ArrayList<Objects.Snapshot?> get_snapshots_by_game (int game_id) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT * FROM Snapshots WHERE game_id = ? ORDER BY date_added DESC LIMIT 5;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (1, game_id);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Snapshot?> ();

        while ((res = stmt.step ()) == Sqlite.ROW) {
            var returned = new Objects.Snapshot ();
            returned.id = stmt.column_int (0);
            returned.game_id = stmt.column_int (1);
            returned.is_automatic = stmt.column_int (2);
            returned.date_added = stmt.column_text (3);

            all.add (returned);
        }

        return all;
    }
}