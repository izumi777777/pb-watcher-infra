from hello_layer import say_hello

def lambda_handler(event, context):
    return {
        "message": say_hello()
    }
