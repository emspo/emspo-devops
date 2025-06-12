import psycopg2
import select
import pika
import json

RABBITMQ_HOST = 'localhost'
RABBITMQ_USER = 'user'
RABBITMQ_PASS = 'password'
QUEUE_NAME = 'email_queue'

# PG_CONN_INFO = "dbname=xx user=xx password=xx host=xx"

def main():
    # Connect to PostgreSQL
    # conn = psycopg2.connect(PG_CONN_INFO)    
    
    conn = psycopg2.connect(
        dbname="mspo_ts",
        user="postgres",
        password="Msp0@202A",
        host="192.168.69.11",
        port="5432"
    )

    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    cur.execute("LISTEN complaint_status_changes;")
    print("Listening for NOTIFY on channel 'complaint_status_changes'...")

    # Connect to RabbitMQ
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    parameters = pika.ConnectionParameters(host=RABBITMQ_HOST, credentials=credentials)
    rabbit_conn = pika.BlockingConnection(parameters)
    channel = rabbit_conn.channel()
    channel.queue_declare(queue=QUEUE_NAME, durable=True)

    try:
        while True:
            if select.select([conn], [], [], 5) == ([], [], []):
                continue
            conn.poll()
            while conn.notifies:
                notify = conn.notifies.pop(0)
                print(f"Got NOTIFY: {notify.payload}")
                channel.basic_publish(
                    exchange='',
                    routing_key=QUEUE_NAME,
                    body=notify.payload
                )
    except KeyboardInterrupt:
        print("Exiting...")
    finally:
        cur.close()
        conn.close()
        rabbit_conn.close()

if __name__ == '__main__':
    main()