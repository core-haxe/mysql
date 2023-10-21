package mysql.externs.nodejs;

import js.lib.Error;

@:jsRequire("mysql2", "Connection")
extern class Connection {
    public function execute(sql:String, ?params:Dynamic, ?cb:MySql2Error->Array<Dynamic>->Dynamic->Void):Void;
    public function query(sql:String, ?params:Dynamic, ?cb:MySql2Error->Array<Dynamic>->Dynamic->Void):Void;
    public function connect(?cb:MySql2Error->Void):Void;
    public function end(?cb:MySql2Error->Void):Void;
}