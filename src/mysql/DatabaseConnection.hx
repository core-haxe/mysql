package mysql;

#if nodejs

typedef DatabaseConnection = mysql.impl.nodejs.DatabaseConnection;

#elseif sys

typedef DatabaseConnection = mysql.impl.sys.DatabaseConnection;

#else

typedef DatabaseConnection = mysql.impl.fallback.DatabaseConnection;

#end