import pika
import json
from send_email import send_email, EMAIL_FROM

RABBITMQ_HOST = 'localhost'  # Change to 'localhost' if running script on host, or 'rabbitmq' if inside another container
RABBITMQ_USER = 'user'
RABBITMQ_PASS = 'password'
QUEUE_NAME = 'email_queue'

def callback(ch, method, properties, body):
    try:
        data = json.loads(body)
        subject = data.get('subject')
        body_text = data.get('body')
        to_email = data.get('to')
        from_email = data.get('from_email', EMAIL_FROM)
        print(f"Received email request: {data}")
        send_email(subject, body_text, to_email, from_email)
    except Exception as e:
        print(f"Error processing message: {e}")

def main():
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    parameters = pika.ConnectionParameters(host=RABBITMQ_HOST, credentials=credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()
    channel.queue_declare(queue=QUEUE_NAME, durable=True)
    channel.basic_consume(queue=QUEUE_NAME, on_message_callback=callback, auto_ack=True)
    print('Waiting for email messages. To exit press CTRL+C')
    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        print("Stopping consumer...")
        channel.stop_consuming()
    finally:
        connection.close()

if __name__ == '__main__':
    main()
    
#     {
#   "subject": "Test",
#   "body": "Hello from RabbitMQ",
#   "to": "recipient@example.com"
# }