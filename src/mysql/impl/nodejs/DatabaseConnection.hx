package mysql.impl.nodejs;

import promises.Promise;
import mysql.externs.nodejs.MySql2;
import mysql.externs.nodejs.MySql2Types;
import js.node.Buffer;
import mysql.externs.nodejs.Connection as NativeConnection;
import logging.Logger;

class DatabaseConnection extends DatabaseConnectionBase {
    private static var log = new Logger(DatabaseConnection, true);

    private var _nativeConnection:NativeConnection = null;

    public override function open():Promise<MySqlResult<Bool>> {
        return new Promise((resolve, reject) -> {
            var port = 3306;
            if (this.connectionDetails.port != null) {
                port = this.connectionDetails.port;
            }
    
            log.debug("creating connection:", {
                host: this.connectionDetails.host,
                user: this.connectionDetails.user,
                password: this.connectionDetails.pass,
                database: this.connectionDetails.database,
                rowsAsArray: false
            });
            _nativeConnection = MySql2.createConnection({
                host: this.connectionDetails.host,
                user: this.connectionDetails.user,
                password: this.connectionDetails.pass,
                database: this.connectionDetails.database,
                port: port,
                rowsAsArray: false
            });

            _nativeConnection.connect(error -> {
                if (error != null) {
                    reject(new MySqlError("Error", error.message));
                    return;
                }

                resolve(new MySqlResult(this, true));
            });
        });
    }
    
    public override function exec(sql:String):Promise<MySqlResult<Bool>> {
        return new Promise((resolve, reject) -> {
            log.data("exec:", sql);
            _nativeConnection.execute(sql, (error, rows, fields) -> {
                if (error != null) {
                    if (!checkForDisconnection(error.message, CALL_EXEC, sql, null, resolve, reject)) {
                        reject(new MySqlError("Error", error.message));
                    }
                    return;
                }

                var result:Dynamic = null;
                if (rows is Array) {
                    result = rows[0];
                } else {
                    result = rows;
                }
                var mysqlResult = new MySqlResult(this, true);
                if (result != null) {
                    mysqlResult.affectedRows = result.affectedRows;
                    mysqlResult.lastInsertId = result.insertId;
                }
                resolve(mysqlResult);
            });
        });
    }

    public override function get(sql:String, ?param:Dynamic):Promise<MySqlResult<Dynamic>> {
        return new Promise((resolve, reject) -> {
            log.data("get:", [sql, param]);
            _nativeConnection.execute(sql, params(param), (error, rows, fields) -> {
                if (error != null) {
                    if (!checkForDisconnection(error.message, CALL_GET, sql, param, resolve, reject)) {
                        reject(new MySqlError("Error", error.message));
                    }
                    return;
                }
                /*
                if (rows == null || rows.length == 0) {
                    resolve(new MySqlResult(this, null));
                }
                */
                var result:Dynamic = null;
                if (rows is Array) {
                    result = rows[0];
                } else {
                    result = rows;
                }
                convertToHaxeTypes(rows, fieldsToMap(fields));
                var mysqlResult = new MySqlResult(this, result);
                if (result != null) {
                    mysqlResult.affectedRows = result.affectedRows;
                    mysqlResult.lastInsertId = result.insertId;
                }
                resolve(mysqlResult);
            });
        });
    }

    public override function query(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            log.data("query:", [sql, param]);
            _nativeConnection.query(sql, params(param), (error, rows, fields) -> {
                if (error != null) {
                    if (!checkForDisconnection(error.message, CALL_QUERY, sql, param, resolve, reject)) {
                        reject(new MySqlError("Error", error.message));
                    }
                    return;
                }

                convertToHaxeTypes(rows, fieldsToMap(fields));
                resolve(new MySqlResult(this, rows));
            });
        });
    }

    public override function all(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            log.data("all:", [sql, param]);
            _nativeConnection.execute(sql, params(param), (error, rows, fields) -> {
                if (error != null) {
                    if (!checkForDisconnection(error.message, CALL_ALL, sql, param, resolve, reject)) {
                        reject(new MySqlError("Error", error.message));
                    }
                    return;
                }

                if (rows == null) {
                    resolve(new MySqlResult(this, []));
                }

                convertToHaxeTypes(rows, fieldsToMap(fields));
                resolve(new MySqlResult(this, rows));
            });
        });
    }

    public override function close() {
        _nativeConnection.end();
    }

    private function params(param:Dynamic):Array<Dynamic> {
        return switch(Type.typeof(param)) {
            case TClass(Array):
                param;
            case TNull:
                null;
            case _:
                [param];
        }
    }

    private function fieldsToMap(fields:Array<Dynamic>):Map<String, Dynamic> {
        var map:Map<String, Dynamic> = [];
        if (fields == null) {
            return map;
        }
        for (f in fields) {
            map.set(f.name, f);
        }
        return map;
    }

    private function convertToHaxeTypes(data:Dynamic, fieldInfo:Map<String, Dynamic>) {
        if ((data is Array)) {
            var array:Array<Dynamic> = data;
            for (item in array) {
                convertToHaxeTypes(item, fieldInfo);
            }
        } else {
            for (f in Reflect.fields(data)) {
                var v = Reflect.field(data, f);
                if ((v is Buffer)) {
                    var buffer:Buffer = cast v;
                    var bytes = buffer.hxToBytes();
                    Reflect.setField(data, f, bytes);
                } else if (fieldInfo.exists(f)) {
                    var info = fieldInfo.get(f);
                    switch (info.type) {
                        case TINY | SHORT | LONG | INT24:
                            Reflect.setField(data, f, Std.parseInt(v));
                        case DECIMAL | DOUBLE | FLOAT | NEWDECIMAL:
                            Reflect.setField(data, f, Std.parseFloat(v));
                        case _:    
                    }
                }
            }
        }
    }
}