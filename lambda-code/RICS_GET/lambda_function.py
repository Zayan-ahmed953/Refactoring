import oracledb
import os
import json
import io
import boto3
from botocore.exceptions import ClientError


def get_secret():
    '''
    Function to retrieve client secrets from AWS Secrets Manager
    '''

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=os.environ['region_name']
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=os.environ['secret_name']
        )
    except ClientError as e:
        raise e

    secret = json.loads(get_secret_value_response['SecretString'])

    return secret


def build_sql_query(query_params):
    '''
    Function that will take a query parameter (JSON) input
    and create a sql query string from it and record 
    the parameters from the sql query for
    binding/parameterization.
    '''
    sql_clauses = []
    parameters = {}

    mapping = {
        'fn':'first_name',
        'ln':'last_name',
        'n':'dea_no',
        'p':'phone_no',
        'e':'contact_email'
    }
    for key, value in query_params.items():
        # Normalize key for SQL (optional, if needed to match DB schema)
        col = key.lower()
        col = mapping.get(col)
        param_name = f":{col}"

        # Add to WHERE clause and parameter map
        sql_clauses.append(f"LOWER({col}) = LOWER({param_name})")
        parameters[col] = value

    where_sql = " AND ".join(sql_clauses)
    return where_sql, parameters


def lambda_handler(event, context):
    '''
    Lambda Handler will capture 'GET' events from a
    JSON payload through an API Gateway to GET
    information on a Registrant from the RICS DB.

    This handler contains flexibility to be able to handle various GET request
    JSON payload formats and still be able to return the correct information. 
    '''

    #get method piece
    print('Function start')
    print(f"Event: {event}")
    http_method = event.get("httpMethod", "")
    print(f"HTTP Method: {http_method}")

    #get RICS DB creds
    orcl_creds = get_secret()

    if (http_method == 'GET'):

        query_params = event.get("queryStringParameters")

        if not query_params:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "No input params given to be able to 'GET' correct data"})
            }

        where_sql, params = build_sql_query(query_params)    

        try:
            #connect to oracle db
            conn = oracledb.connect(
                user= orcl_creds['username'], #os.environ['db_user'],
                password= orcl_creds['password'], #os.environ['db_password'],
                dsn= os.environ['dsn']
            )
            print('Connected to DB')
        except:
            return {
                "statusCode": 503,
                "body": json.dumps({"error": f"Database connection failed. Make sure database is started and credentials are correct."})
            }            

        cur = conn.cursor()

        query = f"SELECT * FROM RICS_Test_File WHERE {where_sql}"
        
        try:
            cur.execute(query, params)
        except:
            return {
                "statusCode": 500,
                "body": json.dumps({"error": f"Database query execution failed. Recheck input query params."})
            }
        
        #retrieve the dea number from the query
        columns = [col[0] for col in cur.description]
        results = cur.fetchall()
        print(f"Query results: {results}")

        cur.close()
        conn.close()

        # Return 404 if no results are found from param query
        if not results:
            return {
                "statusCode": 404,
                "body": json.dumps({"message": f"No Registrant found with given query params."})
            }

        if len(results) > 1:
            return {
                "statusCode": 422,
                "body": json.dumps({
                    "message": "Multiple registrants found. Please include more identifying parameters to narrow down the search."
                })
            }        

        # Convert each row into a dict with column names
        json_results = []
        for row in results:
            row_dict = {}
            for col, val in zip(columns, row):
                row_dict[col] = str(val)
        json_results.append(row_dict)    
        
        #return the dea number
        return {
            "statusCode": 200,
            "headers": {"Content-Type":"application/json"},
            "body": json.dumps(json_results[0], default=str)
        }