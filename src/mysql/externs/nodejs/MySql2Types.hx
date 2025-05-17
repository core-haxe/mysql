package mysql.externs.nodejs;

enum abstract MySql2Types(Int) {
  var DECIMAL = 0x00; // aka DECIMAL
  var TINY = 0x01; // aka TINYINT; 1 byte
  var SHORT = 0x02; // aka SMALLINT; 2 bytes
  var LONG = 0x03; // aka INT; 4 bytes
  var FLOAT = 0x04; // aka FLOAT; 4-8 bytes
  var DOUBLE = 0x05; // aka DOUBLE; 8 bytes
  var NULL = 0x06; // NULL (used for prepared statements; I think)
  var TIMESTAMP = 0x07; // aka TIMESTAMP
  var LONGLONG = 0x08; // aka BIGINT; 8 bytes
  var INT24 = 0x09; // aka MEDIUMINT; 3 bytes
  var DATE = 0x0a; // aka DATE
  var TIME = 0x0b; // aka TIME
  var DATETIME = 0x0c; // aka DATETIME
  var YEAR = 0x0d; // aka YEAR; 1 byte (dont ask)
  var NEWDATE = 0x0e; // aka ?
  var VARCHAR = 0x0f; // aka VARCHAR (?)
  var BIT = 0x10; // aka BIT; 1-8 byte
  var JSON = 0xf5;
  var NEWDECIMAL = 0xf6; // aka DECIMAL
  var ENUM = 0xf7; // aka ENUM
  var SET = 0xf8; // aka SET
  var TINY_BLOB = 0xf9; // aka TINYBLOB; TINYTEXT
  var MEDIUM_BLOB = 0xfa; // aka MEDIUMBLOB; MEDIUMTEXT
  var LONG_BLOB = 0xfb; // aka LONGBLOG; LONGTEXT
  var BLOB = 0xfc; // aka BLOB; TEXT
  var VAR_STRING = 0xfd; // aka VARCHAR; VARBINARY
  var STRING = 0xfe; // aka CHAR; BINARY
  var GEOMETRY = 0xff; // aka GEOMETRY    
}
