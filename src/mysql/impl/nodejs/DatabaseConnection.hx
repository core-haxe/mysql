package mysql.impl.nodejs;

import promises.Promise;
import mysql.externs.nodejs.MySql2;
import mysql.externs.nodejs.Connection as NativeConnection;

class DatabaseConnection extends DatabaseConnectionBase {
    private var _nativeConnection:NativeConnection = null;

    public override function open():Promise<MySqlResult<Bool>> {
        return new Promise((resolve, reject) -> {
            _nativeConnection = MySql2.createConnection({
                host: this.connectionDetails.host,
                user: this.connectionDetails.user,
                password: this.connectionDetails.pass,
                database: this.connectionDetails.database,
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
            _nativeConnection.execute(sql, (error, rows, fields) -> {
                if (error != null) {
                    reject(new MySqlError("Error", error.message));
                    return;
                }

                resolve(new MySqlResult(this, true));
            });
        });
    }

    public override function get(sql:String, ?param:Dynamic):Promise<MySqlResult<Dynamic>> {
        return new Promise((resolve, reject) -> {
            _nativeConnection.execute(sql, params(param), (error, rows, fields) -> {
                if (error != null) {
                    reject(new MySqlError("Error", error.message));
                    return;
                }

                if (rows == null || rows.length == 0) {
                    resolve(new MySqlResult(this, null));
                }

                resolve(new MySqlResult(this, rows[0]));
            });
        });
    }

    public override function query(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            _nativeConnection.query(sql, params(param), (error, rows, fields) -> {
                if (error != null) {
                    reject(new MySqlError("Error", error.message));
                    return;
                }

                resolve(new MySqlResult(this, rows));
            });
        });
    }

    public override function all(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            _nativeConnection.execute(sql, params(param), (error, rows, fields) -> {
                if (error != null) {
                    reject(new MySqlError("Error", error.message));
                    return;
                }

                if (rows == null) {
                    resolve(new MySqlResult(this, []));
                }

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
}