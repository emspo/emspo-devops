import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

EMAIL_FROM = "emspo@mspo.org.my"
EMAIL_PW = "M@rsh@2024?"
EMAIL_HOST = "smtp.office365.com"
EMAIL_PORT = 587
EMAIL_SECURE = False


# python send_email.py --subject "Test" --body "Hello from CLI" --to recipient@example.com

def send_email(subject, body, to_email, from_email):
    msg = MIMEMultipart()
    msg['From'] = from_email
    msg['To'] = to_email
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'plain'))

    try:
        print(f"Sending email to {to_email} with subject '{subject}'")
        with smtplib.SMTP(EMAIL_HOST, EMAIL_PORT) as server:
            server.starttls()
            server.login(EMAIL_FROM, EMAIL_PW)
            server.sendmail(EMAIL_FROM, to_email, msg.as_string())
        return True
    except Exception as e:
        print(f"Failed to send email: {e}")
        return False

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Send an email from the command line.")
    parser.add_argument("--subject", required=True, help="Email subject")
    parser.add_argument("--body", required=True, help="Email body")
    parser.add_argument("--to", required=True, help="Recipient email address")
    parser.add_argument("--from_email", default=EMAIL_FROM, help="Sender email address (default: EMAIL_FROM)")

    args = parser.parse_args()

    success = send_email(args.subject, args.body, args.to, args.from_email)
    if success:
        print("Email sent successfully.")
    else:
        print("Failed to send email.")