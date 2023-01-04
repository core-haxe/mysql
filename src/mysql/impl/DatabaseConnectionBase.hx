package mysql.impl;

import promises.Promise;

class DatabaseConnectionBase {
    public var connectionDetails:ConnectionDetails = null;
    public function new(details:ConnectionDetails) {
        connectionDetails = details;
        if (connectionDetails.port == null) {
            connectionDetails.port = 3306;
        }
    }

    public function open():Promise<MySqlResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new MySqlError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::open" not implemented'));
        });
    }

    public function exec(sql:String):Promise<MySqlResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new MySqlError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::exec" not implemented'));
        });
    }

    public function get(sql:String, ?param:Dynamic):Promise<MySqlResult<Dynamic>> {
        return new Promise((resolve, reject) -> {
            reject(new MySqlError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::get" not implemented'));
        });
    }

    public function all(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            reject(new MySqlError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::all" not implemented'));
        });
    }

    public function close() {        
    }
}