import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;
import ballerina/http;
import ballerina/log;

configurable int port = ?;

configurable string database = ?;

configurable string password = ?;

configurable string user = ?;

configurable string host = ?;

type isValid record {
    boolean valid;
    string address?;
};

type Person record {
    string nic;
    string address;
};

final mysql:Client mysqlEp = check new (host = host, user = user, password = password, database = database, port = port);

service / on new http:Listener(9090) {

    isolated resource function get checkAddress/[string nic]/[string address]() returns isValid|error? {

        
        sql:ParameterizedQuery addressQuery = `SELECT * FROM address_details WHERE nic=${nic.trim()} AND address=${address.trim()}`;

        Person|error queryRowResponse = mysqlEp->queryRow(addressQuery);

        if queryRowResponse is error {
            isValid result = {
                valid: false
            };
            log:printInfo("Entered address is invalid");
            return result;
        } else {
            isValid result = {
                valid: true,
                address: queryRowResponse.address
            };
            return result;
        }

    }
}
