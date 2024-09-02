package mysql.impl.cpp;

import promises.Promise;
import mysql.MySqlClientConnection as NativeConnection;

using StringTools;

class DatabaseConnection extends DatabaseConnectionBase {
    private var _nativeConnection:NativeConnection = null;

    public override function open():Promise<MySqlResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                if (_nativeConnection != null) {
                    _nativeConnection.close();
                }
                _nativeConnection = MySqlClient.open(
                    this.connectionDetails.host,
                    this.connectionDetails.user,
                    this.connectionDetails.pass,
                    this.connectionDetails.database,
                    this.connectionDetails.port
                );

                resolve(new MySqlResult(this, true));
            } catch (e:Dynamic) {
                reject(new MySqlError("Error", e));
            }
       });
    }

    public override function close() {
        _nativeConnection.close();
        _nativeConnection = null;
    }

    public override function exec(sql:String):Promise<MySqlResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                sql = prepareSQL(sql);
                var rs = _nativeConnection.query(sql);
                var result = new MySqlResult(this, true);
                if (rs != null) {
                    result.lastInsertId = _nativeConnection.lastInsertRowId();
                    result.affectedRows = _nativeConnection.affectedRows();
                }
                resolve(result);
            } catch (e:MySqlClientError) {
                if (!checkForDisconnection(e.errorMessage, CALL_EXEC, sql, null, resolve, reject)) {
                    reject(new MySqlError("Error", e.errorMessage));
                }
            }
        });
    }

    public override function get(sql:String, ?param:Dynamic):Promise<MySqlResult<Dynamic>> {
        return new Promise((resolve, reject) -> {
            try {
                sql = prepareSQL(sql, param);
                var rs = _nativeConnection.query(sql);
                if (rs.length == 0) {
                    var record:Dynamic = null;
                    var lastInsertedId = _nativeConnection.lastInsertRowId();
                    if (sql.indexOf("INSERT ") != -1) {
                        record = {};
                        record.insertId = lastInsertedId;
                    }
    
                    var result = new MySqlResult(this, record);
                    result.lastInsertId = lastInsertedId;
                    result.affectedRows = _nativeConnection.affectedRows();
                    resolve(result);
                    return;
                }

                var first:Dynamic = null;
                for (record in rs) {
                    if (first == null) {
                        first = record;
                        break;
                    }
                }

                var lastInsertedId = _nativeConnection.lastInsertRowId();
                if (sql.indexOf("INSERT ") != -1) {
                    first.insertId = lastInsertedId;
                }
                var result = new MySqlResult(this, first);
                result.lastInsertId = lastInsertedId;
                result.affectedRows = _nativeConnection.affectedRows();
                resolve(result);
            } catch (e:MySqlClientError) {
                if (!checkForDisconnection(e.errorMessage, CALL_GET, sql, param, resolve, reject)) {
                    reject(new MySqlError("Error", e.errorMessage));
                }
            }
        });
    }

    public override function all(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            try {
                sql = prepareSQL(sql, param);
                var rs = _nativeConnection.query(sql);
                var records:Array<Dynamic> = [];
                for (record in rs) {
                    records.push(record);
                }
                resolve(new MySqlResult(this, records));
            } catch (e:MySqlClientError) {
                if (!checkForDisconnection(e.errorMessage, CALL_ALL, sql, param, resolve, reject)) {
                    reject(new MySqlError("Error", e.errorMessage));
                }
            }
        });
    }

    public override function query(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            try {
                sql = prepareSQL(sql, param);
                var rs = _nativeConnection.query(sql);
                var records:Array<Dynamic> = [];
                for (record in rs) {
                    records.push(record);
                }
                resolve(new MySqlResult(this, records));
            } catch (e:MySqlClientError) {
                if (!checkForDisconnection(e.errorMessage, CALL_QUERY, sql, param, resolve, reject)) {
                    reject(new MySqlError("Error", e.errorMessage));
                }
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

        var org = params.copy();
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
            return Std.string(v);
        });
        sql = sql.trim();
        if (!sql.endsWith(";")) {
            sql += ";";
        }
        return sql;
    }
}