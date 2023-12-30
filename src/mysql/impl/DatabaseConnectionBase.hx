package mysql.impl;

import promises.Promise;

class DatabaseConnectionBase {
    public var connectionDetails:ConnectionDetails = null;

    public var autoReconnect:Bool = false;
    public var autoReconnectIntervalMS:Int = 1000;
    public var replayQueriesOnReconnection:Bool = false;

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

    public function query(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            reject(new MySqlError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::query" not implemented'));
        });
    }

    public function all(sql:String, ?param:Dynamic):Promise<MySqlResult<Array<Dynamic>>> {
        return new Promise((resolve, reject) -> {
            reject(new MySqlError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::all" not implemented'));
        });
    }

    public function close() {        
    }

    private function checkForDisconnection(error:String, call:CacheCall, sql:String, param:Dynamic, resolve:Dynamic->Void, reject:Dynamic->Void) {
        if (!autoReconnect) {
            return false;
        }
        var isDisconnectedError = false;
        if (error.toLowerCase() == "can't add new command when connection is in closed state") {
            isDisconnectedError = true;
        } else if (error.toLowerCase().indexOf("failed to send packet") != -1)  {
            isDisconnectedError = true;
        }
        if (isDisconnectedError) {
            cacheCall({
                call: call,
                sql: sql,
                param: param,
                resolve: resolve,
                reject: reject
            });
            haxe.Timer.delay(attemptReconnect, autoReconnectIntervalMS);
            return true;
        }
        return false;
    }

    private var _cachedCalls:Array<CacheItem> = [];
    private function cacheCall(item:CacheItem) {
        if (!replayQueriesOnReconnection) {
            return;
        }
        _cachedCalls.push(item);
    }

    private function attemptReconnect() {
        open().then(_ -> {
            replayCachedCalls(_cachedCalls);
        }, error -> {
            haxe.Timer.delay(attemptReconnect, autoReconnectIntervalMS);
        });
    }

    private function replayCachedCalls(cachedCalls:Array<CacheItem>) {
        if (cachedCalls.length == 0) {
            return;
        }

        var item = cachedCalls.shift();
        switch (item.call) {
            case CALL_GET:
                get(item.sql, item.param).then(result -> {
                    item.resolve(result);
                    replayCachedCalls(cachedCalls);
                }, error -> {
                    item.reject(error);
                    replayCachedCalls(cachedCalls);
                });
            case CALL_QUERY:
                query(item.sql, item.param).then(result -> {
                    item.resolve(result);
                    replayCachedCalls(cachedCalls);
                }, error -> {
                    item.reject(error);
                    replayCachedCalls(cachedCalls);
                });
            case CALL_ALL:
                all(item.sql, item.param).then(result -> {
                    item.resolve(result);
                    replayCachedCalls(cachedCalls);
                }, error -> {
                    item.reject(error);
                    replayCachedCalls(cachedCalls);
                });
            case CALL_EXEC:            
                exec(item.sql).then(result -> {
                    item.resolve(result);
                    replayCachedCalls(cachedCalls);
                }, error -> {
                    item.reject(error);
                    replayCachedCalls(cachedCalls);
                });
        }
    }
}

private enum CacheCall {
    CALL_EXEC;
    CALL_GET;
    CALL_QUERY;
    CALL_ALL;
}

private typedef CacheItem = {
    var call:CacheCall;
    var sql:String;
    var param:Dynamic;
    var resolve:Dynamic->Void;
    var reject:Dynamic->Void;
}