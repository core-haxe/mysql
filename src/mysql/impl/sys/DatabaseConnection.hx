package mysql.impl.sys;

import promises.Promise;
import sys.db.Mysql;
import sys.db.Connection as NativeConnection;

using StringTools;

class DatabaseConnection extends DatabaseConnectionBase {
    private var _nativeConnection:NativeConnection = null;

    public override function open():Promise<MySqlResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                _nativeConnection = Mysql.connect({
                    host: this.connectionDetails.host,
                    port: this.connectionDetails.port,
                    user: this.connectionDetails.user,
                    pass: this.connectionDetails.pass,
                    database: this.connectionDetails.database
                });

                resolve(new MySqlResult(this, true));
            } catch (e:Dynamic) {
                reject(new MySqlError("Error", e));
            }
        });
    }

    public override function exec(sql:String):Promise<MySqlResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                sql = prepareSQL(sql);
                _nativeConnection.request(sql);
                resolve(new MySqlResult(this, true));
            } catch (e:Dynamic) {
                reject(new MySqlError("Error", e));
            }
        });
    }

    public override function get(sql:String, ?param:Dynamic):Promise<MySqlResult<Dynamic>> {
        return new Promise((resolve, reject) -> {
            try {
                sql = prepareSQL(sql, param);
                var rs = _nativeConnection.request(sql);
                if (rs.nfields == 0 || rs.length == 0) {
                    resolve(new MySqlResult(this, null));
                    return;
                }
                resolve(new MySqlResult(this, rs.next()));
            } catch (e:Dynamic) {
                reject(new MySqlError("Error", e));
            }
        });
    }

    public override function all(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            try {
                sql = prepareSQL(sql, param);
                var rs = _nativeConnection.request(sql);
                var records:Array<Dynamic> = [];
                while (rs.hasNext()) {
                    records.push(rs.next());
                }
                resolve(new MySqlResult(this, records));
            } catch (e:Dynamic) {
                reject(new MySqlError("Error", e));
            }
        });
    }

    private function prepareSQL(sql:String, param:Dynamic = null):String {
        var params = [];
        if (param != null) {
            params = switch (Type.typeof(param)) {
                case TClass(Array):
                    param;
                case _:
                    [param];
            }
        }

        var r = ~/\?/gm;
        sql = r.map(sql, f -> {
            var p = params.shift();
            var v:Any = switch (Type.typeof(p)) {
                case TClass(String):
                    "\"" + p + "\"";
                case TBool:
                    p == true ? 1 : 0;
                case TFloat:
                    p;
                case TInt:
                    p;
                case TNull:
                    p;
                case _:
                    trace("UKNONWN:", Type.typeof(p));
                    p;
            }
            return v;
        });
        sql = sql.trim();
        if (!sql.endsWith(";")) {
            sql += ";";
        }
        return sql;
    }
}