import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "us-west-2" });

export const handler = async (event, context) => {
    
    console.log("chamou");
    //console.log(event);

    // if(event.rawPath.includes('auth')){
    //     return generatePolicy('user', 'Allow', event.routeArn)
    // }

    const exists = await getDynamoToken(event.headers.authorization);


    if (exists) {
        console.log("achou")
        return generatePolicy('user', 'Allow', event.routeArn)
    }

    return generatePolicy('user', 'Deny', event.routeArn)
};

function generatePolicy(principalId, effect, resource) {
    return {
      "principalId": principalId, // The principal user identification associated with the token sent by the client.
      "policyDocument": {
        "Version": "2012-10-17",
        "Statement": [{
          "Action": "execute-api:Invoke",
          "Effect": effect,
          "Resource": resource
        }]
      },
      "context": {
        "stringKey": "value",
        "numberKey": 1,
        "booleanKey": true,
        "arrayKey": ["value1", "value2"],
        "mapKey": { "value1": "value2" }
      }
    };
}

async function getDynamoToken(authToken) {
    const input = {
        Key: {
            token: {
                S: authToken,
            },
        },
        TableName: "usuariosLogados",
    };

    const command = new GetItemCommand(input);
    const dynamoResponse = await client.send(command);

    if (dynamoResponse.Item === undefined) {
        return false;
    }

    return true
    //   const dynamoUnmarshall = unmarshall(dynamoResponse.Item);

    //   return dynamoUnmarshall;
}
