package mysql.externs.nodejs;

import js.lib.Error;

extern class MySql2Error extends Error {
    public var code:String;
    public var errno:Int;
    public var sqlState:String;
    public var sqlMessage:String;
}